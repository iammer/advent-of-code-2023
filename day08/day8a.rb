#!/usr/bin/env ruby

steps = ARGF.readline.chomp.split('').cycle
ARGF.readline

class Node
  attr_reader :name, :left, :right

  def initialize(line)
    @name, @left, @right = line.match(/(\w{3}) = \((\w{3}), (\w{3})\)/).to_a[1..-1]
  end

  def next(map, dir)
    map[dir == 'L' ? left : right]
  end

  def end?
    name == 'ZZZ'
  end
end

nodes = ARGF.each_line.map { |line| Node.new(line) }.to_h { |n| [n.name, n] }

node = nodes['AAA']
step_count = 0
while !node.end?
  node = node.next(nodes, steps.next)
  step_count += 1
end

puts step_count
