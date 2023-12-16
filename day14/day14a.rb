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
end

puts Platform.from_str(ARGF.read).tilt!.weight
