#!/usr/bin/env ruby

answer = ARGF.each_line.map do |line|
  game, cubes = line.chomp.split(':')

  rounds=cubes.split(';').map do |round|
    round.scan(/(\d+) (\w+)/).to_h { |a,b| [b,a] }
  end

  ['red','green','blue'].map do |color|
    rounds.map { |r| r[color].to_i }.max
  end.reduce(:*)
end.sum

puts answer
