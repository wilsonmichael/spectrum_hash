require 'digest'

require "spectrum_hash/version"
require "spectrum_hash/splash"

module SpectrumHash
  def self.from_string(spectrum_string,options={})
    peaks = parse_peaks_string(spectrum_string)
    self.from_peaks peaks, options
  end

  def self.from_peaks(spectrum,options={})
    Splash.new spectrum, options
  end

  def self.from_splash_string(splash)
    Splash.new nil, splash: splash
  end

  private

  def self.parse_peaks_string(spectrum_string)
    spectrum_string.split(/\n/).map do |line|
      line.split(/\s+/).map(&:to_f)
    end
  end

end
