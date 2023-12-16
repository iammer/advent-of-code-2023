#!/usr/bin/env ruby

class Platform
  def self.from_str(s)
    Platform.new(s.split("\n").map { |l| l.split('') })
  end

  def initialize(grid)
    @grid = grid
  end

  def find_first_block(row, col)
    (row-1).downto(0).find { |i| ['#','O'].include?(@grid[i][col]) } || -1
  end

  def rotate!
    @grid = @grid.transpose.map(&:reverse)

    self
  end

  def tilt!
    @grid.each_with_index do |row, x|
      next if x == 0
      row.each_with_index do |cell, y|
        next unless cell == 'O'
        @grid[x][y] = '.'
        @grid[find_first_block(x, y) + 1][y] = 'O'
      end
    end

    self
  end

  def weight
    @grid.map.with_index do |row, x|
      row.count('O') * (@grid.length - x)
    end.sum
  end

  def to_s
    @grid.map(&:join).join("\n")
  end

  def cycle!
    tilt!.rotate!.tilt!.rotate!.tilt!.rotate!.tilt!.rotate!
  end

  def hash
    @grid.map(&:join).join('').hash
  end
end

class CycleDetector
  def initialize(platform)
    @platform = platform
    @seen = {}
    @weights = {}
    @order = []
    @cycle_length = nil
    @cycle_start = nil
  end

  def detect
    (0..).each do |cycle|
      if seen_at(@platform)
        @cycle_length = cycle - seen_at(@platform)
        @cycle_start = seen_at(@platform)
        return self
      end

      mark_seen(@platform, cycle)
      @platform.cycle!
    end
  end

  def find_weight_at_cycle(cycle)
    @weights[@order[(cycle - @cycle_start) % @cycle_length + @cycle_start]]
  end

  private

  def seen_at(platform)
    @seen[platform.hash]
  end

  def mark_seen(platform, cycle)
    hash = platform.hash
    @order << hash
    @seen[hash] = cycle
    @weights[hash] = platform.weight
  end

end

puts CycleDetector.new(Platform.from_str(ARGF.read)).detect.find_weight_at_cycle(1000000000)
