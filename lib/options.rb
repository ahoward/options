module Options
  VERSION = '2.0.0'

  class << Options
    def version
      Options::VERSION
    end

    def normalize!(hash)
      hash.keys.each{|key| hash[key.to_s.to_sym] = hash.delete(key) unless Symbol===key}
      hash
    end
    alias_method 'to_options!', 'normalize!'

    def normalize(hash)
      normalize!(hash.dup)
    end
    alias_method 'to_options', 'normalize'

    def stringify!(hash)
      hash.keys.each{|key| hash[key.to_s] = hash.delete(key) unless String===key}
      hash
    end
    alias_method 'stringified!', 'stringify!'

    def stringify(hash)
      stringify!(hash)
    end
    alias_method 'stringified', 'stringify'

    def for(hash)
      hash =
        case hash
          when Hash
            hash
          when Array
            Hash[*hash.flatten]
          when String, Symbol
            {hash => true}
          else
            hash.to_hash
        end
      normalize!(hash)
    ensure
      hash.extend(Options) unless hash.is_a?(Options)
    end

    def parse(args)
      case args
      when Array
        args.extend(Arguments) unless args.is_a?(Arguments)
        args.options.pop
      when Hash
        Options.for(args)
      else
        raise ArgumentError, "`args` should be and Array or Hash"
      end
    end
  end

  def to_options!
    replace to_options
  end

  def to_options
    keys.inject(Hash.new){|h,k| h.update k.to_s.to_sym => fetch(k)}
  end
        
  def getopt key, default = nil
    [ key ].flatten.each do |key|
      return fetch(key) if has_key?(key)
      key = key.to_s
      return fetch(key) if has_key?(key)
      key = key.to_sym
      return fetch(key) if has_key?(key)
    end
    default
  end

  def getopts *args
    args.flatten.map{|arg| getopt arg}
  end

  def hasopt key, default = nil
    [ key ].flatten.each do |key|
      return true if has_key?(key)
      key = key.to_s
      return true if has_key?(key)
      key = key.to_sym
      return true if has_key?(key)
    end
    default
  end
  alias_method 'hasopt?', 'hasopt'

  def hasopts *args
    args.flatten.map{|arg| hasopt arg}
  end
  alias_method 'hasopts?', 'hasopts'

  def delopt key, default = nil
    [ key ].flatten.each do |key|
      return delete(key) if has_key?(key)
      key = key.to_s
      return delete(key) if has_key?(key)
      key = key.to_sym
      return delete(key) if has_key?(key)
    end
    default
  end

  def delopts *args
    args.flatten.map{|arg| delopt arg}
  end

  def setopt key, value = nil
    [ key ].flatten.each do |key|
      return self[key]=value if has_key?(key)
      key = key.to_s
      return self[key]=value if has_key?(key)
      key = key.to_sym
      return self[key]=value if has_key?(key)
    end
    return self[key]=value
  end
  alias_method 'setopt!', 'setopt'

  def setopts opts 
    opts.each{|key, value| setopt key, value}
    opts
  end
  alias_method 'setopts!', 'setopts'

  def select! *a, &b
    replace select(*a, &b).to_hash
  end

  def normalize!
    Options.normalize!(self)
  end
  alias_method 'normalized!', 'normalize!'
  alias_method 'to_options!', 'normalize!'

  def normalize
    Options.normalize(self)
  end
  alias_method 'normalized', 'normalize'
  alias_method 'to_options', 'normalize'

  def stringify!
    Options.stringify!(self)
  end
  alias_method 'stringified!', 'stringify!'

  def stringify
    Options.stringify(self)
  end
  alias_method 'stringified', 'stringify'

  attr_accessor :arguments
  def pop
    pop! unless popped?
    self
  end

  def popped?
    defined?(@popped) and @popped
  end

  def pop!
    @popped = arguments.pop
  end

  # Validates that the options provided are acceptable.
  #
  # @param [Enumerable, Hash] options_descriptor Either a list of options that are
  #   allowed or a hash with a `:required` key whose value is a list
  #   of options that are required and key `:optional` whose value is
  #   a list of options that are acceptable but not required.
  def validate(options_descriptor)
    validate_acceptable(options_descriptor)
    validate_required(options_descriptor)
  end

  protected

  def validate_acceptable(options_desc)
    acceptable = if Hash === options_desc
                   options_desc[:required] + options_desc[:optional]
                 else
                   options_desc
                 end

    remaining = (provided_options - acceptable)
    raise ArgumentError, "Unrecognized options: #{remaining.join(', ')}" unless remaining.empty?
  end
  
  def validate_required(options_desc)
    return unless Hash === options_desc

    missing_required = Array(options_desc[:required]) - provided_options
    raise ArgumentError, "Required options are missing: #{missing_required.join(', ')}" unless missing_required.empty?
  end

  def provided_options
    @provided_options ||= normalize!.keys
  end
end

module Arguments
  def options
    @options ||= Options.for(last.is_a?(Hash) ? last : {})
  ensure
    @options.arguments = self
  end

  class << Arguments
    def for(args)
      args.extend(Arguments) unless args.is_a?(Arguments)
      args
    end

    def parse(args)
      [args, Options.parse(args)]
    end
  end
end

class Array
  def options
    extend(Arguments) unless is_a?(Arguments)
    options
  end
end
