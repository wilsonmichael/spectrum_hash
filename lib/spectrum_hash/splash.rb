module SpectrumHash
  class Splash
    PRECISION = 6;
    EPS = 1.0e-6;

    SPLASH_VERSION = 0

    # Value to scale relative spectra
    RELATIVE_INTENSITY_SCALE = 1000.0

    # Separator for building spectrum strings
    PEAK_SEPARATOR = ' '

    # Full spectrum hash properties
    PEAK_PAIR_SEPARATOR = ':'
    MAX_HASH_CHARACTERS_FULL_SPECTRUM = 20

    # Top ions block properties
    MAX_TOP_PEAKS = 10;
    MAX_HASH_CHARACTERS_TOP_PEAKS = 10

    # Spectrum sum properties
    SIMILARITY_BLOCK_PADDING  =  10
    SIMILARITY_BLOCK_MAX_PEAKS = 100

    SPECTRUM_TYPES = {ms: 1, nmr: 2, uv_vis: 3, ir: 4, raman: 5}.freeze
    SPLASH_VERSPEAK = 0

    attr_accessor :spectrum, :spectrum_type

    # NOTE Not using the version argument yet, but the default will be
    # to use the latest version if the argument is not supplied
    def initialize(spectrum, spectrum_type, version=nil)
      # Check for allowed type of spectrum
      spectrum_type = spectrum_type.to_sym
      unless SPECTRUM_TYPES.has_key? spectrum_type
        msg = "'#{spectrum_type} is not a valid type of spectrum. " +
          "Must be one of: #{SPECTRUM_TYPES.keys.join(", ")}"
        raise ArgumentError, msg
      end

      @spectrum = normalize_spectrum(spectrum)
      @spectrum_type = spectrum_type
    end

    def self.splash_from_string(spectrum_string, spectrum_type)
      peaks = spectrum_string.split(/\n/).map do |line|
        line.split(/\s+/).map(&:to_f)
      end
      self.splash_from_peaks(peaks,spectrum_type)
    end

    def self.splash_from_peaks(spectrum, spectrum_type)
      self.new(spectrum,spectrum_type).splash
    end

    # Return the splash of the form:
    #
    # splash{spectra type}{spectra version}-{top peaks block}-{full spectrum block}-{similarity block}
    #
    # Example:
    #
    # splash10-227b34926161-156ca6d57b10dc-000082749
    #
    def splash
      @splash ||=
        "#{version_block}-#{top_peaks_block}-#{full_spectrum_block}-#{similarity_block}"
    end

    def spectrum_type_number
      SPECTRUM_TYPES[@spectrum_type]
    end

    def version_block
      "splash#{spectrum_type_number}#{SPLASH_VERSION}"
    end

    # spectrum = [(mz, intensity / max_intensity * RELATIVE_INTENSITY_SCALE) 
    # for mz, intensity in spectrum]
    def normalize_spectrum(spectrum)
      max_intensity = spectrum.map(&:last).max

      # normalize the intensities to max intensity and scale
      spectrum.map do |peak|
        peak[1] = peak[1] / max_intensity * RELATIVE_INTENSITY_SCALE
        peak
      end
    end

    # Sort the spectrum peaks by descending intensity then ascending peak position
    def spectrum_sorted_for_top_peaks
      spectrum.sort_by{|peak| [-peak.last,peak.first] }
    end

    # Make a truncated sha256 digest given a sting and a length
    def sha_digest(string,length)
      Digest::SHA256.hexdigest(string)[0,length]
    end

    def round(number)
      format "%.#{PRECISION}f", 1.0
    end

    # Create a standard string from a peak list
    #
    # Example:
    #
    # 1.000001:200.000001 2.000001:150.000001 3.000001:100.000001
    #
    def stringify_peaks(peaks)
      peaks.map do |peak|
        # Round the values before joining
        peak.map{|value| round(value) }.join(PEAK_SEPARATOR)
      end.join(PEAK_PAIR_SEPARATOR)
    end

    # A hash of the Top 10 peaks, which is a reduced spectral representation that
    # encodes the top 10 peaks without intensities sorted by descending intensity
    # and then mass-to-charge ratios m/z. The m/z are saved to 6 digits and a
    # SHA256 is calculated in hexadecimal notation and then truncated to 10
    # characters.
    def top_peaks_block
      sha_digest top_peaks_string, MAX_HASH_CHARACTERS_TOP_PEAKS
    end

    def top_peaks_string
      stringify_peaks top_peaks
    end

    def top_peaks
      spectrum_sorted_for_top_peaks[0,MAX_TOP_PEAKS]
    end

    # A hash of the full spectrum (m/z and relative intensities, sorted by
    # ascending m/z and then by descending intensity with m/z and intensity given
    # to 6 digits) in SHA256, calculated in hexadecimal notation and truncated to
    # 20 characters.
    def full_spectrum_block
      sha_digest full_spectrum_string, MAX_HASH_CHARACTERS_FULL_SPECTRUM
    end

    def full_spectrum_string
      stringify_peaks full_spectrum
    end

    def full_spectrum
      spectrum.sort_by{|peak| [peak.first,-peak.last]}
    end

    # A 10 digit block containing the sum of the peak position multiplied by relative
    # intensity values for the top 100 peaks, truncated (casted to an integer)
    # after summing
    def similarity_block
      # Zero fill the similarity block
      similarity_block_value.to_s.rjust(SIMILARITY_BLOCK_PADDING,'0')
    end

    def similarity_block_value
      similarity_block_peaks.
        # Multiply the position by the intensity
        map{|peak| peak.first * peak.last }.
        # then sum the products
        reduce(0,&:+).
        # then truncate
        round
    end

    def similarity_block_peaks
      spectrum_sorted_for_top_peaks[0,SIMILARITY_BLOCK_MAX_PEAKS]
    end

  end
end
