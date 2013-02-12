# collapse.py - collapse feature for mercurial
#
# Copyright 2009 Colin Caughie <c.caughie at indigovision dot com>
# Copyright 2011 Peer Stritzinger GmbH  http://www.stritzinger.com
#                                       https://bitbucket.org/peerst
# This software may be used and distributed according to the terms
# of the GNU General Public License, incorporated herein by reference.

'''collapse multiple revisions into one
'''

from mercurial import util, repair, merge, cmdutil, commands
from mercurial.node import nullrev, hex
from mercurial.i18n import _
import re
import StringIO
import os
import time

def collapse(ui, repo, **opts):
    """collapse multiple revisions into one

    Collapse combines multiple consecutive changesets into a single changeset,
    preserving any descendants of the final changeset. The commit messages for
    the collapsed changesets are concatenated and may be edited before the
    collapse is completed.
    """

    hg_vsn = util.version()
    vsn_list = [ int(x) for x in hg_vsn.split(".") ]
    if vsn_list < [2,0]:
        raise util.Abort(_('Mercurial version to low (%s), '
                           'you need at least 2.0') % hg_vsn)

    try:
        from mercurial import scmutil
        rng = scmutil.revrange(repo, opts['rev'])
    except ImportError:
        rng = cmdutil.revrange(repo, opts['rev'])

    if opts['movelog']:
        movelog = open(opts['movelog'], 'a')
    else:
        movelog = False
            
    if opts['timedelta']:
        timedelta = float(opts['timedelta'])
    else:
        timedelta = float('inf')

    if not opts['auto']:
        if not rng:
            raise util.Abort(_('no revisions specified'))

        if opts['timedelta']:
            raise util.Abort(_('-t or --timedelta only valid with --auto'))
        if opts['userchange']:
            raise util.Abort(_('-u or --userchange only valid with --auto'))
        # FIXME add more options that don't work
        # FIXME FIXME: rework ui to make the distinction between auto
        # and not unnecessary.  Integrate revsets (event disjoint)

        first = rng[0]
        last = rng[-1]
        revs = inbetween(repo, first, last)

        if not revs:
            raise util.Abort(_('revision %s is not an ancestor '
                               'of revision %s\n') % (first, last))
        elif len(revs) == 1:
            raise util.Abort(_('only one revision specified'))
        do_collapse(ui, repo, first, last, revs, movelog, timedelta,
            opts)

    else:                       # auto mode
        if len(rng) == 0:
            start = 0
        elif len(rng) == 1:
            start = rng[0]
        else:
            util.Abort(_('multiple revisions specified with auto mode'))

        count = 0
        while count < 1 or opts['repeat']:
            if opts['usefirst']:
                revs = find_first_chunk(ui, repo, start, timedelta, opts)
            else:
                revs = find_last_chunk(ui, repo, start, timedelta, opts)

            if not revs:
                if count == 0:
                    raise util.Abort(_('no revision chunk found\n'))
                else:
                    break

            first = min(revs)
            last = max(revs)

            assert len(revs) > 1
            do_collapse(ui, repo, first, last, revs, movelog, timedelta, opts)
            count += 1
            

def do_collapse(ui, repo, first, last, revs, movelog, timedelta, opts):        
    ui.debug(_('Collapsing revisions %s\n') % revs)

    if opts['debugdelay']:
        debug_delay = float(opts['debugdelay'])
    else:
        debug_delay = False

    for r in revs:
        if repo[r].user() != ui.username() and not opts['force']:
            raise util.Abort(_('revision %s does not belong to %s\n') %
                (r, ui.username()))
        if r != last:
            children = repo[r].children()
            if len(children) > 1:
                for c in children:
                    if not c.rev() in revs:
                        raise util.Abort(_('revision %s has child %s not '
                            'being collapsed, please rebase\n') % (r, c.rev()))
        if r != first:
            parents = repo[r].parents()
            if len(parents) > 1:
                for p in parents:
                    if not p.rev() in revs:
                        raise util.Abort(_('revision %s has parent %s not '
                            'being collapsed.') % (r, p.rev()))

    if len(repo[first].parents()) > 1:
        raise util.Abort(_('start revision %s has multiple parents, '
            'won\'t collapse.') % first)

    try:
        cmdutil.bailifchanged(repo)
    except AttributeError:
        cmdutil.bail_if_changed(repo)

    parent = repo[first].parents()[0]
    tomove = list(repo.changelog.descendants(last))

    head_hgtags = get_hgtags_from_heads(ui, repo, last)
    if '.hgtags' in parent:
        parent_hgtags = parent['.hgtags'].data()
    else:
        parent_hgtags = False

    movemap = dict.fromkeys(tomove, nullrev)
    ui.debug(_('will move revisions: %s\n') % tomove)

    tagsmap = dict()
    if opts['noop']:
        ui.status(_('noop: not collapsing\n'))
    else:
        origparent = repo['.'].rev()
        collapsed = None

        try:
            branch = repo[last].branch()
            collapsed = makecollapsed(ui, repo, parent, revs, branch, tagsmap,
                                      parent_hgtags, movelog, opts)
            movemap[max(revs)] = collapsed
            movedescendants(ui, repo, collapsed, tomove, movemap, tagsmap, 
                            parent_hgtags, movelog, debug_delay)
            fix_hgtags(ui, repo, head_hgtags, tagsmap)
        except:
            merge.update(repo, repo[origparent].rev(), False, True, False)
            if collapsed:
                repair.strip(ui, repo, collapsed.node(), "strip")
            raise

        if not opts['keep']:
            ui.debug(_('stripping revision %d\n') % first)
            repair.strip(ui, repo, repo[first].node(), "strip")

        ui.status(_('collapse completed\n'))

