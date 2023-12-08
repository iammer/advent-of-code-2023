#!/usr/bin/env ruby

class Hand
  attr_reader :hand, :cards, :bid

  def initialize(line)
    @hand, bid = line.chomp.split
    @cards = @hand.split('').map { |x| card_to_val(x) }
    @bid = bid.to_i
  end 

  def strength
    @strength ||= @cards.reduce(base_strength) { |acc, card| acc * 20 + card }
  end

  private

  def card_to_val(x)
    case x
    when 'T'
      10
    when 'J'
      1
    when 'Q'
      12
    when 'K'
      13
    when 'A'
      14
    else
      x.to_i
    end
  end

  def base_strength
    card_counts = @cards.reject { |c| c == 1 }
      .each_with_object(15.times.map { 0 }) { |card, counts| counts[card] += 1 }
      .sort.reverse.first(2)

    card_counts[0] += @cards.count(1)

    case card_counts
    in [5, _]
      6
    in [4, _]
      5
    in [3, 2]
      4
    in [3, _] 
      3
    in [2, 2]
      2
    in [2, _]
      1
    else
      0
    end
  end
end

puts ARGF.each_line.map { |line| Hand.new(line) }
  .sort_by(&:strength)
  .map.with_index { |hand, i| hand.bid * (i+1) }
  .reduce(:+)
