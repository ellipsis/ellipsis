#!/usr/bin/env python2.7
"""
description
  hoodoo is a task management app. tasks can be tagged, searched, sorted.

commands available
  add <name> #<tag>    add a new task
    alias: +
    opt: created=<date> due=<date> done=True/False, tags

  edit <index>         edit a task
    alias: e
    opt: name=<name> created=<date> due=<date> done=True/False, tags

  del <index>          delete a task
    alias: rm, -

  done <index>         mark task as done
    alias: x

  list                 list tasks
    alias: ls

  search <query>       search through tasks by name or tag
    alias: default action if arguments do not match options

  set <name>           switch to another set, if it does not exist create it

  sets                 list sets

notes:
  to be able to tag without quotes with most shells you will
  probably need to disable globbing. for zsh add this alias:
  alias hoodoo='noglob python path/to/hoodoo.py'
"""

import os, sys
from string import punctuation, whitespace
from datetime import datetime
from time import strptime
from functools import reduce

try:
    import cPickle as pickle
except ImportError:
    import pickle

PROJECT = os.path.basename(os.getcwd())
PROJECTDIR = os.path.join(os.getcwd(), '.hoodoo')
SETSDIR = os.path.join(PROJECTDIR, 'sets')

def clean(s):
    s = s.lower()
    for char in punctuation, whitespace:
        s = s.replace(char, '')
    return s

def load_it(f):
    f = open(f, 'r+b')
    unpickled = pickle.load(f)
    return unpickled

def save_it(f, obj):
    f = open(f, 'wb')
    pickle.dump(obj, f, 2)

def init(args):
    if not os.path.isdir(PROJECTDIR):
        os.mkdir(PROJECTDIR)
        os.mkdir(SETSDIR)
    else:
        print(PROJECT, 'has already been initialized')
        return
    cfg = {'current_set': 'default', 'default_format': 0}
    task_list = []
    save_it(os.path.join(PROJECTDIR, 'hoodoo_settings'), cfg)
    save_it(os.path.join(SETSDIR, 'default'), task_list)
    print(PROJECT + ' initialized')

def switch_set(args):
    task_set = args[0]
    try:
        cfg['current_set'] = task_set
        save_it(os.path.join(PROJECTDIR, 'hoodoo_settings'), cfg)
    except:
        task_list = []
        save_it(os.path.join(SETSDIR, task_set), task_list)
        cfg['current_set'] = task_set
        save_it(os.path.join(PROJECTDIR, 'hoodoo_settings'), cfg)
    print('switched to ' + task_set)

def fmt_task(task, index, format):
    if format == 0:
        base = len(str(task_len))
        index = "{0:0=#{1}}".format(index, base)
        name = task[0]
        if task[3] is True:
            done = ' x'
        else:
            done = ''
        if task[4] is not None:
            tags = task[4]
        else:
            tags = ''
        if task[2] is not None:
            due = 'due:' + task[2]
        else:
            due = ''
        return "{0}{1} {2} {3} {4}".format(index, done, name, tags, due)
    elif format == 1:
        base = len(str(task_len))
        index = "{0:0=#{1}}".format(index, base)
        name = task[0]
        created = task[1].strftime("%m-%d-%y").lower()
        if task[3] is True:
            done = ' x'
        else:
            done = ''
        if task[4] is not None:
            tags = task[4]
        else:
            tags = ''
        if task[2] is not None:
            due = 'due:' + task[2]
        else:
            due = ''
        return "{0}{1} {2} {3} {4}".format(index, done, name, created, tags, due)

def add_task(args):
    name = args[0]
    created = datetime.now()
    due = None
    done = False
    tags = []
    for arg in args[1:]:
        if arg.startswith('#'):
            tags.append(arg)
        elif arg.startswith('created'):
            arg = arg.split('=')[1]
            created = strptime(arg, "%m-%d-%y")
        elif arg.startswith('due'):
            arg = arg.split('=')[1]
            due = strptime(arg, "%m-%d-%y")
        elif arg.startswith('done'):
            arg = arg.split('=')[1].lower()
            if arg == 'true' or 'x':
                done = True
            else:
                done = False
        else:
            name += ' ' + arg
    clean_name = clean(name)
    if len(tags) > 0:
        tag_fmt = reduce(lambda x,y: x + ' ' + y, tags)
        clean_tags = clean(tag_fmt)
    else:
        tag_fmt = None
        clean_tags = None
    matches = list(filter(lambda x: x[0] == name, task_list))
    if len(matches) == 0: # check if task already exists
        task = (name, created, due, done, tag_fmt, clean_name, clean_tags)
        task_list.append(task)
    else:
        print('task with the name: ' + name + ' already exists!')
        return
    save_it(os.path.join(SETSDIR, task_set), task_list)
    index = task_len + 1
    print('added task: ' + fmt_task(task, index, 0))

