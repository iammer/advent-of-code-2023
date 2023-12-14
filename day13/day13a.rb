#!/usr/bin/env ruby

class Map
  def self.from_s(s)
    new(s.split("\n"))
  end

  def initialize(map)
    @map = map
  end

  def transpose
    Map.new(@map.map { |r| r.split('') }.transpose.map(&:join))
  end

  def is_reflection(r)
    (0..r).all? { |i| (r + i + 1) >= @map.size || @map[r - i] == @map[r + i + 1] }
  end

  def find_reflection
    ((0...@map.size-1).find { |r| is_reflection(r) } || -1) + 1
  end

  def to_s
    @map.join("\n")
  end
end


maps = ARGF.read.split("\n\n").map { |puzzle| Map.from_s(puzzle) }

puts maps.sum { |map| map.find_reflection * 100 + map.transpose.find_reflection }
