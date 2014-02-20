require 'alfred/handler'


module Alfred
  module Handler

    class HelpItem < ::Hash
      Base_Order = 10
      def initialize(attributes = {}, &block)
        super(&block)
        initialize_attributes(attributes)
      end

      def <=>(other)
        self[:order] <=> other[:order]
      end

      private

      def initialize_attributes(attributes)
        attributes.each_pair do |att, value|
          self[att] = value
        end if attributes
        self[:order] = Base_Order unless self[:order]
      end
    end


    class Help < Base
      def initialize(alfred, opts = {})
        super
        @settings = {
          :handler           => 'Help'                     ,
          :exclusive?        => true                       ,
          :with_handler_help => true                       ,
          :items             => []                         ,
          :handler_order     => ( Base_Invoke_Order / 10 )
        }.update(opts)

        @order = @settings[:handler_order]

        if @settings[:items].empty?
          @load_from_workflow_setting = true
        else
          @load_from_workflow_setting = false
        end

      end

      def on_parser
        parser.on_tail('-?', '-h', '--help', 'Workflow Helper') do
          options.help = true
        end
      end

      def on_help
        {
          :kind         => 'text'                      ,
          :valid        => 'no'                        ,
          :autocomplete => '-h'                        ,
          :match?       => :always_match?              ,
          :order        => (HelpItem::Base_Order * 12) ,
          :title        => '-?, -h, --help [Show Workflow Usage Help]' ,
          :subtitle     => 'Other feedbacks are blocked.'              ,
        }
      end

      def feedback?
        options.help
      end

      def on_feedback
        return unless feedback?

        if @settings[:with_handler_help]
          @settings[:items].push @core.on_help
          @core.handler_controller.each do |h|
            @settings[:items].push h.on_help
          end
        end

        if @load_from_workflow_setting
          if @core.workflow_setting.has_key?(:help)
            @settings[:items].push @core.workflow_setting[:help]
          end
        end

        @settings[:items].flatten!.compact!
        @settings[:items].map! { |i| HelpItem.new(i) }.sort!

        @settings[:items].each do |item|

          case item[:kind]
          when 'file'
            item[:path] = File.expand_path(item[:path])
            # action is handled by fallback action in the main loop
            feedback.add_file_item(item[:path], item)
          when 'url'
            item[:arg] = xml_builder(
              :handler => @settings[:handler] ,
              :kind    => item[:kind]         ,
              :url     => item[:url]
            )

            feedback.add_item(
              {
                :icon => ::Alfred::Feedback.CoreServicesIcon('BookmarkIcon')
              }.merge(item)
            )

          when 'text', 'message'
            item[:arg] = xml_builder(
              {
                :handler      => @settings[:handler] ,
                :kind         => item[:kind]         ,
              }
            )

            feedback.add_item(
              {
                :valid        => 'no' ,
                :autocomplete => ''   ,
                :icon         => ::Alfred::Feedback.CoreServicesIcon('ClippingText') ,
              }.merge(item)
            )

          else
            if item.has_key? :title
              item[:arg] = xml_builder(
                {
                  :handler => @settings[:handler] ,
                  :kind    => item[:kind]         ,
                }.merge(item)
              )

              feedback.add_item(
                {
                  :icon => ::Alfred::Feedback.CoreServicesIcon('HelpIcon'),
                }.merge(item)
              )
            end
          end
        end

        @status = :exclusive if @settings[:exclusive?]
      end


      def on_action(arg)
        return unless action?(arg)

        case arg[:kind]
        when 'url'
          ::Alfred::Util.open_url(arg[:url])
        when 'file'
          %x{open "#{arg[:path]}"}
        end
      end
    end

  end
end
