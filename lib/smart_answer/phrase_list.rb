module SmartAnswer
  class PhraseList

    attr_accessor :phrase_keys

    def initialize(*phrase_keys)
      @phrase_keys = phrase_keys
    end

    def +(phrase_key)
      PhraseList.new( *phrase_keys + [ phrase_key ] )
    end

    def <<(phrase_key)
      phrase_keys << phrase_key
      self
    end
  end
end
