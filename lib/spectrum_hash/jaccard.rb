module Jaccard
  # Jaccard index is defined as the size of the intersection divided by the size
  # of the union of the sample sets.
  #
  # If both are empty, we define the index as 1
  #
  # We match a library peak to a query peak if the difference between the peaks
  # is less than the tolerance. We can only match a peak once.
  #
  def calculate_jaccard_ratio(lib_spectrum, query_spectrum, tolerance, options={})
    unless lib_spectrum.is_a?(Set) && query_spectrum.is_a?(Set)
      raise 'Jaccard expects the spectra as sets of integers'
    end

    unless lib_spectrum.first.is_a?(Integer) && query_spectrum.first.is_a?(Integer)
      raise 'Jaccard expects the spectra sets to contain integers'
    end

    # If both are empty, we define the index as 1
    return 1 if lib_spectrum.empty? && query_spectrum.empty?

    # Sort the input peaks and turn them into sets for efficient
    # delete operations
    #lib_spectrum   = lib_spectrum.map{|v|(v*10000).to_i}.sort.to_set
    #query_spectrum = query_spectrum.map{|v|(v*10000).to_i}.sort.to_set
    #tolerance = (tolerance*10000).to_i

    # Set up some data structures to store data
    #missed_peaks  = Set.new
    #matches = Hash.new{|h,k| h[k] = Array.new}
    missed_peaks = 0
    matches = 0
    lib_spectrum = lib_spectrum.dup

    query_spectrum.each do |query_peak|
      lib_spectrum.each do |lib_peak|
        if (lib_peak - query_peak).abs <= tolerance
          # if the difference between the query peak and
          # the lib peak is less than tolerance then it is
          # a match
          matches += 1
          # we only match a query peak once, os we remove it from
          # the set once it is matched
          lib_spectrum.delete(lib_peak)
          # we only match a library peak once, so we can break
          # at this point
          break

        elsif query_peak > lib_peak
          # we go through the query_peaks and the lib_peaks in acsending
          # order so we can be sure that when the lib peak is larger than the
          # lib_peak that no other lib peaks will match it so we can remove
          # it from the set
          missed_peaks += 1
          lib_spectrum.delete(lib_peak)

        else
          # if query_peak > lib_peak
          # we go through the query_peaks and the lib_peaks in acsending
          # order so we can be sure that when the query peak is larger than the
          # lib_peak and we don't have a match, that we can stop looking
          # for a match for this peak
          break
        end
      end
    end

    intersect_count = matches
    union_count     = missed_peaks + query_spectrum.count + lib_spectrum.count
    jaccard_index   = intersect_count.to_f / union_count.to_f

    return jaccard_index
  end
end
