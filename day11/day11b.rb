#!/usr/bin/env ruby

SCALE = 1000000

class Galaxy
  attr_reader :row, :col, :idx

  def initialize(row,col,idx)
    @row=row
    @col=col
    @idx=idx
  end

  def expand(empty_rows, empty_cols)
    @row += empty_rows.count { |r| @row > r } * (SCALE - 1)
    @col += empty_cols.count { |c| @col > c } * (SCALE - 1)

    self
  end

  def to_s
    "#{@idx}: (#{@row},#{@col})"
  end

  def distance(o)
    (@row - o.row).abs + (@col - o.col).abs
  end
end

space_map = ARGF.each_line.map.with_index do |line, rownum|
  line.chomp.split('').map { |c| c == '#' }
end

empty_rows = (0...space_map.count).reject { |i| space_map[i].any? }
empty_cols = (0...space_map.first.count).reject { |i| space_map.map { |row| row[i] }.any? }

galaxies = []
space_map.each_with_index do |row,rownum|
  row.each_with_index do |c,colnum|
    next unless c
    galaxies << Galaxy.new(rownum,colnum,galaxies.count + 1).expand(empty_rows, empty_cols)
  end
end

puts galaxies.combination(2).map { |g1,g2| g1.distance(g2) }.sum
