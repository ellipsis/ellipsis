module Alfred
  module OSX

    class << self

      def version
        @version ||= get_osx_version
      end

      def version_number
        "#{version[:major]}.#{version[:minor]}"
      end

      def notification_center?
        version[:major] >= 10.8
      end


      def full_name
        "Mac OS X " + version_number
      end


      def short_name
        case version[:major]
        when 10.4
          short_name = "Tiger"
        when 10.5
          short_name = "Leopard"
        when 10.6
          short_name = "Snow Leopard"
        when 10.7
          short_name = "Lion"
        when 10.8
          short_name = "Mountain Lion"
        when 10.9
          short_name = "Mavericks"
        end

        return short_name
      end


      private

      def get_osx_version
        begin
          version = %x{/usr/bin/sw_vers -productVersion}.chop
        rescue Errno::ENOENT => e
          raise Errno::ENOENT, "This computer is not running Mac OS X becasue #{e.message}"
        end

        segments = version.split('.')[0,3].map!{|p| p.to_i}
        {
          :major => "#{segments[0]}.#{segments[1]}".to_f,
          :minor => segments[2],
        }
      end

    end
  end
end

