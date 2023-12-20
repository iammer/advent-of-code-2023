#!/usr/bin/env ruby

HIGH = 1
LOW = 0

def flip(value)
  value == LOW ? HIGH : LOW
end

class Machine
  def self.from_s(s)
    new(s.chomp.split("\n").map { |s| Component.from_s(s) })
  end

  def initialize(components)
    @components = components.to_h { |c| [c.name, c] }
    @pulses = []
    @next_pulse = 0

    @components.values.each { |c| c.connect(self) }
  end

  def trigger(name, v)
    @pulses.push(Pulse.new(v, @components[name]))

    self
  end

  def run
    until @next_pulse >= @pulses.size
      @pulses.concat(@pulses[@next_pulse].trigger)
      @next_pulse+=1
    end

    self
  end

  def pulse_counts
    @pulses.each_with_object([0,0]) { |p, acc| acc[p.value] += 1 }
  end

  def pulse_display
    @pulses.map(&:to_s).join("\n")
  end

  def [](name)
    @components[name] ||= Component.new(name, [])
  end
end

class Pulse
  attr_reader :source, :destination, :value
  def initialize(value, destination, source = nil)
    @source = source
    @value = value
    @destination = destination
  end

  def trigger
    @destination.trigger(self)
  end

  def high?
    @value == HIGH
  end
  
  def low?
    @value == LOW
  end

  def to_s
    "#{source&.name} -#{low? ? 'low' : 'high'}-> #{destination.name}"
  end
end

class Component
  attr_reader :name

  def self.from_s(s)
    type, name, outputs = s.scan(/^([&%]?)(\w+)\s->\s(.*)$/).first
    output_names = outputs.split(/[, ]+/)
    
    case type
    when '&'
      Conjuction.new(name, output_names)
    when '%'
      FlipFlop.new(name, output_names)
    else
      new(name, output_names)
    end
  end

  def initialize(name, output_names)
    @name = name
    @output_names = output_names
    @outputs = []
    @inputs = []
  end

  def connect(machine)
    @outputs = @output_names.map { |n| machine[n] }
    @outputs.each { |c| c.connected_to(self) }
  end

  def connected_to(input)
    @inputs << input
  end

  def trigger(pulse)
    send_pulse(pulse.value)
  end

  def send_pulse(v)
    @outputs.map { |c| Pulse.new(v, c, self) }
  end
end

class FlipFlop < Component
  def initialize(name, output_names)
    super(name, output_names)
    @state = LOW
  end

  def trigger(pulse)
    return [] if pulse.high?
    @state = flip(@state)

    send_pulse(@state)
  end
end

class Conjuction < Component
  def initialize(name, output_names)
    super(name, output_names)
    @input_pulse_map = {}
  end

  def connected_to(input)
    super(input)
    @input_pulse_map[input.name] = Pulse.new(LOW, input, self)
  end

  def trigger(pulse)
    @input_pulse_map[pulse.source.name] = pulse
    return send_pulse(LOW) if @input_pulse_map.values.all?(&:high?)
    send_pulse(HIGH)
  end
end

machine = Machine.from_s(ARGF.read)
1000.times { machine.trigger('broadcaster',LOW).run }

puts machine.pulse_counts.reduce(:*)
