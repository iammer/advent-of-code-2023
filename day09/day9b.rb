#!/usr/bin/env ruby

def interpolate(arr)
  diffs = arr.each_cons(2).map { |a, b| b - a }
  return arr.last if diffs.all?(&:zero?)

  arr.last + interpolate(diffs)
end

puts ARGF.each_line.map { |line| interpolate(line.chomp.split.map(&:to_i).reverse) }.sum
