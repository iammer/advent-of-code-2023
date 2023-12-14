#!/usr/bin/env ruby

class Row
  def self.from_line(line)
    record, groups = line.split
    new(record, groups)
  end

  def initialize(record, groups)
    @record = record
    @groups = groups.split(',')

    @memo = (@record.size + 1).times.map { |_| @groups.map { nil }.push(nil) }
  end

  def possibilities(n=0, m=0)
    @memo[n][m] ||= self._possibilities(n,m)
  end

  private

  def _possibilities(n,m)
    return @record[n..].match('^[.?]*$') ? 1 : 0 if m==@groups.length
    return 0 if n == @record.length

    match = next_match(n, m)
    return possibilities(next_wild(n), m) if match.nil?

    possibilities(match, m+1) + possibilities(next_wild(n), m)
  end

  def next_match(n,m)
    match = @record[n..].match("^\\.*[#?]{#{@groups[m]}}([.?]\\.*|$)")&.end(0)
    match && match + n
  end

  def next_wild(n)
    nw = @record[n..].match(/^\.*\?/)&.end(0)
    return @record.length if nw.nil?

    nw + n
  end
end

rows = ARGF.each_line.map { |line| Row.from_line(line) }

puts rows.map(&:possibilities).sum
