#!/usr/bin/env -S ruby --yjit
require 'sorted_set'

class Vec2
  attr_reader :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end

  def add(v)
    Vec2.new(x+v.x, y+v.y)
  end

  def turns
    DIRECTIONS.select { |d| d.x.abs != x.abs }
  end

  def to_s
    "(#{x},#{y})"
  end

  def hash
    [x,y].hash
  end

  def ==(o)
    x == o.x && y == o.y
  end
  alias eql? ==

  def in_bounds?(bottom, top)
    x >= bottom.x && y >= bottom.y && x <= top.x && y <= top.y
  end
end

UP=Vec2.new(-1,0)
DOWN=Vec2.new(1,0)
LEFT=Vec2.new(0,-1)
RIGHT=Vec2.new(0,1)
DIRECTIONS=[UP,DOWN,LEFT,RIGHT]

class Path
  attr_reader :position, :direction, :value, :steps

  def initialize(position, direction, value, steps)
    @position = position
    @direction = direction
    @value = value
    @steps = steps
  end

  def from_dir_map(dir, map, steps)
    val = value
    pos = position
    steps.times {
      pos = pos.add(dir)
      val += map.tile_at(pos)
    }

    Path.new(pos, dir, val, steps)
  end

  def possible_next_paths(map)
    direction.turns.flat_map { |d| (4..10).map { |steps| from_dir_map(d,map,steps) } }.select { |p| p.position.in_bounds?(map.bottom, map.top) }
  end

  def <=>(o)
    return 0 if eql?(o)
    r = ordering <=> o.ordering
    return r unless r == 0
    -1
  end

  def ordering
    value - (position.x + position.y)
  end

  def ==(o)
    position.eql?(o.position) && direction.eql?(o.direction) && steps == o.steps
  end
  alias eql? ==

  def hash
    [position, direction, steps].hash
  end

  def to_s
    "p: #{position} d: #{direction}, s: #{steps}, v: #{value}, o: #{ordering}"
  end
end

class HeatMap
  attr_reader :top, :bottom

  def self.from_s(s)
    new(s.chomp.split("\n").map { |row| row.split('').map(&:to_i) })
  end

  def initialize(grid)
    @grid=grid
    @bottom = Vec2.new(0,0)
    @top = Vec2.new(@grid.size - 1, @grid.first.size - 1)
  end

  def tile_at(p)
    @grid[p.x]&.[](p.y) || 0
  end

  def minimum_path
    path_to(bottom, top)
  end

  def path_to(start, fin)
    paths_to_check = SortedSet.new
    seen_paths = Set.new

    start_paths = [ Path.new(start, RIGHT, 0, 0), Path.new(start, DOWN, 0, 0) ]
    paths_to_check.merge(start_paths)
    seen_paths.merge(start_paths)

    until paths_to_check.empty?
      path = paths_to_check.first

      paths_to_check.subtract([path])
      return path if path.position == fin 

      paths_to_check.merge(path.possible_next_paths(self).reject { |p| seen_paths.add?(p).nil? })
    end
  end
end

puts HeatMap.from_s(ARGF.read).minimum_path.value
