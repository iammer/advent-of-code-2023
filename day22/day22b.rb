#!/usr/bin/env ruby

X, Y, Z = (0..2).to_a

class Block
  attr_reader :coords, :under, :above, :block_id
  @@next_block_id = 0

  def self.from_s(s)
    coords = s.chomp.split('~').map { |coord| coord.split(',').map(&:to_i) }.sort

    new(coords)
  end

  def initialize(coords)
    @coords=coords
    @block_id = (@@next_block_id += 1)

    @under = []
    @above = nil
  end

  def bottom_z
    coords[0][Z]
  end

  def top_z
    coords[1][Z]
  end

  def cache_under(blocks)
    @above = blocks.select { |b| below?(b) }
    @above.each { |s| s.under.push(self) }
  end

  def supports
    @supports ||= @above.select { |b| beneath?(b) }
  end

  def supported_by
    @supported_by ||= @under.select { |b| b.beneath?(self) }
  end

  def fall!
    top = @under.max_by(&:top_z)
    distance = (top ? coords[0][Z] - top.coords[1][Z]: coords[0][Z]) - 1
    return if distance.zero?

    (0..1).each { |i| coords[i][Z] -= distance }
    @supports = nil
    @supported_by = nil
  end

  def coords_in_axis(axis)
    (coords[0][axis]..coords[1][axis])
  end

  def overlaps?(block)
    [0,1].all? { |a| overlaps_in_axis?(a,block) }
  end

  def under?(block)
    coords[1][Z] < block.coords[0][Z]
  end

  def beneath?(block)
    coords[1][Z] + 1 == block.coords[0][Z]
  end

  def below?(block)
    under?(block) && overlaps?(block)
  end

  def overlaps_in_axis?(axis, block)
    s = coords_in_axis(axis)
    o = block.coords_in_axis(axis)
    s.cover?(o.begin) || s.cover?(o.end) || o.cover?(s.begin)
  end

  def support_count(removed = [])
    removed = removed.push(self)
    supports.reject { |s| s.supported_by.any? { |s| !removed.include?(s) } }.sum { |s| s.support_count(removed) + 1 }
  end

  def to_s
    "#{@block_id}: (#{coords[0].join(',')}) (#{coords[1].join(',')}) axis: #{@axis} #{coords_in_axis(@axis)} supports: #{supports.map(&:block_id).join(',')} supported_by: #{supported_by.map(&:block_id).join(',')}"
  end
end

blocks = ARGF.each_line.map { |s| Block.from_s(s) }.sort_by(&:bottom_z)
blocks.each_with_index { |b, i| b.cache_under(blocks[i+1..]) }
blocks.each(&:fall!)
puts blocks.sum(&:support_count)
