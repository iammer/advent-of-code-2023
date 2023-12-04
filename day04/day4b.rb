#!/usr/bin/env ruby

matches = ARGF.each_line.map do |line|
  line.chomp!

  card, wining_numbers_section, have_numbers_section = line.split(/[:|]/)
  wining_numbers = wining_numbers_section.split
  have_numbers = have_numbers_section.split

  have_numbers.intersection(wining_numbers).count 
end

class CardsPerCard
  def initialize(matches)
    @cache = []
    @matches = matches
  end

  def for_card(n)
    @cache[n] ||= (n+1..n+@matches[n-1]).map { |x| for_card(x) }.sum + 1
  end
end

cards = CardsPerCard.new(matches)
puts (0...matches.count).map { |x| cards.for_card(x) }.sum
