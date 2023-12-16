#!/usr/bin/env ruby

class Instruction
  attr_reader :label, :op, :arg

  def self.from_s(s)
    new(*s.scan(/(\w+)([=-])(\d*)/).first)
  end

  def initialize(label, op, arg = 0)
    @label = label
    @op = op
    @arg = arg.to_i
  end

  def box
    aoc_hash(@label)
  end

  def lens
    Lens.new(@label, @arg)
  end

  def to_s
    "#{@label}#{@op}#{@arg}"
  end

  def operate_on(box)
    if @op == '-'
      box.remove(@label)
    else
      box.add(lens)
    end
  end

  private

  def aoc_hash(s)
    s.split('').reduce(0) { |acc, c| (acc + c.ord) * 17 % 256 }
  end
end

class Box
  def initialize(n)
    @items = []
    @n = n
  end

  def add(lens)
    @items[find(lens.label)] = lens
  end

  def remove(label)
    @items.delete_if { |l| l.label == label }
  end

  def focal_length
    (@n + 1) * @items.map.with_index { |l, i| l.focal_length * (i + 1) }.sum
  end

  def to_s
    "Box #{@n}: #{@items.map(&:to_s).join(" ")}" unless @items.empty?
  end

  private

  def find(label)
    @items.index { |l| l.label == label } || @items.length
  end
end

class Lens
  attr_reader :label, :focal_length

  def initialize(label, focal_length)
    @label = label
    @focal_length = focal_length
  end

  def to_s
    "[#{@label} #{@focal_length}]"
  end
end

instructions = ARGF.read.gsub("\n", '').split(',').map { |s| Instruction.from_s(s) }
@boxes = 256.times.map { |n| Box.new(n) }
instructions.each { |i| i.operate_on(@boxes[i.box]) }

puts @boxes.map(&:focal_length).sum