def makecollapsed(ui, repo, parent, revs, branch, tagsmap, parent_hgtags, 
                  movelog, opts):
    'Creates the collapsed revision on top of parent'

    last = max(revs)
    ui.debug(_('updating to revision %d\n') % parent)
    merge.update(repo, parent.node(), False, False, False)
    ui.debug(_('reverting to revision %d\n') % last)
    recreaterev(ui, repo, last)
    repo.dirstate.setbranch(branch)
    msg = ''
    nodelist = []
    if opts['message'] != "" :
        msg = opts['message']
    else:
        first = True
        for r in revs:
            nodelist.append(hex(repo[r].node()))
            if repo[r].files() != ['.hgtags']:
                if not first:
                    if opts['changelog']:
                        msg += '\n'
                    else:
                        msg += '----------------\n'
                first = False
                if opts['changelog']:
                    msg += "* " + ' '.join(repo[r].files()) + ":\n"

                msg += repo[r].description() + "\n"

        msg += "\nHG: Enter commit message.  Lines beginning with 'HG:' are removed.\n"
        msg += "HG: Remove all lines to abort the collapse operation.\n"

        if ui.config('ui', 'interactive') != 'off':
            msg = ui.edit(msg, ui.username())

        pattern = re.compile("^HG:.*\n", re.MULTILINE);
        msg  = re.sub(pattern, "", msg).strip();

    if not msg:
        raise util.Abort(_('empty commit message, collapse won\'t proceed'))

    write_hgtags(parent_hgtags)
    newrev = repo.commit(
        text=msg,
        user=repo[last].user(),
        date=repo[last].date())

    ctx = repo[newrev]

    newhex = hex(ctx.node())
    for n in nodelist:
        ui.debug(_('makecollapsed %s -> %s\n' % (n, newhex))) 
        tagsmap[n] = newhex
        if movelog:
            movelog.write('coll %s -> %s\n' % (n, newhex))
        
    return ctx

def movedescendants(ui, repo, collapsed, tomove, movemap, tagsmap, 
                    parent_hgtags, movelog, debug_delay):
    'Moves the descendants of the source revisions to the collapsed revision'

    sorted_tomove = list(tomove)
    sorted_tomove.sort()

    for r in sorted_tomove:
        ui.debug(_('moving revision %r\n') % r)

        if debug_delay:
            ui.debug(_('sleep debug_delay: %r\n') % debug_delay)
            time.sleep(debug_delay)

        parents = [p.rev() for p in repo[r].parents()]
        nodehex = hex(repo[r].node())
        if repo[r].files() == ['.hgtags'] and len(parents) == 1:
            movemap[r] = movemap[parents[0]]
            phex = hex(repo[parents[0]].node())
            assert phex in tagsmap
            tagsmap[nodehex] = tagsmap[phex]
        else:
            if len(parents) == 1:
                ui.debug(_('setting parent to %d\n') 
                         % movemap[parents[0]].rev())
                repo.dirstate.setparents(movemap[parents[0]].node())
            else:
                ui.debug(_('setting parents to %d and %d\n') %
                    (map_or_rev(repo, movemap, parents[0]).rev(), 
                     map_or_rev(repo, movemap, parents[1]).rev()))
                repo.dirstate.setparents(map_or_rev(repo, movemap, 
                                                    parents[0]).node(),
                                         map_or_rev(repo, movemap, 
                                                    parents[1]).node())

            repo.dirstate.write()
            
            ui.debug(_('reverting to revision %d\n') % r)
            recreaterev(ui, repo, r)

            write_hgtags(parent_hgtags)
            newrev = repo.commit(text=repo[r].description(), 
                                 user=repo[r].user(), date=repo[r].date(),
                                 force=True)

            if newrev == None:
                raise util.Abort(_('no commit done: text=%r, user=%r, date=%r')
                                 % (repo[r].description(), repo[r].user(), 
                                    repo[r].date()))
                
            ctx = repo[newrev]
            movemap[r] = ctx

            newhex = hex(ctx.node())
            tagsmap[nodehex] = newhex
            ui.debug(_('movedescendants %s -> %s\n' % (nodehex, newhex)))
            if movelog:
                movelog.write('move %s -> %s\n' % (nodehex, newhex))

