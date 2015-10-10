require 'digest'

require "spectrum_hash/version"
require "spectrum_hash/splash"

module SpectrumHash
  def self.from_string(spectrum_string,options={})
    peaks = self.parse_peaks_string(spectrum_string)
    self.from_peaks(peaks,options)
  end

  def self.parse_peaks_string(spectrum_string)
    spectrum_string.split(/\n/).map do |line|
      line.split(/\s+/).map(&:to_f)
    end
  end

  def self.from_peaks(spectrum,options={})
    Splash.new(spectrum,options)
  end
end
