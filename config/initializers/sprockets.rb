# This adds terser as a recognised compressor
# to Sprockets. Without this patch, Sprockets
# will not be able to run terser.
#
# Code originates from:
# https://stackoverflow.com/a/70086366

require "terser"

module Sprockets
  class Environment < Base
    def js_compressor=(compressor)
      register_compressor "application/javascript", :terser, Terser::Compressor
      super
    end
  end
end
