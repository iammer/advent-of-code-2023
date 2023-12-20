#!/usr/bin/env ruby

class Workflow
  attr_reader :name

  def self.from_s(s)
    name, rules = s.scan(/^(\w+){([^}]*)}$/).first
    rules = rules.split(',').map { |r| Rule.from_s(r) }
    
    new(name, rules)
  end

  def initialize(name, rules)
    @name = name
    @rules = rules
  end

  def apply(part)
    paths = []
    @rules.each do | rule|
      return paths unless part
      match, part = part.apply_rule(rule)
      paths << [ rule.dest, match ]
    end

    paths
  end
end

class Rule
  attr_reader :attr, :test, :value, :dest

  def self.from_s(s)
    new(*s.scan(/^((\w*)([<>]?)(\d*):)?(\w+)/).first[1..])
  end

  def initialize(attr, test, value, dest)
    @attr=attr
    @test=test
    @value=value.to_i
    @dest=dest
  end

  def final?
    attr.nil?
  end
end

class PartRange
  def initialize(start = 1, fin = 4000)
    @start = start
    @fin = fin
  end

  def split(rule)
    test = rule.test
    value = rule.value

    if test == '<'
      return [self] if @fin < value
      return [nil, self] if @start >= value
      [PartRange.new(@start, value - 1), PartRange.new(value, @fin)]
    else
      return [self] if @start > value
      return [nil, self] if @fin <= value
      [PartRange.new(value + 1, @fin), PartRange.new(@start, value)]
    end
  end

  def range
    @fin - @start + 1
  end
end

class Part
  attr_accessor :x, :m, :a, :s
  def initialize(x = nil, m = nil, a = nil, s = nil)
    @x = x || PartRange.new
    @m = m || PartRange.new
    @a = a || PartRange.new
    @s = s || PartRange.new
  end

  def clone
    Part.new(@x.clone, @m.clone, @a.clone, @s.clone)
  end

  def apply_rule(rule)
    return [self] if rule.final?

    attr = self.public_send(rule.attr)
    ranges = attr.split(rule)
    return [self, nil] if ranges.one?
    return [nil, self] if ranges.first.nil?

    ranges.map { |r| clone.tap { |c| c.public_send("#{rule.attr}=", r) } }
  end

  def range
    @x.range * @m.range * @a.range * @s.range
  end
end

class WorkflowSet
  def self.from_s(s)
    new(s.chomp.split("\n").map { |s| Workflow.from_s(s) }.to_h { |r| [r.name, r] })
  end

  def initialize(workflows)
    @workflows = workflows
  end

  def find_accepted_parts
    paths = @workflows['in'].apply(Part.new)

    accepted_parts = []

    until paths.empty?
      name, part = paths.shift
      if ['A','R'].include?(name)
        accepted_parts << part if name == 'A'
        next
      end

      paths.concat(@workflows[name].apply(part))
    end

    accepted_parts
  end
end

workflows = WorkflowSet.from_s(ARGF.read.split("\n\n").first)

puts workflows.find_accepted_parts.sum(&:range)
