# SpectrumHash

A library for creating a Splash keys following the splash definition. Splash stands for the spectra hash code and is an unique identifier independent of acquisition or processing. It basically tries to ensure that you can easily tell if two spectra are identical, similar or very different. Based on several criteria.

This library simply wraps the REST API available at http://splash.fiehnlab.ucdavis.edu/ It also has some convenient methods to work with splashes.

Citing SPLASH:

Wohlgemuth, G, et al., SPLASH, a Hashed Identifier for Mass Spectra. Nature Biotechnology 34, 1099-101 (2016). 

# Quick Intro to SPLASH

The SPLASH is an unambiguous, database-independent spectral identifier, just as the InChIKey is designed to serve as a unique identifier for chemical structures. It contains separate blocks that define different layers of information, separated by dashes. For example, the full SPLASH of a caffeine mass spectrum above is splash10-0002-0900000000-b112e4e059e1ecf98c5f. The SPLASH is split into four blocks:

  1) Identifer Block: first block (splash10) encodes the SPLASH
  identifier. The first number is the measurement type (1 for MS, 2 and above for other data types to be included in the future) and the second number is the SPLASH version. splash10 is a
  SPLASH identifier for MS, version 0.

The second and third blocks are spectral summaries, which can be used to prefilter and restrict searches, and find similar spectra. In the second and third blocks, intensities are summed over fixed (but different) bin sizes and wrapped over ten bins. The wrapped bin (zero-based) index for a given ion is computed as floor (m/z ÷ BinSize) modulo 10.

  2) Top Ten Block:  The second block (0002) is formed using the top ten or fewer ions greater than 10% of the base peak). This reduced spectrum is summed over bins of 5 Da. Each bin is then scaled to a
  single-digit integral value in base 3 (0–2), and the resulting 10 digit histogram is converted
  to a base 36 number, resulting in a 4-digit block.

  3) Histogram Block: In the third block (0900000000) the intensities are summed over 100-Da bin
  sizes, each bin is then scaled to a single-digit, integral base-10 digit (0–9).

  4) The fourth block (b112e4e059e1ecf98c5f) is a hash of the full spectrum in Secure Hash
    Algorithm10 SHA256 (numbers and lowercase letters only), calculated in hexadecimal
    notation and truncated to 20 characters. The full spectrum string of m/z and relative abundance values.

## Installation

Add this line to your application's Gemfile:

    gem 'spectrum_hash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spectrum_hash

## Usage

Create a splash from a peak list.
```ruby
require 'spectrum_hash'

# List of m/z and intensity for each peak
spectrum = [
  [  41.982,  4383598.000],
  [  56.450,   867285.813],
  [  69.408,  1181789.750],
  [  83.625,  1009049.375],
  [ 123.006,  1119260.125],
  [ 538.356,   421962.563],
  [1026.834,  1193619.381]
]

SpectrumHash.from_peaks(spectrum).splash
# => "splash10-0006-9100000000-5405bffe0624d866f870"
```

Create a splash from a tab delimited list of peaks and strings.
```ruby
spectrum = <<-TXT
41.982  4383598.000
56.450 	867285.813
69.408 	1181789.750
83.625 	1009049.375
123.006 	1119260.125
138.356 	421962.563
1026.834 1193619.381
TXT

SpectrumHash.from_string(spectrum).splash
# => "splash10-0006-9100000000-b0cf38693934211e4e35"
```

There are a couple methods to get the different components of the
splash
```ruby

splash = SpectrumHash.from_splash_string "splash10-0006-9100000000-b0cf38693934211e4e35"

# print the version number for the splash
splash.version
# => "1"

# print the full version block
splash.version_block
# => "splash10"

# print the top ten block
splash.top_ten_block
# => "0006"

# print the histogram block
splash.histogram_block
# => "9100000000"

# print the hash block
splash.hash_block
# => "b0cf38693934211e4e35"

# get the histogram as a list of integers (handy for comparisons)
splash.histogram_list
# => [9, 1, 0, 0, 0, 0, 0, 0, 0, 0]

```

Get the manhattan distance between the histogram blocks of two splashes
```ruby
splash1 = SpectrumHash.from_splash_string "splash10-0002-0900000000-b112e4e059e1ecf98c5f"
splash2 = SpectrumHash.from_splash_string "splash10-0006-9100000000-b0cf38693934211e4e35"
splash1.distance_to splash2
# => 17
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/spectrum_hash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
