require 'uri'
require 'terminal-notifier'
require 'alfred/osx'

class String
  def strip_heredoc
    indent = scan(/^[ \t]*(?=\S)/).min.size || 0
    gsub(/^[ \t]{#{indent}}/, '')
  end
end

module Alfred

  module Util

    class << self
      # escape text for use in an AppleScript string
      def escape_applescript(str)
        str.to_s.gsub(/(?=["\\])/, '\\')
      end

      def make_webloc(name, url, folder=nil, comment = '')
        date = Time.now.strftime("%m-%d-%Y %I:%M%p")
        folder = Alfred.workflow_folder unless folder
        folder, name, url, comment = [folder, name, url, comment].map do |t|
          escape_applescript(t)
        end

        return %x{
        osascript << __APPLESCRIPT__
        tell application "Finder"
            set webloc to make new internet location file at (POSIX file "#{folder}") ¬
            to "#{url}" with properties ¬
            {name:"#{name}",creation date:(AppleScript's date "#{date}"), ¬
            comment:"#{comment}"}
        end tell
        return POSIX path of (webloc as string)
__APPLESCRIPT__}
      end


      def open_url(url)
        uri = URI.parse(url)
        %x{/usr/bin/open #{uri.to_s}}
      end

      def google(query)
        open_url %Q{http://www.google.com/search?as_q=#{URI.escape(query)}&lr=lang_}
      end

      def open_with(app, path)
        %x{osascript <<__APPLESCRIPT__
        tell application "#{app}"
            try
                open "#{path}"
                activate
            on error err_msg number err_num
                return err_msg
            end try
        end tell
__APPLESCRIPT__}
      end

      def reveal_in_finder(path)
        raise InvalidArgument, "#{path} does not exist." unless File.exist? path
        %x{osascript <<__APPLESCRIPT__
        tell application "Finder"
            try
                reveal POSIX file "#{path}"
                activate
            on error err_msg number err_num
                return err_msg
            end try
        end tell
__APPLESCRIPT__}
      end


      def search_command(query = '')
        %Q{osascript <<__APPLESCRIPT__
      tell application "Alfred 2"
        search "#{escape_applescript(query)}"
      end tell
__APPLESCRIPT__}
      end


      def notify(query, message, opts = {})
        if Alfred::OSX.notification_center?
          notifier_options = {
            :title   => 'Alfred Notification'             ,
            :sound   => 'default'                         ,
            :execute => search_command(query)             ,
          }.merge!(opts)
          p notifier_options
          TerminalNotifier.notify(message, notifier_options)
        else
          system search_command(query)
        end
      end

    end
  end

end
