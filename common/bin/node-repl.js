#!/usr/bin/env node
var repl = require('repl').start('> ')
var context = repl.context

String.prototype.format = function(i, safe, arg) {
  function format() {
    var str = this, len = arguments.length+1

    // For each {0} {1} {n...} replace with the argument in that position. If
    // the argument is an object or an array it will be stringified to JSON.
    for (i=0; i < len; arg = arguments[i++]) {
      safe = typeof arg === 'object' ? JSON.stringify(arg) : arg
      str = str.replace(RegExp('\\{'+(i-1)+'\\}', 'g'), safe)
    }
    return str
  }

  // Save a reference of what may already exist under the property native.
  // Allows for doing something like: if("".format.native) { /* use native */ }
  format.native = String.prototype.format

  // Replace the prototype property
  return format
}()
context.format = String.prototype.format

// Addition REPL commands
repl.defineCommand('hi', function() {
  this.outputStream.write('hello!\n')
  this.displayPrompt()
})

repl.defineCommand('self', {
  help: 'sets self to this',
  action: function() {
    this.context.self = this
    this.displayPrompt()
  }
})

repl.defineCommand('time', {
  help: 'time an expression',
  action: function() {

    // process arguments
    var args = this.rli.history[0].split(' ')
    var times = args[1], expression = args.slice(2).join(' ')

    // Pull context into scope
    Object.keys(context).filter(function(e, i){ return i > 9 }).forEach(function(name) {
      eval(name + ' = context.' + name )
    })

    try {
      // build func to test from expression
      var func = eval('(function() { return {0}; });'.format(expression))

      // start timer
      var start = new Date().getTime()
      for (var i=0; i < times; ++i) {
        func()
      }
      // end timer
      var end = new Date().getTime()
    } catch(e) {
      console.log(e.stack)
      this.displayPrompt()
      return false
    }
    var time = end - start
    console.log('Execution time: {0} ms'.format(time))
    this.displayPrompt()
  }
})

context.fs = require('fs')
context.http = require('http') 
context.sys = require('sys')
context.util = require('util')

context.sum = function(array) {
  return Array.prototype.reduce.call(array, function (x,y) {
    return x + y
  })
}

context.range = function (start, stop) {
  var array = []
  while (start <= stop) {
    array.push(start)
    start++
  }
  return array
}

context.oc = function oc(a) {
  var o = {}
  for(var i=0; i<a.length; i++) {
    o[a[i]] = ''
  }
  return o
}

context.print = console.log
context.dir = console.dir
context.inspect = context.util.inspect