def write_hgtags(hgtags):
    if hgtags:
        hgf = open('.hgtags', 'wb')
        hgf.write(hgtags)
        hgf.close()
    else:
        try:
            os.remove('.hgtags')
        except OSError:
            pass        # .hgtags might well still not exist


def map_or_rev(repo, movemap, rev):
    if rev in movemap:
        return movemap[rev]
    else:
        return repo[rev]

def recreaterev(ui, repo, rev):
    ui.debug(_('reverting to revision %d\n') % rev)
    commands.revert(ui, repo, rev=rev, all=True, date=None, no_backup=True)

    wctx = repo[None]
    node = repo[rev]

    ss = node.substate

    for path, info in ss.items():
        ui.debug(_('updating subrepo %s to revision %s\n') % (path, info[1]))
        wctx.sub(path).get(info)

def fix_hgtags(ui, repo, head_hgtags, tagsmap):
    for tf in iter(tagsmap):
        ui.debug('fix_hgtags: tagsmap %s -> %s\n' % (tf, tagsmap[tf]))
    for old in iter(head_hgtags):
        new = map_recursive(tagsmap, old)
        ui.debug('fix_hgtags: head %s -> %s\n' % (old, new))
        merge.update(repo, repo[new].node(), False, False, False)
        tfile = open('.hgtags', 'wb')
        lines = StringIO.StringIO(head_hgtags[old])
        for line in lines:
            if not line:
                continue
            (nodehex, name) = line.split(" ", 1)
            name = name.strip()
            nhm = map_recursive(tagsmap, nodehex)
            ui.debug('fix_hgtags: hgtags write: %s %s\n' % (nhm, name))
            tfile.write('%s %s\n' % (nhm, name))
        lines.close()    
        tfile.close()
        wctx = repo[None]
        if '.hgtags' not in wctx:
            wctx.add(['.hgtags'])
        nrev = repo.commit(text="collapse tag fix")
        if nrev:
            nctx = repo[nrev]
            ui.debug(_('fix_hgtags: nctx rev %d node %r files %r\n') % 
                     (nctx.rev(), hex(nctx.node()), nctx.files()))
            ui.debug(_('fix_hgtags: nctx parents %r\n') % 
                      ([hex(p.node()) for p in nctx.parents()]))
        else:
            ui.debug(_('fix_hgtags: nctx: None\n'))

def map_recursive(m, key):
    res = key
    while res in m:
        res = m[res]
    return res

def inbetween(repo, first, last):
    'Return all revisions between first and last, inclusive'

    if first == last:
        return set([first])
    elif last < first:
        return set()

    parents = [p.rev() for p in repo[last].parents()]

    if not parents:
        return set()

    result = inbetween(repo, first, parents[0])
    if len(parents) == 2:
        result = result | inbetween(repo, first, parents[1])

    if result:
        result.add(last)

    return result

def get_hgtags_from_heads(ui, repo, rev):
    from mercurial import scmutil
    heads = scmutil.revrange(repo,['heads(%d::)' % (rev)])
    ui.debug(_('get_hgtags_from_heads: rev: %d heads: %r\n') % (rev, heads))
    head_hgtags = dict()
    for h in heads:
        if '.hgtags' in repo[h]:
            hgtags = repo[h]['.hgtags'].data()
            hnode = hex(repo[h].node())
            ui.debug(_('get_hgtags_from_heads: head_hgtags[%s]:\n%s\n') 
                     % (hnode, hgtags))
            head_hgtags[hnode] = hgtags
    return head_hgtags


def find_first_chunk(ui, repo, start, timedelta, opts):
    return find_chunk(ui, repo, start, set(), timedelta, opts)

