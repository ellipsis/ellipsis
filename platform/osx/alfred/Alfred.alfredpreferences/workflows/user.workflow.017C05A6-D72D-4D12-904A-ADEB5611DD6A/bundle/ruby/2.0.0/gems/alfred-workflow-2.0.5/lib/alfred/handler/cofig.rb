module Alfred::Handler

  class Config < Base
    def initialize(alfred, opts = {})
      super
      @order = 20
      @settings = {
        :setting => alfred.workflow_setting ,
        :break?  => true                    ,
        :handler => 'Config'
      }.update(opts)

    end

    def on_parser
      opts.on("-c", "--config CONFIG", "Config Workflow Settings") do |v|
        options.config = v
      end
    end

    def on_help
      {
        :kind     => 'text'                     ,
        :title    => '-c, --config [query]'     ,
        :subtitle => 'Config Workflow Settings' ,
      }
    end

    def on_feedback
    end

  end
end
