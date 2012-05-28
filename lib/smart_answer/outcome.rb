module SmartAnswer
  class Outcome < Node
    def outcome?
      true
    end

    def transition(*args)
      raise InvalidNode
    end

    def places(slug, options = {})
      @imminence_slug = slug
      @limit = options[:limit] || 3
    end

    def load_places(geostack)
      @locations ||= places_from_imminence(geostack)
    end

    def places_from_imminence(geostack = {})
      if @imminence_slug and geostack
        geostack = geostack.symbolize_keys
        imminence_api.places(@imminence_slug, geostack[:fuzzy_point]['lat'], geostack[:fuzzy_point]['lon'], @limit)
      else
        false
      end
    end

    def contact_list(symbol)
      @contact_list = symbol
    end

    def contact_list_sym
      @contact_list
    end
  end
end
