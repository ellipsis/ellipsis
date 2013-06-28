$:.unshift File.join(File.dirname(__FILE__), *%w[.. lib])

require "rspec"
require "alfred"

RSpec.configure do |c|
  c.color_enabled = true

  # Use color not only in STDOUT but also in pagers and files
  c.tty = true

  c.formatter = :documentation # :progress, :html, :textmate

  c.mock_with :rspec
end

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end
