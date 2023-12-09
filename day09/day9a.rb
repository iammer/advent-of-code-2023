#!/usr/bin/env ruby

def win2(arr)
  arr[0...-1].zip(arr[1..-1])
end

def interpolate(arr)
  diffs = win2(arr).map { |a, b| b - a }
  return arr.last if diffs.all?(&:zero?)

  arr.last + interpolate(diffs)
end

puts ARGF.each_line.map { |line| interpolate(line.chomp.split.map(&:to_i)) }.sum
