#!/usr/bin/env -S ruby --yjit

class Map
  def self.from_s(s)
    new(s.chomp.split("\n").map { |r| r.split('') })
  end

  def size
    @grid.size
  end

  def initialize(grid)
    @grid = grid
  end

  def start
    @grid.each_with_index { |row,i| row.each_with_index { |c,j| return [i,j] if c == 'S' } }
  end

  def at(x,y)
    @grid[x % @grid.size][y % @grid.first.size]
  end
end

def neighbors(p)
  [
    [p.first+1,p.last],
    [p.first-1,p.last],
    [p.first,p.last+1],
    [p.first,p.last-1]
  ]
end

def fit_poly(x,y,z)
  c = x
  a = (z - 2 * y + x) / 2
  b = y - (a + c)
  [a, b, c]
end

map = Map.from_s(ARGF.read)

locs = [map.start]

counts = []
n = 26501365 / map.size
o = 26501365 % map.size

(1..map.size * 2 + o).each do |steps|
  locs = locs.flat_map { |p| neighbors(p) }.select { |l| map.at(*l) != '#' }.uniq
  counts << locs.size if steps % map.size == o
end

puts fit_poly(*counts).reduce { |acc, c| acc * n + c }
