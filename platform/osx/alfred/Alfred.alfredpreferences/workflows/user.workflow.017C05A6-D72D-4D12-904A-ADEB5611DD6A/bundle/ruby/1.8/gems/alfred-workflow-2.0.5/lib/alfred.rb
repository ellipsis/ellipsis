require 'rubygems' unless defined? Gem # rubygems is only needed in 1.8

require 'plist'
require 'fileutils'
require 'yaml'
require 'optparse'
require 'ostruct'
require 'gyoku'
require 'nori'

require 'alfred/ui'
require 'alfred/feedback'
require 'alfred/setting'
require 'alfred/handler/help'

module Alfred

  class AlfredError < RuntimeError
    def self.status_code(code)
      define_method(:status_code) { code }
    end
  end

  class ObjCError           < AlfredError; status_code(1) ; end
  class NoBundleIDError     < AlfredError; status_code(2) ; end
  class InvalidArgument     < AlfredError; status_code(10) ; end
  class InvalidFormat       < AlfredError; status_code(11) ; end
  class NoMethodError       < AlfredError; status_code(13) ; end
  class PathError           < AlfredError; status_code(14) ; end

  class << self

    #
    # Default entry point to build alfred workflow with this gem
    #
    # Example:
    #
    #    class MyHandler < ::Alfred::Handler::Base
    #      # ......
    #    end
    #    Alfred.with_friendly_error do |alfred|
    #      alfred.with_rescue_feedback = true
    #      alfred.with_help_feedback = true
    #      MyHandler.new(alfred).register
    #    end
    #
    def with_friendly_error(alfred_core = nil, &blk)
      begin
        if alfred_core.nil? or !alfred_core.is_a?(::Alfred::Core)
          alfred = Alfred::Core.new
        end
      rescue Exception => e
        log_file = File.expand_path("~/Library/Logs/Alfred-Workflow.log")
        rescue_feedback = %Q{
          <items>
            <item autocomplete="" uid="Rescue Feedback" valid="no">
              <title>Alfred Gem Fail to Initialize.</title>
              <arg>Alfred::NoBundleIDError: Wrong Bundle ID Test!</arg>
              <subtitle>Check log #{log_file} for extra debug info.</subtitle>
              <icon>/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/AlertStopIcon.icns</icon>
            </item>
            <item autocomplete="Alfred-Workflow.log" type="file" valid="yes">
              <title>Alfred-Workflow.log</title>
              <arg>#{log_file}</arg>
              <subtitle>#{log_file}</subtitle>
              <icon type="fileicon">/Applications/Utilities/Console.app</icon>
            </item>
          </items>
        }
        puts rescue_feedback

        File.open(log_file, "a+") do |log|
          log.puts "Alfred Gem Fail to Initialize.\n  #{e.message}"
          log.puts e.backtrace.join("  \n")
          log.flush
        end

        exit e.status_code
      end

      begin
        yield alfred
        alfred.start_handler

      rescue AlfredError => e
        alfred.ui.error e.message
        alfred.ui.debug e.backtrace.join("\n")
        puts alfred.rescue_feedback(
          :title => "#{e.class}: #{e.message}") if alfred.with_rescue_feedback
        exit e.status_code
      rescue Interrupt => e
        alfred.ui.error "\nQuitting..."
        alfred.ui.debug e.backtrace.join("\n")
        puts alfred.rescue_feedback(
          :title => "Interrupt: #{e.message}") if alfred.with_rescue_feedback
        exit 1
      rescue SystemExit => e
        puts alfred.rescue_feedback(
          :title => "SystemExit: #{e.status}") if alfred.with_rescue_feedback
        alfred.ui.error e.message
        alfred.ui.debug e.backtrace.join("\n")
        exit e.status
      rescue Exception => e
        alfred.ui.error(
          "A fatal error has occurred. " \
          "You may seek help in the Alfred supporting site, "\
          "forum or raise an issue in the bug tracking site.\n" \
          "  #{e.inspect}\n  #{e.backtrace.join("  \n")}\n")
        puts alfred.rescue_feedback(
          :title => "Fatal Error!") if alfred.with_rescue_feedback
          exit(-1)
      end
    end


    def workflow_folder
      Dir.pwd
    end


    # launch alfred with query
    def search(query = "")
      %x{osascript <<__APPLESCRIPT__
      tell application "Alfred 2"
        search "#{query.gsub('"','\"')}"
      end tell
__APPLESCRIPT__}
    end

    def front_appname
      %x{osascript <<__APPLESCRIPT__
      name of application (path to frontmost application as text)
__APPLESCRIPT__}.chop
    end

    def front_appid
      %x{osascript <<__APPLESCRIPT__
      id of application (path to frontmost application as text)
__APPLESCRIPT__}.chop
    end

  end

  class Core
    attr_accessor :with_rescue_feedback, :with_help_feedback
    attr_accessor :cached_feedback_reload_option

    attr_reader :handler_controller
    attr_reader :query, :raw_query


    def initialize(&blk)
      @with_rescue_feedback = true
      @with_help_feedback = false
      @cached_feedback_reload_option = {
        :use_reload_option => false,
        :use_exclamation_mark => false
      }

      @query = ARGV
      @raw_query = ARGV.dup

      @handler_controller = ::Alfred::Handler::Controller.new

      instance_eval(&blk) if block_given?

      raise NoBundleIDError unless bundle_id
    end


    def debug?
      ui.level >= LogUI::WARN
    end

    #
    # Main loop to work with handlers
    #
    def start_handler

      if @with_help_feedback
        ::Alfred::Handler::Help.new(self, :with_handler_help => true).register
      end

      return if @handler_controller.empty?

      # step 1: register option parser for handlers
      @handler_controller.each do |handler|
        handler.on_parser
      end

      begin
        query_parser.parse!
      rescue OptionParser::InvalidOption, OptionParser::MissingArgument => e
        ui.warn(
          "Fail to parse user query.\n" \
          "  #{e.inspect}\n  #{e.backtrace.join("  \n")}\n") if debug?
      end

      if @cached_feedback_reload_option[:use_exclamation_mark] && !options.should_reload_cached_feedback
        if ARGV[0].eql?('!')
          ARGV.shift
          options.should_reload_cached_feedback = true
        elsif ARGV[-1].eql?('!')
          ARGV.delete_at(-1)
          options.should_reload_cached_feedback = true
        end
      end

      @query = ARGV

      # step 2: dispatch options to handler for FEEDBACK or ACTION
      case options.workflow_mode
      when :feedback
        @handler_controller.each_handler do |handler|
          handler.on_feedback
        end

        puts feedback.to_alfred(@query)
      when :action
        arg = @query
        if @query.length == 1
          if hsh = xml_parser(@query[0])
            arg = hsh
          end
        end

        if arg.is_a?(Hash)
          @handler_controller.each_handler do |handler|
            handler.on_action(arg)
          end
        else
          #fallback default action
          arg.each do |a|
            if File.exist? a
              %x{open "#{a}"}
            end
          end
        end
      else
        raise InvalidArgument, "#{options.workflow_mode} mode is not supported."
      end

      # step 3: close
      close
      @handler_controller.each_handler do |handler|
        handler.on_close
      end

    end

    def close
      @feedback.close if @feedback
      @setting.close if @setting
      # @workflow_setting.close if @workflow_setting
    end


    #
    # User query without reload options 
    #
    def user_query
      q = @raw_query.dup

      if cached_feedback?
        if @cached_feedback_reload_option[:use_exclamation_mark] 
          if q[0].eql?('!')
            q.shift
          elsif q[-1].eql?('!')
            q.delete_at(-1)
          end
        end

        if @cached_feedback_reload_option[:use_reload_option]
          q.delete_if do |v|
            ['-r', '--reload'].include? v
          end
        end
      end

      q
    end

    #
    # Parse and return user query to three parts
    #
    #   [ [before], last option, tail ]
    #
    def last_option
      (@raw_query.size - 1).downto(0) do |i|
        if @raw_query[i].start_with? '-'
          if @raw_query[i] == @raw_query[-1]
            return @raw_query[0...i], '', @raw_query[i]
          else
            return @raw_query[0..i], @raw_query[i], @raw_query[(i + 1)..-1].join(' ')
          end
        end
      end

      return [], '', @raw_query.join(' ')
    end



    def options(opts = {})
      @options ||= OpenStruct.new(opts)
    end

    def query_parser
      @query_parser ||= init_query_parser
    end

    def xml_parser(xml)
      @xml_parser ||= Nori.new(:parser => :rexml,
                               :convert_tags_to => lambda { |tag| tag.to_sym })
      begin
        hsh = @xml_parser.parse(xml)
        return hsh[:root]
      rescue REXML::ParseException, Nokogiri::XML::SyntaxError
        return nil
      end
    end

    def xml_builder(arg)
      Gyoku.xml(:root => arg)
    end

    def ui
      @ui ||= LogUI.new(bundle_id)
    end


    #
    # workflow setting is stored in the workflow_folder
    #
    def workflow_setting(opts = {})
      @workflow_setting ||= new_setting(opts)
    end

    #
    # user setting is stored in the storage_path by default
    #
    def user_setting(&blk)
      @setting ||= new_setting(
        :file => File.join(storage_path, "setting.yaml")
      )
    end
    alias_method :setting, :user_setting


    def feedback(opts = {}, &blk)
      @feedback ||= new_feedback(opts, &blk)
    end

    alias_method :with_cached_feedback, :feedback

    def info_plist
      @info_plist ||= Plist::parse_xml('info.plist')
    end

    # Returns nil if not set.
    def bundle_id
      @bundle_id ||= info_plist['bundleid'] unless info_plist['bundleid'].empty?
    end

    def volatile_storage_path
      path = "#{ENV['HOME']}/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/#{bundle_id}"
      unless File.directory?(path)
        FileUtils.mkdir_p(path)
      end
      path
    end

    # Non-volatile storage directory for this bundle
    def storage_path
      path = "#{ENV['HOME']}/Library/Application Support/Alfred 2/Workflow Data/#{bundle_id}"
      unless File.exist?(path)
        FileUtils.mkdir_p(path)
      end
      path
    end


    def cached_feedback?
      @cached_feedback_reload_option.values.any?
    end


    def rescue_feedback(opts = {})
      default_opts = {
        :title        => "Failed Query!"                                  ,
        :subtitle     => "Check log #{ui.log_file} for extra debug info." ,
        :uid          => 'Rescue Feedback'                                ,
        :valid        => 'no'                                             ,
        :autocomplete => ''                                               ,
        :icon         => Feedback.CoreServicesIcon('AlertStopIcon')
      }
      if @with_help_feedback
       default_opts[:autocomplete] = '-h'
      end
      opts = default_opts.update(opts)

      items = []
      items << Feedback::Item.new(opts[:title], opts)
      log_item = Feedback::FileItem.new(ui.log_file)
      log_item.uid = nil
      items << log_item

      feedback.to_alfred('', items)
    end

    def on_help
      reload_help_item
    end


    def new_feedback(opts, &blk)
      ::Alfred::Feedback.new(self, opts, &blk)
    end


    def new_setting(opts)
      default_opts = {
        :file    => File.join(Alfred.workflow_folder, "setting.yaml"),
        :format  => 'yaml',
      }
      opts = default_opts.update(opts)

      ::Alfred::Setting.new(self) do
        @backend_file = opts[:file]
        @formt = opts[:format]
      end
    end

    private

    def reload_help_item
      title = []
      if @cached_feedback_reload_option[:use_exclamation_mark]
        title.push "!"
      end

      if @cached_feedback_reload_option[:use_reload_option]
        title.push "-r, --reload"
      end

      unless title.empty?
        return {
          :kind  => 'text',
          :order => (Handler::HelpItem::Base_Order * 10),
          :title => "#{title.join(', ')} [Reload cached feedback unconditionally]" ,
          :subtitle => %q{The '!' mark must be at the beginning or end of the query.} ,
        }
      else
        return nil
      end
    end

    def init_query_parser
      options.workflow_mode = :feedback
      options.modifier = :none
      options.should_reload_cached_feedback = false

      modifiers = [:command, :alt, :control, :shift, :fn, :none]
      OptionParser.new do |opts|
        opts.separator ""
        opts.separator "Built-in Options:"

        opts.on("--workflow-mode [TYPE]", [:feedback, :action],
                "Alfred handler working mode (feedback, action)") do |t|
          options.workflow_mode = t
        end

        opts.on("--modifier [MODIFIER]", modifiers,
                "Alfred action modifier (#{modifiers})") do |t|
          options.modifier = t
        end

        if @cached_feedback_reload_option[:use_reload_option]
          opts.on("-r", "--reload", "Reload cached feedback") do
            options.should_reload_cached_feedback = true
          end
        end
        opts.separator ""
        opts.separator "Handler Options:"
      end

    end
  end
end

