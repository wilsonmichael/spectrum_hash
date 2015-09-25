require 'digest'

require "spectrum_hash/version"
require "spectrum_hash/splash"

module SpectrumHash
  def self.from_string(spectrum_string, spectrum_type)
    peaks = self.parse_peaks_string(spectrum_string)
    self.from_peaks(peaks,spectrum_type)
  end

  def self.parse_peaks_string(spectrum_string)
    spectrum_string.split(/\n/).map do |line|
      line.split(/\s+/).map(&:to_f)
    end
  end

  def self.from_peaks(spectrum, spectrum_type)
    Splash.new(spectrum,spectrum_type).splash
  end
end
