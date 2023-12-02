#!/usr/bin/env ruby
answer = 0

ARGF.each_line do |line|
  line.chomp!
  game, cubes = line.split(':')

  rounds=cubes.split(';').map do |round|
    round.scan(/(\d+) (\w+)/).to_h { |a,b| [b,a] }
  end

  answer += ['red','green','blue'].map do |color|
    rounds.map { |r| r[color].to_i }.max
  end.reduce(:*)
end

puts answer


