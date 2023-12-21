#!/usr/bin/env ruby

class RangeMap
  def initialize
    @entries = []
  end

  def add(dest, src, len)
    @entries << RangeMapEntry.new(dest, src, len)
  end

  def map_to(loc)
    @entries.find { |e| e.can_map?(loc) }&.map_to(loc) || loc
  end
end

class RangeMapEntry
  def initialize(dest, src, len)
    @dest = dest
    @src = src
    @len = len
  end

  def can_map?(loc)
    loc >= @src && loc < @src + @len
  end

  def map_to(loc)
    loc - @src + @dest
  end
end

def read_seads(line)
  line.split(': ').last.split.map(&:to_i)
end

def read_map(lines)
  map = RangeMap.new

  lines.each do |line|
    map.add(*line.split(' ').map(&:to_i))
  end

  map
end

seeds = read_seads(ARGF.readline)
ARGF.readline

maps = {}
while !ARGF.eof?
  map_name = ARGF.readline.split.first
  lines = []
  while !ARGF.eof? && (line = ARGF.readline) != "\n"
    lines << line
  end

  maps[map_name] = read_map(lines)
end

order = %w[seed soil fertilizer water light temperature humidity location]
locations = seeds
order.each_cons(2) do |src,dest|
  map = maps["#{src}-to-#{dest}"]
  locations = locations.map(&map.method(:map_to))
end

puts locations.min
