#!/usr/bin/env ruby

answer = 0

max = {
  red: 12,
  green: 13,
  blue: 14
}

ARGF.each_line do |line|
  game, cubes = line.chomp.split(':')
  rounds = cubes.split(';')
  next unless rounds.all? do |round|
    round.scan(/(\d+) (\w+)/).all? do |count, color|
      count.to_i <= max[color.to_sym]
    end
  end

  answer += game.split(' ').last.to_i
end

puts answer
