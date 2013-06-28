# alfred-workflow

* home  :: https://github.com/zhaocai/alfred-workflow
* rdoc  :: http://rubydoc.info/gems/alfred-workflow/
* code  :: https://github.com/zhaocai/alfred-workflow
* bugs  :: https://github.com/zhaocai/alfred-workflow/issues


## DESCRIPTION:

alfred-workflow is a ruby Gem helper for building [Alfred](http://www.alfredapp.com) workflow.


## FEATURES:

* Use standard [bundler][gembundler] to easily package, manage, and update ruby gems in the workflow.
* Friendly exception and debug output to the Mac OS X Console.
* Automate rescue feedback items to alfred when something goes wrong.
* Functions for smart case query filter of feedback results.
* Functions for finding the bundle ID, cache and storage paths, and query arguments.
* Functions for reading and writing plist files.
* Functions to simplify generating feedback XML for Alfred.
* Functions to simplify saving and retrieving settings.

## SYNOPSIS:

```ruby
require 'rubygems' unless defined? Gem
require "bundle/bundler/setup"
require "alfred"

Alfred.with_friendly_error do |alfred|
  fb = alfred.feedback

  fb.add_file_item(File.expand_path "~/Applications/")

  puts fb.to_alfred(ARGV)
end
```

Code are wrapped in `Alfred.with_friendly_error` block. Exceptions and debug messages are logged to Console log file **~/Library/Logs/Alfred-Workflow.log**.

## INSTALL:

`gem install alfred-workflow`

## USAGE:

* Refer to [alfred2-ruby-template]( https://github.com/zhaocai/alfred2-ruby-template ) for example and detailed instruction.


## Example Projects

* [alfred2_top_workflow]( https://github.com/zhaocai/alfred2-top-workflow )


## DEVELOPERS:

After checking out the source, run:

  $ rake newb

This task will install any missing dependencies, run the tests/specs,
and generate the RDoc.

## LICENSE:

Copyright (c) 2013 Zhao Cai <caizhaoff@gmail.com>

This program is free software: you can redistribute it and/or modify it under
the terms of the GNU General Public License as published by the Free Software
Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with
this program. If not, see <http://www.gnu.org/licenses/>.


[gembundler]: http://gembundler.com/
[alfredapp]: http://www.alfredapp.com
