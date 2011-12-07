"""Interactive history editing.

Inspired by git rebase --interactive.
"""
from inspect import getargspec
try:
    import cPickle as pickle
except ImportError:
    import pickle
import tempfile
import os

from mercurial import cmdutil
from mercurial import error
from mercurial import hg
from mercurial import node
from mercurial import repair
from mercurial import patch
from mercurial import util
from mercurial import url
from mercurial import discovery
from mercurial.i18n import _

def _revsingle(repo, parent):
    return repo[parent]
_revsingle = getattr(cmdutil, 'revsingle', _revsingle)

if getattr(cmdutil, 'bailifchanged', None):
    from mercurial.cmdutil import bailifchanged
else:
    from mercurial.cmdutil import bail_if_changed as bailifchanged

# hg < 1.7
updatedir = getattr(patch, 'updatedir', None)
if updatedir is None:
    # hg >= 1.7
    updatedir = getattr(cmdutil, 'updatedir', None)
if updatedir is None:
    # hg >= 1.9
    from mercurial.scmutil import updatedir


try:
    hidepassword = util.hidepassword
except AttributeError:
    hidepassword = url.hidepassword

# Different signatures to patch.patch, and different cleanup requirements
if 'cwd' in getargspec(patch.patch)[0]:
    # mercurial < 1.9:
    #  - patch.patch takes cwd
    #  - use cmdutil.updatedir to cleanup
    def applypatch(ui, repo, patchname, strip=1, files=None, eolmode='strict',
                    similarity=0):
        # in mercurial < 1.9, patch.patch expects files to be a dictionary that
        # will be filled with filenames that have been changed, and requires
        # that this be run through updatedir
        if files is None:
            files = set()
        filedict = {}
        try:
            retval = patch.patch(patchname, ui, strip=strip, cwd=repo.root,
                                 files=filedict, eolmode=eolmode)
        finally:
            updatedir(ui, repo, filedict)
        files.update(filedict.keys())
        return retval
else:
    # mercurial > 1.9
    applypatch = patch.patch

# almost entirely stolen from the git-rebase--interactive.sh source
editcomment = """

# Edit history between %s and %s
#
# Commands:
#  p, pick = use commit
#  e, edit = use commit, but stop for amending
#  f, fold = use commit, but fold into previous commit
#  d, drop = remove commit from history
#  m, mess = edit message without changing commit content
#
"""

def between(repo, old, new, keep):
    revs = [old, ]
    current = old
    while current != new:
        ctx = repo[current]
        if not keep and len(ctx.children()) > 1:
            raise util.Abort('cannot edit history that would orphan nodes')
        if len(ctx.parents()) != 1 and ctx.parents()[1] != node.nullid:
            raise util.Abort("can't edit history with merges")
        if not ctx.children():
            current = new
        else:
            current = ctx.children()[0].node()
            revs.append(current)
    if len(repo[current].children()) and not keep:
        raise util.Abort('cannot edit history that would orphan nodes')
    return revs


def pick(ui, repo, ctx, ha, opts):
    oldctx = repo[ha]
    if oldctx.parents()[0] == ctx:
        ui.debug('node %s unchanged\n' % ha)
        return oldctx, [], [], []
    hg.update(repo, ctx.node())
    fd, patchfile = tempfile.mkstemp(prefix='hg-histedit-')
    fp = os.fdopen(fd, 'w')
    diffopts = patch.diffopts(ui, opts)
    diffopts.git = True
    diffopts.ignorews = False
    diffopts.ignorewsamount = False
    diffopts.ignoreblanklines = False
    gen = patch.diff(repo, oldctx.parents()[0].node(), ha, opts=diffopts)
    for chunk in gen:
        fp.write(chunk)
    fp.close()
    try:
        files = set()
        try:
            applypatch(ui, repo, patchfile, files=files, eolmode=None)
            if not files:
                ui.warn(_('%s: empty changeset')
                             % node.hex(ha))
                return ctx, [], [], []
        finally:
            os.unlink(patchfile)
    except Exception, inst:
        raise util.Abort(_('Fix up the change and run '
                           'hg histedit --continue'))
    n = repo.commit(text=oldctx.description(), user=oldctx.user(), date=oldctx.date(),
                    extra=oldctx.extra())
    return repo[n], [n, ], [oldctx.node(), ], []


