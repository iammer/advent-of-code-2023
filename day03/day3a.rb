#!/usr/bin/env ruby

input = ARGF.each_line.map { |line| line.chomp.chars.push('.') }

def symbol?(input,i,j)
  return false if i < 0 || j < 0
  /[^\d\.]/.match(input[i]&.[](j))
end

def adjacent?(input, i, j)
  (i-1..i+1).any? do |x|
    (j-1..j+1).any? { |y| symbol?(input,x,y) }
  end
end

answer = 0
number = 0
adjacent = false

input.each_with_index do |line, i|
  line.each_with_index do |c, j|
    if /\d/.match(c)
      adjacent ||= adjacent?(input,i,j)
      number = number * 10 + c.to_i
    else
      answer += number if number > 0 && adjacent
      number = 0
      adjacent = false
    end
  end
end

puts answer
