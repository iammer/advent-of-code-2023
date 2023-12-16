#!/usr/bin/env ruby

def aoc_hash(s)
  s.split('').reduce(0) { |acc, c| (acc + c.ord) * 17 % 256 }
end
 
puts ARGF.read.gsub("\n", '').split(',').map { |s| aoc_hash(s) }.sum
