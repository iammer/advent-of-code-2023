#!/usr/bin/env ruby
answer = 0

ARGF.each_line do |line|
  card, wining_numbers_section, have_numbers_section = line.chomp.split(/[:|]/)
  wining_numbers = wining_numbers_section.split
  have_numbers = have_numbers_section.split

  matches = have_numbers.intersection(wining_numbers).count 
  answer += 2 ** ( matches - 1) if matches > 0
end

puts answer
