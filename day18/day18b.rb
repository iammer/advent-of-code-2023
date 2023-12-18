#!/usr/bin/env ruby

class Instruction
  attr_reader :distance, :direction

  def self.from_s(s)
    new(*s.chomp.scan(/(\w) (\d+) \(#(.*)\)/).first)
  end

  def initialize(direction, distance, code)
    @direction = ['R','D','L','U'][code[5].to_i]
    @distance = code[0...5].hex 
  end

  def move(x,y)
    case @direction
    when 'U'
      [x - @distance, y]
    when 'D'
      [x + @distance, y]
    when 'L'
      [x, y - @distance]
    when 'R'
      [x, y + @distance]
    end
  end
end

class Polygon
  def initialize(start)
    @pos=start
    @points=[start]
    @length=0
  end

  def draw(i)
    @pos=i.move(*@pos)
    @points << @pos
    @length += i.distance
  end

  def area
    (@points.map.with_index { |p,i| p[1] * (x(i-1) - x(i+1)) }.sum.abs + @length) / 2 + 1
  end

  private

  def x(n)
    @points[n % @points.size][0]
  end
end

instructions = ARGF.each_line.map { |line| Instruction.from_s(line) }
polygon = Polygon.new([0,0])
instructions.each { |i| polygon.draw(i) }
puts polygon.area
