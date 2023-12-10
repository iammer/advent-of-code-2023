#!/usr/bin/env ruby

class Pipe
  attr_reader :c, :x, :y
  attr_accessor :visited

  def initialize(c,x,y)
    @c = c
    @x = x
    @y = y
    @visited = false
  end

  def visit
    return if ground?
    @visited = true
  end

  def ground?
    c == '.'
  end

  def start?
    c == 'S'
  end

  def connections
    case c
    when '|'
      [[x,y+1],[x,y-1]]
    when '-'
      [[x+1,y],[x-1,y]]
    when 'L'
      [[x+1,y],[x,y-1]]
    when 'J'
      [[x-1,y],[x,y-1]]
    when '7'
      [[x-1,y],[x,y+1]]
    when 'F'
      [[x+1,y],[x,y+1]]
    when 'S'
      [[x+1,y],[x-1,y],[x,y+1],[x,y-1]]
    else
      []
    end.reject { |x,y| x < 0 || y < 0 }
  end

  def display
    return '.' if ground?
    return 'S' if start?
    return 'X' if visited
    ' '
  end
end

map = ARGF.each_line.map.with_index do |line, y|
  line.chomp.split('').map.with_index { |c,x| Pipe.new(c,x,y) }
end

queue = map.flatten.select(&:start?)
while queue.any?
  queue.each(&:visit)
  queue = queue.flat_map(&:connections).map { |x,y| map[y]&.[](x) }.reject(&:visited)
end

#puts map.map { |row| row.map(&:display).join }.join("\n")

puts (map.flatten.count(&:visited) / 2.0).ceil 
