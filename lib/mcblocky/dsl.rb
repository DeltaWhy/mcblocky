module McBlocky
  module DSL
    def helper(*command, &block)
      context.helpers << [command, block]
    end
  end
end
