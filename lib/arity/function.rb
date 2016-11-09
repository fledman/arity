module Arity
  class Function
    attr_reader :callable

    def self.make(fn, silent: false)
      return new(fn) if fn.respond_to?(:call)
      return if silent
      raise NotCallableError, "function is not callable: #{fn.inspect}"
    end

    private def initialize(fn)
      @callable = unwrap_function(fn)
    end

    def arity
      callable.arity
    end

    def signature
      @signature ||= compute_signature
    end

    def takes?(arg_count:, keywords:)
      bad_param('arg_count', 'an int', arg_count) if !arg_count.is_a?(Integer)
      bad_param('keywords', 'an array', keywords) if !keywords.is_a?(Array)

      return false if arg_count < signature[:min_args]

      if signature[:max_args] > -1
        return false if arg_count > signature[:max_args]
      end

      missing = signature[:required_keys] - keywords
      return false if !missing.empty?

      return true if signature[:any_key]

      extra_keys = keywords - signature[:required_keys] \
                            - signature[:optional_keys]
      extra_keys.empty?
    end

    def runnable?(*args, **opts)
      takes?(arg_count: args.size, keywords: opts.keys)
    end

    def run(*args, **opts)
      args.push(opts) unless opts.empty?
      callable.call(*args)
    end

    private

    def unwrap_function(fn)
      fn.respond_to?(:arity) ? fn : fn.method(:call)
    end

    def unknown_parameter_type!(type, name)
      raise UnknownParameterTypeError,
        "type #{type.inspect} for parameter #{name.inspect}"
    end

    def bad_param(name, type, value)
      raise ArgumentError, "#{name} must be #{type}, got: #{value.inspect}"
    end

    def compute_signature
      splat = false
      { min_args: 0,
        max_args: 0,
        required_keys: [],
        optional_keys: [],
        any_key: false
      }.tap do |signature|
        callable.parameters.each do |type,name|
          case type
          when :req
            signature[:min_args] += 1
            signature[:max_args] += 1
          when :opt
            signature[:max_args] += 1
          when :rest
            splat = true
          when :key
            signature[:optional_keys] << name
          when :keyreq
            signature[:required_keys] << name
          when :keyrest
            signature[:any_key] = true
          else
            unknown_parameter_type!(type, name)
          end
        end
        signature[:max_args] = -1 if splat
        signature[:required_keys].freeze
        signature[:optional_keys].freeze
      end.freeze
    end

  end
end
