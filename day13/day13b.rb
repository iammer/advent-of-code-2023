#!/usr/bin/env ruby
require 'pry'
require 'pry-nav'

class Map
  def self.from_s(s)
    new(s.split("\n").map { |r| r.split('') })
  end

  def initialize(map)
    @map = map
  end

  def transpose
    Map.new(@map.transpose)
  end

  def differences(r)
    (0..r).sum do |i|
      next 0 if (r + i + 1) >= @map.size
      @map[r - i].zip(@map[r + i + 1]).count { |a, b| a != b }
    end
  end

  def find_reflection
    reflection = (0...@map.size-1).find { |r| differences(r) == 1 }
    reflection && reflection + 1
  end

  def value
    vref = transpose.find_reflection
    return vref if vref

    href = find_reflection
    return href * 100 if href

    0
  end

  def to_s
    @map.join("\n")
  end
end


maps = ARGF.read.split("\n\n").map { |puzzle| Map.from_s(puzzle) }

puts maps.map(&:value).sum
