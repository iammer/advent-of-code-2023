#!/usr/bin/env ruby

class RangeMap
  def initialize
    @entries = []
  end

  def add(dest, src, len)
    @entries << RangeMapEntry.new(dest, src, len)
  end

  def map_to(ranges)
    to_map = ranges
    dest = []
    @entries.each do |entry|
      to_map, mapped = entry.map_range(to_map)
      dest += mapped
    end

    dest + to_map
  end
end

class RangeMapEntry
  def initialize(dest, src, len)
    @dest = dest
    @src = src
    @src_range = [src,src+len-1]
  end
  
  def map_val(val)
    val - @src + @dest
  end

  def map_range(ranges)
    to_map = []
    mapped = []

    ranges.each do |range|
      mapped << range_inter(range, @src_range)
      to_map += range_subtract(range, @src_range)
    end

    [to_map, mapped.compact.map { |m| m.map(&method(:map_val)) }]
  end
end

def range_inter(a, b)
  start = [a[0],b[0]].max
  fin = [a[1],b[1]].min
  fin >= start ? [start,fin] : nil
end

def range_subtract(a,b)
  return [a] if range_inter(a,b).nil?
  return [[a[0],b[0]-1], [b[1]+1,a[1]]] if a[0] < b[0] && b[1] < a[1]
  return [] if b[0] <= a[0] && a[1] <= b[1]
  return [[b[1]+1,a[1]]] if b[0] <= a[0] && b[1] < a[1]
  return [[a[0],b[0]-1]] if a[0] < b[0] && a[1] <= b[1]
  raise 'Something is wrong'
end

def read_seeds(line)
  line.split(': ').last.split.map(&:to_i).each_slice(2).map { |a,b| [a,a+b-1] }
end

def read_map(lines)
  map = RangeMap.new

  lines.each do |line|
    map.add(*line.split(' ').map(&:to_i))
  end

  map
end

seeds = read_seeds(ARGF.readline)
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
order.each_cons(2).each do |src,dest|
  map = maps["#{src}-to-#{dest}"]
  locations = map.map_to(locations)
end

puts locations.map(&:first).min