def edit(ui, repo, ctx, ha, opts):
    oldctx = repo[ha]
    hg.update(repo, ctx.node())
    fd, patchfile = tempfile.mkstemp(prefix='hg-histedit-')
    fp = os.fdopen(fd, 'w')
    diffopts = patch.diffopts(ui, opts)
    diffopts.git = True
    diffopts.ignorews = False
    diffopts.ignorewsamount = False
    diffopts.ignoreblanklines = False
    gen = patch.diff(repo, oldctx.parents()[0].node(), ha, opts=diffopts)
    for chunk in gen:
        fp.write(chunk)
    fp.close()
    try:
        files = set()
        try:
            applypatch(ui, repo, patchfile, files=files, eolmode=None)
        finally:
            os.unlink(patchfile)
    except Exception, inst:
        pass
    raise util.Abort('Make changes as needed, you may commit or record as '
                     'needed now.\nWhen you are finished, run hg'
                     ' histedit --continue to resume.')

def fold(ui, repo, ctx, ha, opts):
    oldctx = repo[ha]
    hg.update(repo, ctx.node())
    fd, patchfile = tempfile.mkstemp(prefix='hg-histedit-')
    fp = os.fdopen(fd, 'w')
    diffopts = patch.diffopts(ui, opts)
    diffopts.git = True
    diffopts.ignorews = False
    diffopts.ignorewsamount = False
    diffopts.ignoreblanklines = False
    gen = patch.diff(repo, oldctx.parents()[0].node(), ha, opts=diffopts)
    for chunk in gen:
        fp.write(chunk)
    fp.close()
    try:
        files = set()
        try:
            applypatch(ui, repo, patchfile, files=files, eolmode=None)
            if not files:
                ui.warn(_('%s: empty changeset')
                             % node.hex(ha))
                return ctx, [], [], []
        finally:
            os.unlink(patchfile)
    except Exception, inst:
        raise util.Abort(_('Fix up the change and run '
                           'hg histedit --continue'))
    n = repo.commit(text='fold-temp-revision %s' % ha, user=oldctx.user(), date=oldctx.date(),
                    extra=oldctx.extra())
    return finishfold(ui, repo, ctx, oldctx, n, opts, [])

def finishfold(ui, repo, ctx, oldctx, newnode, opts, internalchanges):
    parent = ctx.parents()[0].node()
    hg.update(repo, parent)
    fd, patchfile = tempfile.mkstemp(prefix='hg-histedit-')
    fp = os.fdopen(fd, 'w')
    diffopts = patch.diffopts(ui, opts)
    diffopts.git = True
    diffopts.ignorews = False
    diffopts.ignorewsamount = False
    diffopts.ignoreblanklines = False
    gen = patch.diff(repo, parent, newnode, opts=diffopts)
    for chunk in gen:
        fp.write(chunk)
    fp.close()
    files = set()
    try:
        applypatch(ui, repo, patchfile, files=files, eolmode=None)
    finally:
        os.unlink(patchfile)
    newmessage = '\n***\n'.join(
        [ctx.description(), ] +
        [repo[r].description() for r in internalchanges] +
        [oldctx.description(), ])
    # If the changesets are from the same author, keep it.
    if ctx.user() == oldctx.user():
        username = ctx.user()
    else:
        username = ui.username()
    newmessage = ui.edit(newmessage, username)
    n = repo.commit(text=newmessage, user=username, date=max(ctx.date(), oldctx.date()),
                    extra=oldctx.extra())
    return repo[n], [n, ], [oldctx.node(), ctx.node() ], [newnode, ] # xxx

def drop(ui, repo, ctx, ha, opts):
    return ctx, [], [repo[ha].node(), ], []


def message(ui, repo, ctx, ha, opts):
    oldctx = repo[ha]
    hg.update(repo, ctx.node())
    fd, patchfile = tempfile.mkstemp(prefix='hg-histedit-')
    fp = os.fdopen(fd, 'w')
    diffopts = patch.diffopts(ui, opts)
    diffopts.git = True
    diffopts.ignorews = False
    diffopts.ignorewsamount = False
    diffopts.ignoreblanklines = False
    gen = patch.diff(repo, oldctx.parents()[0].node(), ha, opts=diffopts)
    for chunk in gen:
        fp.write(chunk)
    fp.close()
    try:
        files = set()
        try:
            applypatch(ui, repo, patchfile, files=files, eolmode=None)
        finally:
            os.unlink(patchfile)
    except Exception, inst:
        raise util.Abort(_('Fix up the change and run '
                           'hg histedit --continue'))
    message = oldctx.description()
    message = ui.edit(message, ui.username())
    new = repo.commit(text=message, user=oldctx.user(), date=oldctx.date(),
                      extra=oldctx.extra())
    newctx = repo[new]
    return newctx.parents()[0], [new], [oldctx.node()], []


