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

  def next_workflow(part)
    @rules.find { |r| r.applies_to?(part) }.dest
  end
end

class Rule
  attr_reader :dest

  def self.from_s(s)
    new(*s.scan(/^((\w*)([<>]?)(\d*):)?(\w+)/).first[1..])
  end

  def initialize(attr, test, value, dest)
    @attr=attr
    @test=test
    @value=value.to_i
    @dest=dest
  end

  def applies_to?(part)
    return true if @attr.nil?

    case @test
    when '>'
      part.public_send(@attr) > @value
    when '<'
      part.public_send(@attr) < @value
    else
      false
    end
  end
end


class Part
  attr_reader :x, :m, :a, :s

  def self.from_s(s)
    new(*s.scan(/(\w)=(\d+)/).map(&:last).map(&:to_i))
  end

  def initialize(x,m,a,s)
    @x = x
    @m = m
    @a = a
    @s = s
  end

  def rating
    @x + @m + @a + @s
  end
end

class WorkflowSet
  def self.from_s(s)
    new(s.chomp.split("\n").map { |s| Workflow.from_s(s) }.to_h { |r| [r.name, r] })
  end

  def initialize(workflows)
    @workflows = workflows
  end

  def accepted?(part)
    workflow_name = 'in'
    until ['A','R'].include?(workflow_name)
      workflow_name = @workflows[workflow_name].next_workflow(part)
    end

    workflow_name == 'A'
  end
end

workflows, parts = ARGF.read.split("\n\n")
parts = parts.chomp.split("\n").map { |s| Part.from_s(s) }
workflows = WorkflowSet.from_s(workflows)

accepted_parts = parts.select { |part| workflows.accepted?(part) }

puts accepted_parts.sum(&:rating)
