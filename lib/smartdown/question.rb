module Smartdown
  class Question < Node

    def has_hint?
      !!hint
    end

    # Usage TBC, most hints should actually be `body`s, semi-deprecated
    # As we transition content we should better define it, or remove it
    def hint
    end

    def prefix
      "prefix not currently possible"
    end

    def suffix
      "suffix not currently possible"
    end

    def subtitle
      "subtitle not currently possible"
    end

    #TODO: when error handling
    def error
    end

    #TODO
    def responses
    end

  end
end
