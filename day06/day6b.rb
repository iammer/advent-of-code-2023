#!/usr/bin/env ruby

EPSILON = 0.0000001

times = [ARGF.readline.split[1..].join.to_f]
distances = [ARGF.readline.split[1..].join.to_f]

puts(times.zip(distances).map do |time, distance|
  q = Math.sqrt(time * time + -4 * (distance + EPSILON))

  ((time + q) / 2).floor - ((time - q) / 2).ceil + 1
end.inject(:*))