def find_last_chunk(ui, repo, start, timedelta, opts):
    revs = find_chunk(ui, repo, start, set(), timedelta, opts)
    if revs:
        children = [c.rev() for c in repo[max(revs)].children()]
        for c in children:
            found = find_last_chunk(ui, repo, c, timedelta, opts)
            if found:
                return found
        return revs
    else:
        return set()

def find_chunk(ui, repo, start, acc, timedelta, opts):
    'Find first linear chunk, traversing from start'

    children = [c.rev() for c in repo[start].children()]
    parents = [p.rev() for p in repo[start].parents()]

    ui.debug(_('find_chunk(%d, %s) children %s parents %s\n') 
             % (start, acc, children, parents))

    if len(parents) == 1 and not auto_exclude(ui, repo, start):
        if stop_here(ui, repo, parents[0], start, acc, timedelta, opts):
            if len(acc) > 1:
                return acc
            else:
                acc = set()
        acc.add(start)
    else:
        if len(acc) > 1:
            return acc
        else:
            acc = set()

    if len(children) == 0:
        if len(acc) > 1:
            return acc
        else:
            return set()
    elif len(children) == 1:
        return find_chunk(ui, repo, children[0], acc, timedelta, opts)
    else:
        if len(acc) > 1:
            return acc
        else:
            for c in children:
                found = find_chunk(ui, repo, c, set(), timedelta, opts)
                if found:
                    return found
            return set()

def stop_here(ui, repo, parent, current, acc, timedelta, opts):
    if current == 0:
        return False

    td = repo[current].date()[0] - repo[parent].date()[0]
    if td > timedelta:
        ui.debug(_('timedelta parent %s current %s is %s (max %s) -> stop\n') 
                 % (parent, current, td, timedelta))
        return True

    if opts['userchange']:
        if repo[current].user() != repo[parent].user():
            ui.debug(_('userchange parent %s user %s current %s user %s, '
                       '-> stop\n') 
                     % (parent, repo[parent].user(), 
                        current, repo[current].user()))
            return True

    if opts['singlefile']:
        fs = set([item for sublist in 
                  [repo[r].files() for r in acc] for item in sublist])
        cs = set(repo[current].files())
        if not fs.isdisjoint(cs):
            ui.debug(_('singlefile current %s fs %s cs %s -> stop\n') 
                     % (current, fs, cs))
            return True

    if not opts['tagcollapse']:
        if repo[parent].tags():
            ui.debug(_('parent %s has tags %s -> stop\n') 
                     % (parent, repo[parent].tags()))
            return True

    return False

def auto_exclude(ui, repo, current):
    if not repo[current].children() and '.hgtags' in repo[current].files():
        ui.debug(_('.hgtags in head %s -> exclude\n') % (current))
        return True

    return False


cmdtable = {
"collapse":
        (collapse,
        [
        ('r', 'rev', [], _('revisions to collapse')),
        ('', 'keep', False, _('keep original revisions')),
        ('f', 'force', False, _('force collapse of changes '
                                'from different users')),
        ('a', 'auto', False, _('DEPRECATED: auto collapse mode')),
        ('', 'usefirst', False, _('DEPRECATED: use first match instead of last '
                                  '(slower with --repeat)')),
        ('',  'repeat', False, _('DEPRECATED: reapeat auto collapse until no '
                                 'matches are found')),
        ('t', 'timedelta', '', _('DEPRECATED: maximum time gap between '
                                    'changesets in seconds')),
        ('u', 'userchange', False, _('DEPRECATED: don\'t auto-collapse '
                                  'when the user changed')),
        ('F', 'singlefile', False, _('DEPRECATED: don\'t autocollapse multiple '
                                     'changes to the same file')),
        ('T', 'tagcollapse', False, _('DEPRECATED: auto collapse tagged '
                                      'revisions')),
        ('C', 'changelog', False, _('alternate style for commit message '
                                    'combination')),
        ('L', 'movelog', '', _('DEPRECATED: appends "{move,coll} '
                               'oldnode -> newnode to this file. '
                               'MUST BE OUTSIDE THE REPOSITORY!')),
        ('n', 'noop', False, _('dry run, do not change repo')),
        ('m', 'message', "", _('use <text> as combined commit message')),
        ('', 'debugdelay', '', _('DEPRECATED: for testsuite use only '
                                  'this adds a delay between changeset moves '
                                  'and provokes a problem with revert'))
        ],
        _('hg collapse [OPTIONS] -r REVS')),
}
