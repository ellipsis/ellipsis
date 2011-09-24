begin
  # load wirble
  require 'rubygems'
  require 'irb/completion'

  if IRB.version.include?('DietRB')
    require 'irb/ext/colorize'
  else
    require 'wirble'
    Wirble.init
    Wirble.colorize
  end

  IRB.conf[:AUTO_INDENT] = true 

class Object
  # get all the methods for an object that aren't basic methods from Object
  def local_methods
    (methods - Object.instance_methods).sort
  end
end 
rescue LoadError => err
  warn "Couldn't load Wirble: #{err}"
end