actiontable = {'p': pick,
               'pick': pick,
               'e': edit,
               'edit': edit,
               'f': fold,
               'fold': fold,
               'd': drop,
               'drop': drop,
               'm': message,
               'mess': message,
               }
def histedit(ui, repo, *parent, **opts):
    """hg histedit <parent>
    """
    # TODO only abort if we try and histedit mq patches, not just
    # blanket if mq patches are applied somewhere
    mq = getattr(repo, 'mq', None)
    if mq and mq.applied:
        raise util.Abort(_('source has mq patches applied'))

    parent = list(parent) + opts.get('rev', [])
    if opts.get('outgoing'):
        if len(parent) > 1:
            raise util.Abort('only one repo argument allowed with --outgoing')
        elif parent:
            parent = parent[0]

        dest = ui.expandpath(parent or 'default-push', parent or 'default')
        dest, revs = hg.parseurl(dest, None)[:2]
        if isinstance(revs, tuple):
            # hg >= 1.6
            revs, checkout = hg.addbranchrevs(repo, repo, revs, None)
            other = hg.repository(hg.remoteui(repo, opts), dest)
            # hg >= 1.9
            findoutgoing = getattr(discovery, 'findoutgoing', None)
            if findoutgoing is None:
                def findoutgoing(repo, other, force=False):
                    common, outheads = discovery.findcommonoutgoing(
                        repo, other, [], force=force)
                    return repo.changelog.findmissing(common, outheads)[0:1]
        else:
            other = hg.repository(ui, dest)
            def findoutgoing(repo, other, force=False):
                return repo.findoutgoing(other, force=force)

        if revs:
            revs = [repo.lookup(rev) for rev in revs]

        ui.status(_('comparing with %s\n') % hidepassword(dest))
        parent = findoutgoing(repo, other, force=opts.get('force'))
    else:
        if opts.get('force'):
            raise util.Abort('--force only allowed with --outgoing')

    if opts.get('continue', False):
        if len(parent) != 0:
            raise util.Abort('no arguments allowed with --continue')
        (parentctxnode, created, replaced,
         tmpnodes, existing, rules, keep, tip, ) = readstate(repo)
        currentparent, wantnull = repo.dirstate.parents()
        parentctx = repo[parentctxnode]
        # discover any nodes the user has added in the interim
        newchildren = [c for c in parentctx.children()
                       if c.node() not in existing]
        action, currentnode = rules.pop(0)
        while newchildren:
            if action in ['f', 'fold', ]:
                tmpnodes.extend([n.node() for n in newchildren])
            else:
                created.extend([n.node() for n in newchildren])
            newchildren = filter(lambda x: x.node() not in existing,
                                 reduce(lambda x, y: x + y,
                                        map(lambda r: r.children(),
                                            newchildren)))
        m, a, r, d = repo.status()[:4]
        oldctx = repo[currentnode]
        message = oldctx.description()
        if action in ('e', 'edit', 'm', 'mess'):
            message = ui.edit(message, ui.username())
        elif action in ('f', 'fold', ):
            message = 'fold-temp-revision %s' % currentnode
        new = None
        if m or a or r or d:
            new = repo.commit(text=message, user=oldctx.user(), date=oldctx.date(),
                              extra=oldctx.extra())

        if action in ('f', 'fold'):
            if new:
                tmpnodes.append(new)
            else:
                new = newchildren[-1]
            (parentctx, created_,
             replaced_, tmpnodes_, ) = finishfold(ui, repo,
                                                  parentctx, oldctx, new,
                                                  opts, newchildren)
            replaced.extend(replaced_)
            created.extend(created_)
            tmpnodes.extend(tmpnodes_)
        elif action not in ('d', 'drop'):
            if new != oldctx.node():
                replaced.append(oldctx.node())
            if new:
                if new != oldctx.node():
                    created.append(new)
                parentctx = repo[new]

    elif opts.get('abort', False):
        if len(parent) != 0:
            raise util.Abort('no arguments allowed with --abort')
        (parentctxnode, created, replaced, tmpnodes,
         existing, rules, keep, tip, ) = readstate(repo)
        ui.debug('restore wc to old tip %s\n' % node.hex(tip))
        hg.clean(repo, tip)
        ui.debug('should strip created nodes %s\n' %
                 ', '.join([node.hex(n)[:12] for n in created]))
        ui.debug('should strip temp nodes %s\n' %
                 ', '.join([node.hex(n)[:12] for n in tmpnodes]))
        for nodes in (created, tmpnodes, ):
            for n in reversed(nodes):
                try:
                    repair.strip(ui, repo, n)
                except error.LookupError:
                    pass
        os.unlink(os.path.join(repo.path, 'histedit-state'))
        return
    else:
        bailifchanged(repo)
        if os.path.exists(os.path.join(repo.path, 'histedit-state')):
            raise util.Abort('history edit already in progress, try '
                             '--continue or --abort')

        tip, empty = repo.dirstate.parents()


        if len(parent) != 1:
            raise util.Abort('requires exactly one parent revision')
        parent = _revsingle(repo, parent[0]).node()

        keep = opts.get('keep', False)
        revs = between(repo, parent, tip, keep)

        ctxs = [repo[r] for r in revs]
        existing = [r.node() for r in ctxs]
        rules = opts.get('commands', '')
        if not rules:
            rules = '\n'.join([('pick %s %s' % (
                c.hex()[:12], c.description().splitlines()[0]))[:80]
                               for c in ctxs])
            rules += editcomment % (node.hex(parent)[:12], node.hex(tip)[:12], )
            rules = ui.edit(rules, ui.username())
        else:
            f = open(rules)
            rules = f.read()
            f.close()
        rules = [l for l in (r.strip() for r in rules.splitlines())
                 if l and not l[0] == '#']
        rules = verifyrules(rules, repo, ctxs)

        parentctx = repo[parent].parents()[0]
        keep = opts.get('keep', False)
        replaced = []
        tmpnodes = []
        created = []


    while rules:
        writestate(repo, parentctx.node(), created, replaced, tmpnodes, existing,
                   rules, keep, tip)
        action, ha = rules.pop(0)
        (parentctx, created_,
         replaced_, tmpnodes_, ) = actiontable[action](ui, repo,
                                                       parentctx, ha,
                                                       opts)
        created.extend(created_)
        replaced.extend(replaced_)
        tmpnodes.extend(tmpnodes_)

    hg.update(repo, parentctx.node())

    if not keep:
        ui.debug('should strip replaced nodes %s\n' %
                 ', '.join([node.hex(n)[:12] for n in replaced]))
        for n in sorted(replaced, lambda x, y: cmp(repo[x].rev(), repo[y].rev())):
            try:
                repair.strip(ui, repo, n)
            except error.LookupError:
                pass

    ui.debug('should strip temp nodes %s\n' %
             ', '.join([node.hex(n)[:12] for n in tmpnodes]))
    for n in reversed(tmpnodes):
        try:
            repair.strip(ui, repo, n)
        except error.LookupError:
            pass
    os.unlink(os.path.join(repo.path, 'histedit-state'))


