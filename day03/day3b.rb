#!/usr/bin/env ruby

input = ARGF.each_line.map { |line| line.chomp.chars.push('.') }

def digit_at?(input,i,j)
  return false if i < 0 || j < 0

  /\d/.match(input[i]&.[](j))
end

def number_at(input,i,j)
  j-=1 while digit_at?(input,i,j-1)

  number = 0
  (j..).each do |y|
    return number unless digit_at?(input,i,y)
    number = number * 10 + input[i][y].to_i
  end
end

answer = 0

input.each_with_index do |line, i|
  line.each_with_index do |c, j|
    next unless c == '*'

    numbers = []

    [j-1,j+1].each { |y| numbers << number_at(input,i,y) if digit_at?(input,i,y) }

    [i-1,i+1].each do |x|
      y=j-1
      while y <= j+1
        numbers << number_at(input, x, y) if digit_at?(input,x,y)
        y+=1 while digit_at?(input,x,y)
        y+=1
      end
    end

    answer += numbers.reduce(:*) if numbers.count == 2
  end
end

puts answer
