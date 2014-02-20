require 'moneta'
require 'alfred/util'

#
# = Alfred Callback Hander
#
# Each callback is stored using Moneta via YAML backend.!
#
# == Example:
#   Suppose we have a callback with key "demo"
#
# - @backend[ENTRIES_KEY] => {
#   'demo' => {:key => 'demo', :title => 'title', :subtitle => ...}
# }
#
# - @backend['demo'] => the feedback items
#
module Alfred::Handler

  class Callback < Base
    ENTRIES_KEY = 'feedback_entries'

    def initialize(alfred, opts = {})
      super
      @settings = {
        :handler       => 'Callback'                  ,
        :exclusive?    => true                        ,
        :backend_dir   => @core.volatile_storage_path ,
        :backend_file  => 'callback.yaml'             ,
        :handler_order => ( Base_Invoke_Order / 12 )
      }.update(opts)

      @order = @settings[:handler_order]
    end


    def on_parser
      parser.on("--callback [CALLBACK]", "Alfred callback feedback") do |v|
        options.callback = v || ''
      end
    end

    def feedback?
      options.callback
    end

    def on_feedback
      return unless feedback?
      if entries[options.callback]
        feedback.merge! backend[options.callback]
        @status = :exclusive if @settings[:exclusive?]

      elsif entries.empty?
        # show a warn feedback item
        feedback.add_item(
          {
            :title        => 'No available callback!' ,
            :valid        => 'no'                     ,
            :autocomplete => ''                       ,
            :subtitle     => 'Please check it later. Background task may still be running.',
            :icon         => ::Alfred::Feedback.CoreServicesIcon('Unsupported') ,
          }
        )
      else
        # list available callbacks
        entries.each do |key, entry|
          feedback.add_item(
            {
              :title        => "Feedback Callback: #{key}" ,
              :subtitle     => "#{entry[:timestamp]}",
              :valid        => 'no'                        ,
              :autocomplete => "--callback '#{key}'"       ,
              :icon         => ::Alfred::Feedback.CoreServicesIcon('AliasBadgeIcon') ,
            }.merge(entry)
          )
        end
        @status = :exclusive if @settings[:exclusive?]
      end
    end


    def on_close
      backend.close
    end


    def on_callback(keyword, entry, feedback_items)
      add_entry(entry, feedback_items)
      Alfred::Util.notify("#{keyword} --callback '#{entry[:key]}'",
                          entry[:title] || entry[:key],
                          entry)
    end


    def add_entry(entry, feedback_items)
      entry.merge!(:timestamp => Time.now)
      key = entry[:key]
      new_entries = entries.merge(key => entry)
      backend[ENTRIES_KEY] = new_entries
      backend[key] = feedback_items
    end

    def remove_entry(key)
      new_entries = entries.delete(key)
      backend[ENTRIES_KEY] = new_entries
      backend.delete(key)
    end



    def entries
      backend[ENTRIES_KEY]
    end


    def backend
      @backend ||= Moneta.new(:YAML,
                              :file => File.join(@settings[:backend_dir],
                                                 @settings[:backend_file]))

      unless @backend.key?(ENTRIES_KEY)
        @backend[ENTRIES_KEY] = {}
      end
      @backend
    end

    private

  end
end
