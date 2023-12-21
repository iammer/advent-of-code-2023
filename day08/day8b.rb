#!/usr/bin/env ruby

class Steps
  def self.from_s(s)
    new(s.chomp.split(''))
  end

  def initialize(steps)
    @steps=steps
  end

  def to_enum
    @steps.cycle
  end
end

class Node
  attr_reader :name, :left, :right

  def self.from_s(s)
    new(*s.scan(/(\w{3}) = \((\w{3}), (\w{3})\)/).first)
  end

  def initialize(*args)
    @name, @left, @right = args
  end

  def next(map, dir)
    map[dir == 'L' ? left : right]
  end

  def end?
    name.end_with?('Z')
  end

  def start?
    name.end_with?('A')
  end
end

steps, nodes = ARGF.read.split("\n\n")
steps = Steps.from_s(steps)
nodes = nodes.split("\n").map { |s| Node.from_s(s) }.to_h { |n| [n.name, n] }

start_nodes = nodes.values.select(&:start?)
counts = start_nodes.map do |node|
  step_count = 0
  step_enum = steps.to_enum

  while !node.end?
    node = node.next(nodes, step_enum.next)
    step_count += 1
  end

  step_count
end

puts counts.reduce { |acc, c| acc.lcm(c) }
