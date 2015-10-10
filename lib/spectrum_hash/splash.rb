require 'net/http'

require 'rubygems'
require 'httparty'

module SpectrumHash
  class Splash
    attr_reader :spectrum, :spectrum_type, :api_uri, :response, :splash

    DEFAULT_SPLASH_API_URI = 'http://splash.fiehnlab.ucdavis.edu/splash/it'

    DEFAULT_SPECTRUM_TYPE = :ms
    SPECTRUM_TYPES = {ms: 1, nmr: 2, uv_vis: 3, ir: 4, raman: 5}.freeze

    def initialize(spectrum, options={})
      # options can be version or uri to use a different end point
      @spectrum      = spectrum
      @spectrum_type = options[:spectrum_type] || DEFAULT_SPECTRUM_TYPE
      @api_uri       = options[:uri]           || DEFAULT_SPLASH_API_URI

      fetch!
      # VALIDATE
    end

    RETRIES    = 3
    RETRY_WAIT = 0.1

    # TODO handle retries
    def fetch!
      @response = fetch_splash
      @splash = @response.body
    end

    def peak_list
      @peak_list ||= spectrum.map do |peak|
        {mass: peak.first, intensity: peak.last}
      end
    end

    def payload
      {
        ions: peak_list,
        type: spectrum_type.to_s.upcase
      }
    end

    def split_splash
      @split_splash ||= splash.split(/-/)
    end

    def version
      "1"
    end

    def version_block
      split_splash[0]
    end

    def histogram_block
      split_splash[1]
    end

    def hash_block
      split_splash[2]
    end

    private

    def fetch_splash
      HTTParty.post api_uri, body: payload.to_json, headers: { 'Content-Type' => 'application/json' }
    end

  end
end
