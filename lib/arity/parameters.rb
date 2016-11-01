module Arity
  class Parameters
    attr_reader :args, :opts

    def initialize
      @args = []
      @opts = {}
    end

    def append(*new_args)
      @args.concat(new_args)
      self
    end

    def merge(**new_opts)
      @opts.merge!(new_opts)
      self
    end

    def valid_for?(function)
      function.callable?(arg_count: args.size, keywords: opts.keys)
    end

  end
end
