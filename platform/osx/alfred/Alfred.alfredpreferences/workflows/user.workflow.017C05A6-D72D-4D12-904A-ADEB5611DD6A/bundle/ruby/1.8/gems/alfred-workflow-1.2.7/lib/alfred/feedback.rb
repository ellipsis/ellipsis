require "rexml/document"
require 'alfred/feedback/item'
require 'alfred/feedback/file_item'

module Alfred

  class Feedback
    attr_accessor :items

    def initialize
      @items = []
    end

    def add_item(opts = {})
      raise ArgumentError, "Feedback item must have title!" if opts[:title].nil?
      @items << Item.new(opts[:title], opts)
    end

    def add_file_item(path)
      @items << FileItem.new(path)
    end

    def to_xml(with_query = '', items = @items)
      document = REXML::Element.new("items")
      items.each do |item|
        document << item.to_xml if item.match?(with_query)
      end
      document.to_s
    end

    alias_method :to_alfred, :to_xml

  end

end
