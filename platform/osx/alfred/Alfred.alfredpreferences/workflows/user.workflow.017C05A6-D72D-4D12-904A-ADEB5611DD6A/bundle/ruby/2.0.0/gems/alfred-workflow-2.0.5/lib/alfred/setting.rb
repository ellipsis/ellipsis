require 'yaml'

module Alfred

  class Setting
    attr_accessor :backend_file
    attr_reader :format

    def initialize(alfred, &block)
      @core = alfred
      @table = {}

      instance_eval(&block) if block_given?

      @format ||= "yaml"
      @backend_file ||= File.join(@core.storage_path, "setting.#{@format}")

      raise InvalidFormat, "#{format} is not suported." unless validate_format

      unless File.exist?(@backend_file)
        @table.merge!({:id => @core.bundle_id})
        dump(:flush => true)
      else
        load
      end
    end


    def validate_format
      ['yaml'].include?(format)
    end


    def load
      send("load_from_#{format}".to_sym)
    end


    def dump(opts = {})
      send("dump_to_#{format}".to_sym, opts)
    end

    alias_method :close, :dump

    #
    # Provides yaml serialization support
    #
    if RUBY_VERSION < "1.9"
      def to_yaml_properties
        [ '@table' ]
      end
    else
      def encode_with(coder)
        coder['table'] = @table
      end
    end

    #
    # Provides marshalling support for use by the Marshal library.
    #
    def marshal_dump
      @table
    end

    #
    # Provides marshalling support for use by the Marshal library.
    #
    def marshal_load(x)
      @table.merge! x
    end
    #
    # Converts to hash
    #
    def to_h
      @table.dup
    end

    def each_pair
      return to_enum __method__ unless block_given?
      @table.each_pair{|p| yield p}
    end


    def [](name)
      @table[name]
    end

    #
    # Sets the value of a member.
    #
    #   person = Alfred::Setting.new('name' => 'John Smith', 'age' => 70)
    #   person[:age] = 42
    #
    def []=(name, value)
      @table[name] = value
    end

    def has_key?(key)
      @table.has_key?(key)
    end
    alias_method :key?, :has_key?


    def ==(other)
      return false unless other.kind_of?(Alfred::Setting)
      @table == other.table
    end

    def eql?(other)
      return false unless other.kind_of?(Alfred::Setting)
      @table.eql?(other.table)
    end

    attr_reader :table # :nodoc:
    protected :table


    #
    # Send missing method to @table to mimic a hash
    #
    def method_missing (name, *args, &block) # :nodoc:
      @table.send(name, *args, &block)
    end

    protected

    def load_from_yaml
      @table.merge!(YAML::load_file(@backend_file))
    end

    def dump_to_yaml(opts = {})
      File.open(@backend_file, File::WRONLY|File::TRUNC|File::CREAT) { |f|
        YAML::dump(@table, f)
        f.flush if opts[:flush]
      }
    end

  end
end


