# -*- ruby -*-

require 'rubygems'
require 'hoe'

Hoe.plugin :bundler
Hoe.plugin :test

Hoe.plugin :git
Hoe.plugin :gemspec
Hoe.plugin :version

Hoe.spec 'alfred-workflow' do

  developer 'Zhao Cai', 'caizhaoff@gmail.com'

  license 'GPL-3'



  testlib = :minitest
  extra_deps << ['plist', '~> 3.1.0']
  extra_deps << ['logging', '~> 1.8.0']

  # add rspce dep
end


%w{major minor patch}.each { |v| 
  desc "Bump #{v.capitalize} Version and Commit"
  task "bump:#{v}", [:message] => ["version:bump:#{v}"] do |t, args|
    m = args[:message] ? args[:message] :'Bump version to #{ENV["VERSION"]}'
    sh "git commit -am #{m}"
  end
}

# vim: syntax=ruby
