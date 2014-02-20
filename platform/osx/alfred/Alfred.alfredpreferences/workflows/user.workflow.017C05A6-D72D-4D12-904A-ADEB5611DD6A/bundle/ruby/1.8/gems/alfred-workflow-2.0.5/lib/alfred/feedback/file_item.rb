require "rexml/document"
require "alfred/feedback/item"

module Alfred
  class Feedback
    class FileItem < Item

      def initialize(path, opts = {})
        if opts[:title]
          @title = opts[:title]
        elsif ['.ennote', '.webbookmark', '.vcf', '.abcdp', '.olk14Contact'].include? File.extname(path)
          @title = %x{/usr/bin/mdls -name kMDItemDisplayName -raw '#{path}'}
        else
          @title = File.basename(path)
        end
        @subtitle = path
        @uid = path
        @arg = path
        @icon = {:type => "fileicon", :name => path}
        @valid = 'yes'
        @autocomplete = @title
        @type = 'file'

        super @title, opts
      end

    end
  end
end

