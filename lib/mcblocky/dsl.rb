module McBlocky
  module DSL
    def helper(*args, **kwargs, &block)
      context.helpers << [args, kwargs, block]
    end
  end
end