def writestate(repo, parentctxnode, created, replaced,
               tmpnodes, existing, rules, keep, oldtip):
    fp = open(os.path.join(repo.path, 'histedit-state'), 'w')
    pickle.dump((parentctxnode, created, replaced,
                 tmpnodes, existing, rules, keep, oldtip,),
                fp)
    fp.close()

def readstate(repo):
    """Returns a tuple of (parentnode, created, replaced, tmp, existing, rules, keep, oldtip, ).
    """
    fp = open(os.path.join(repo.path, 'histedit-state'))
    return pickle.load(fp)


def verifyrules(rules, repo, ctxs):
    """Verify that there exists exactly one edit rule per given changeset.

    Will abort if there are to many or too few rules, a malformed rule,
    or a rule on a changeset outside of the user-given range.
    """
    parsed = []
    first = True
    if len(rules) != len(ctxs):
        raise util.Abort('must specify a rule for each changeset once')
    for r in rules:
        if ' ' not in r:
            raise util.Abort('malformed line "%s"' % r)
        action, rest = r.split(' ', 1)
        if ' ' in rest.strip():
            ha, rest = rest.split(' ', 1)
        else:
            ha = r.strip()
        try:
            if repo[ha] not in ctxs:
                raise util.Abort('may not use changesets other than the ones listed')
        except error.RepoError:
            raise util.Abort('unknown changeset %s listed' % ha)
        if action not in actiontable:
            raise util.Abort('unknown action "%s"' % action)
        parsed.append([action, ha])
    return parsed


cmdtable = {
    "histedit":
        (histedit,
         [('', 'commands', '', 'Read history edits from the specified file.'),
          ('c', 'continue', False, 'continue an edit already in progress', ),
          ('k', 'keep', False, 'don\'t strip old nodes after edit is complete', ),
          ('', 'abort', False, 'abort an edit in progress', ),
          ('o', 'outgoing', False, 'changesets not found in destination'),
          ('f', 'force', False, 'force outgoing even for unrelated repositories'),
          ('r', 'rev', [], _('first revision to be edited')),
          ],
         __doc__,
         ),
}