def edit_task(args):
    try:
        index = int(args[0]) - 1
        task = list(task_list[index])
    except:
        print('Not a valid task')
        return
    for arg in args[1:]:
        if arg.startswith('name'):
            arg = arg.split('=')[1]
            task[0] = arg
            task[5] = clean(arg)
        elif arg.startswith('created'):
            arg = arg.split('=')[1]
            task[1] = strptime(arg, "%m-%d-%y")
        elif arg.startswith('due'):
            arg = arg.split('=')[1]
            task[2] = strptime(arg, "%m-%d-%y")
        elif arg.startswith('done'):
            arg = arg.split('=')[1]
            task[3] = arg
        elif arg.startswith('tags'):
            arg = arg.split('=')[1]
            tag_fmt = reduce(lambda x,y: x + ' ' + y, arg.split(','))
            task[4] = tag_fmt
            task[6] = clean(tag_fmt)
    task_list[index] = tuple(task)
    save_it(os.path.join(SETSDIR, task_set), task_list)

def done(args):
    try:
        index = int(args[0]) - 1
        task = list(task_list[index])
    except:
        print('Not a valid task')
        return
    task[3] = True
    task_list[index] = tuple(task)
    save_it(os.path.join(SETSDIR, task_set), task_list)

def delete_task(args):
    try:
        index = int(args[0]) - 1
        task = list(task_list[index])[0]
        task_list.pop(index)
    except:
        print('Not a valid task')
        return
    print('deleting task ' + str(index + 1) + ' ' + task)
    save_it(os.path.join(SETSDIR, task_set), task_list)

def list_tasks(args):
    if task_len > 0:
        index = 1
        try:
            offset = int(args[0])
            if offset < 0:
                for task in task_list[:offset]:
                    print(fmt_task(task, index, 0))
                    index += 1
            else:
                for task in task_list[offset:]:
                    print(fmt_task(task, index, 0))
                    index += 1
        except:
            for task in task_list:
                print(fmt_task(task, index, 0))
                index += 1
    else:
        print('no tasks yet!')

def list_sets(args):
    sets = os.listdir(SETSDIR)
    for set in sets: print(set)

def search(args):
    query = args[0]
    matches = False
    try:
        index = int(args[0]) - 1
        task = task_list[index]
        print(fmt_task(task, index + 1, 1))
        return
    except:
        index = 1
        print('searching for ' + query)
    if query.startswith('#'):
        query = clean(query)
        for task in task_list:
            if task[6] is not None:
                if task[6].find(query) is not -1:
                    print(fmt_task(task, index, 0))
                    matches = True
                index += 1
    else:
        query = clean(query)
        for task in task_list:
            if task[5].find(query) is not -1:
                print(fmt_task(task, index, 0))
                matches = True
            index += 1
    if matches is False:
        print('no matches found')

def print_help(args):
    print(__doc__)

def print_command_list(args):
    print """add:add a new item
edit:edit an existing item
del:delete an item
done:mark item as done
list:list all items
init:initialize a directory
rm:delete an item
ls:list all items
help:show help
search:search items
set:change set
sets:list sets"""

if __name__ == "__main__":
    opts = {'add': add_task,
            'del': delete_task,
            'done': done,
            'edit': edit_task,
            'init': init,
            'list': list_tasks,
            'search': search,
            'set': switch_set,
            'sets': list_sets,
            'help': print_help,
            '+': add_task,
            '-': delete_task,
            'rm': delete_task,
            'x': done,
            'e': edit_task,
            'ls': list_tasks,
            'h': print_help,
            'command_list': print_command_list}
    non_init_cmds = {'h': print_help, 'help': print_help, 'command_list': print_command_list, 'init': init}
    if sys.argv.__len__() > 1 and sys.argv[1] in non_init_cmds:
        args = sys.argv[2:]
        non_init_cmds[sys.argv[1]](args)
        sys.exit(0)
    try:
        cfg = load_it(os.path.join(PROJECTDIR, 'hoodoo_settings'))
        task_set = cfg['current_set']
        task_list = load_it(os.path.join(SETSDIR, task_set))
        task_len = len(task_list)
        print('hoodoo :: ' + PROJECT + '/' + task_set + ' :: ' + str(task_len) + ' tasks')
    except:
        print('This directory has not been initialized, try using init')
        sys.exit(0)
    if sys.argv.__len__() > 1:
        if sys.argv[1] in opts:
                args = sys.argv[2:]
                opts[sys.argv[1]](args)
        else:
                args = sys.argv[1:]
                search(args)
    else:
        list_tasks(None)

