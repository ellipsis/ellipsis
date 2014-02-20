require "rexml/document"

module Alfred
  class Feedback
    class Item
      attr_accessor :uid, :arg, :valid, :autocomplete, :title, :subtitle, :icon, :type
      attr_accessor :order

      Default_Order = 256

      def initialize(title, opts = {})
        @title    = title
        @subtitle = opts[:subtitle] if opts[:subtitle]

        if opts[:icon]
          @icon    = opts[:icon]
        else
          @icon  ||= {:type => "default", :name => "icon.png"}
        end

        if opts[:uid]
          @uid    = opts[:uid]
        end

        if opts[:arg]
          @arg    = opts[:arg]
        else
          @arg  ||= @title
        end

        if opts[:type]
          @type    = opts[:type]
        else
          @type  ||= 'default'
        end

        if opts[:valid]
          @valid    = opts[:valid]
        else
          @valid  ||= 'yes'
        end

        if opts[:autocomplete]
          @autocomplete    = opts[:autocomplete]
        end

        if opts[:match?]
          @matcher   = opts[:match?].to_sym
        else
          @matcher ||= :title_match?
        end

        if opts[:order]
          @order = opts[:order]
        else
          @order = Default_Order
        end
      end


      # sort function
      def <=>(other)
        @order <=> other.order
      end

      
      ## To customize a new matcher?, define it.
      #
      # Module Alfred
      #   class Feedback
      #     class Item
      #       def your_match?(query)
      #         # define new matcher here
      #       end
      #     end
      #   end
      # end
      def match?(query)
        send(@matcher, query)
      end

      #
      # Matchers
      #
      def always_match?(query)
        true
      end

      def title_match?(query)
        return true if query.empty?
        if smartcase_query(query).match(@title)
          return true
        else
          return false
        end
      end

      def all_title_match?(query)
        return true if query.empty?
        if query.is_a? String
          query = query.split("\s")
        end

        queries = []
        query.each { |q|
          queries << smartcase_query(q)
        }

        queries.delete_if { |q|
          q.match(@title) or q.match(@subtitle)
        }

        if queries.empty?
          return true
        else
          return false
        end
      end


      def to_xml
        xml_element = REXML::Element.new('item')
        if @uid
          xml_element.add_attributes({
            'uid'          => @uid,
            'valid'        => @valid,
            'autocomplete' => @autocomplete
          })
        else
          xml_element.add_attributes({
            'valid'        => @valid,
            'autocomplete' => @autocomplete
          })

        end
        xml_element.add_attributes('type' => 'file') if @type == "file"

        REXML::Element.new("title", xml_element).text    = @title
        REXML::Element.new("arg", xml_element).text      = @arg
        REXML::Element.new("subtitle", xml_element).text = @subtitle

        icon = REXML::Element.new("icon", xml_element)
        icon.text = @icon[:name]
        icon.add_attributes('type' => 'fileicon') if @icon[:type] == "fileicon"

        xml_element
      end

      protected

      #
      # Regex helpers
      #
      def build_regexp(query, option)
        begin
          Regexp.compile(".*#{query.gsub(/\s+/,'.*')}.*", option)
        rescue RegexpError
          Regexp.compile(".*#{Regexp.escape(query)}.*", option)
        end
      end

      def smartcase_query(query)
        if query.is_a? Array
          query = query.join(" ")
        end
        option = Regexp::IGNORECASE
        if /[[:upper:]]/.match(query)
          option = nil
        end
        build_regexp(query, option)
      end

      def ignorecase_query(query)
        if query.is_a? Array
          query = query.join(" ")
        end
        option = Regexp::IGNORECASE
        build_regexp(query, option)
      end

      def default_query(query)
        if query.is_a? Array
          query = query.join(" ")
        end
        build_regexp(query, nil)
      end

    end
  end
end
