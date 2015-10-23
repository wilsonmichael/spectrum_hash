# SpectrumHash

A library for hashing mass spectra data following the splash definition.

Paper in progress...

## Installation

Add this line to your application's Gemfile:

    gem 'spectrum_hash'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install spectrum_hash

## Usage

Splash stands for the spectra hash code and is an unique identifier independent of acquisition or processing. It basically tries to ensure that you can easily tell if two spectra are identical, similar or very different. Based on several criteria.

This library simply wraps the REST API available at http://splash.fiehnlab.ucdavis.edu/ It also has some convenient methods to work with splashes.

Create a splash from a peak list.
```ruby
require 'spectrum_hash'

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
# => "splash10-z400010000-d64778f5782df78f3910"
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
# => "splash10-z400010000-d64778f5782df78f3910"
```

There are a couple methods to get the different components of the
splash
```ruby

splash = SpectrumHash.from_splash_string "splash10-z40h010000-d349672ea211ef542549"

# print the version number for the splash
splash.version
# => "1"

# print the full version block
splash.version_block
# => "splash10"

# print the histogram block
splash.histogram_block
# => "z40h010000"

# print the hash block
splash.hash_block
# => "d349672ea211ef542549"

# get the histogram as a list of integers (handy for comparisons)
splash.histogram_list
# => [35, 4, 0, 17, 0, 1, 0, 0, 0, 0]

```

Get the manhattan distance between the histogram blocks of two splashes
```ruby
splash1 = SpectrumHash.from_splash_string "splash10-z400010000-d64778f5782df78f3910"
splash2 = SpectrumHash.from_splash_string "splash10-z40h010000-d349672ea211ef542549"
splash1.distance_to splash2
# => 17
```

## Contributing

1. Fork it ( https://github.com/[my-github-username]/spectrum_hash/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
