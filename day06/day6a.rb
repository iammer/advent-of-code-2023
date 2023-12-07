#!/usr/bin/env ruby

EPSILON = 0.0000001

times = ARGF.readline.split[1..].map(&:to_f)
distances = ARGF.readline.split[1..].map(&:to_f)

puts(times.zip(distances).map do |time, distance|
  q = Math.sqrt(time * time + -4 * distance)

  ((time + q) / 2 - EPSILON).floor - ((time - q) / 2 + EPSILON).ceil + 1
end.inject(:*))
