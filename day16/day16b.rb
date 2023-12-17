#!/usr/bin/env ruby

class LightGrid
  attr_reader :grid_bounds

  def self.from_s(s)
    new(s.chomp.split("\n").map { |row| row.split('') })
  end

  def initialize(grid)
    @grid=grid
    @grid_bounds = [Vec2.new(0,0),Vec2.new(grid.count, grid.first.count)]
  end

  def tile_at(position)
    @grid[position.x][position.y]
  end

  def visited_count
    @visited.flatten.count(&:itself)
  end

  def keep?(beam)
    beam.in_bounds?(*@grid_bounds) && @beams_seen.add?(beam)
  end

  def run(start)
    @beams = [start]
    @visited = @grid.map { |row| row.map { |_| false } }
    @beams_seen = Set.new(@beams)

    until @beams.empty?
      @beams.each { |beam| @visited[beam.position.x][beam.position.y] = true }
      @beams = @beams.flat_map { |beam| beam.reflect(tile_at(beam.position)) }.delete_if { |beam| !keep?(beam) }
    end

    self
  end

  def to_s
    @grid.map.with_index do |row,x|
      row.map.with_index do |c,y|
        next '#' if @visited[x][y]
        c
      end.join('')
    end.join("\n")
  end
end

class Vec2
  attr_reader :x, :y

  def initialize(x,y)
    @x = x
    @y = y
  end

  def add(v)
    Vec2.new(x+v.x, y+v.y)
  end

  def flip
    Vec2.new(y,x)
  end

  def flip_neg
    Vec2.new(-y,-x)
  end

  def vert?
    y.zero?
  end

  def horz?
    x.zero?
  end

  def to_s
    "(#{x},#{y})"
  end

  def hash
    x.hash ^ y.hash
  end

  def eql?(o)
    x == o.x && y == o.y
  end

  def in_bounds?(bottom, top)
    x >= bottom.x && y >= bottom.y && x < top.x && y < top.y
  end
end

class LightBeam
  attr_reader :position, :direction

  def self.start
    new(Vec2.new(0,0),Vec2.new(0,1))
  end

  def initialize(position, direction)
    @position = position
    @direction = direction
  end

  def step!
    @position = @position.add(@direction)

    self
  end

  def horz?
    @direction.horz?
  end

  def vert?
    @direction.vert?
  end

  def in_bounds?(bottom, top)
    @position.in_bounds?(bottom, top)
  end

  def reflect(tile)
    case tile
    when '/'
      [LightBeam.new(@position, @direction.flip_neg)]
    when '\\'
      [LightBeam.new(@position, @direction.flip)]
    when '-'
      if horz?
        [clone]
      else
        [LightBeam.new(@position, @direction.flip), LightBeam.new(@position, @direction.flip_neg)]
      end
    when '|'
      if vert?
        [clone]
      else
        [LightBeam.new(@position, @direction.flip), LightBeam.new(@position, @direction.flip_neg)]
      end
    else
      [clone]
    end.map(&:step!)
  end

  def hash
    @position.hash ^ @direction.hash
  end

  def eql?(o)
    @position.eql?(o.position) && @direction.eql?(o.direction)
  end

  def to_s
    "p: #{position} d: #{direction}"
  end
end

light_grid = LightGrid.from_s(ARGF.read)
bounds = light_grid.grid_bounds.last
starts = (0...bounds.x).flat_map { |x| [ LightBeam.new(Vec2.new(x,0),Vec2.new(0,1)), LightBeam.new(Vec2.new(x,bounds.y-1),Vec2.new(0,-1)) ] } +
    (0...bounds.y).flat_map { |y| [ LightBeam.new(Vec2.new(0,y), Vec2.new(1,0)), LightBeam.new(Vec2.new(bounds.x-1,y),Vec2.new(-1,0)) ] }


puts starts.map { |s| light_grid.run(s).visited_count }.max
