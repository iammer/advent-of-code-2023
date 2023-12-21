#!/usr/bin/env ruby

class Map
  def self.from_s(s)
    new(s.chomp.split("\n").map { |r| r.split('') })
  end

  def initialize(grid)
    @grid = grid
    @locs = grid.map.with_index { |row,x| row.map.with_index { |c,y| Loc.new(x,y,c,self) } }
  end

  def inbounds?(x,y)
    x >= 0 && y >= 0 && x < @grid.size && y < @grid.first.size
  end

  def start
    @locs.flatten.find(&:start?)
  end

  def loc_at(x,y)
    return Loc::INVALID unless inbounds?(x,y)
    @locs[x][y]
  end
end

class Loc
  attr_reader :x, :y

  def initialize(x,y,value,map)
    @x = x
    @y = y
    @value = value
    @map = map
  end

  def valid?
    @value != '#'
  end

  def start?
    @value == 'S'
  end

  def rock?
    @value == '#'
  end

  def next_steps
    @next_steps ||= [@x-1,@x+1].map { |i| @map.loc_at(i,@y) }.concat( [@y-1, @y+1].map { |i| @map.loc_at(@x,i) } ).select(&:valid?)
  end

  def hash
    [@x, @y].hash
  end

  def ==(o)
    o.x == x && o.y == o.y
  end
  alias eql? ==

  INVALID = Loc.new(-1,-1,'#',nil)
end

map = Map.from_s(ARGF.read)

locs = [map.start]

64.times do 
  locs = locs.flat_map(&:next_steps).uniq
end

puts locs.size
