require "alfred/feedback/file_item"
require 'alfred/util'

module Alfred
  class Feedback
    class WeblocItem < FileItem

      def initialize(title, opts = {})
        unless File.exist? opts[:webloc]
          opts[:webloc] = ::Alfred::Util.make_webloc(
            opts[:title], opts[:url], opts[:folder])
        end

        @subtitle = opts[:url]
        @uid = opts[:url]

        super title, opts
      end

    end
  end
end

