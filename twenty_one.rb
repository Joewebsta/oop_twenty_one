module Formatting
  def clear
    system "clear"
  end

  def spacer
    puts
  end

  def enter_to(action)
    puts
    puts "------------------------------------------"
    puts "Press 'enter' to #{action}."
    gets.chomp
  end

  def join_and(names, unknown_card)
    if unknown_card
      "#{names[0]} and an unknown card"
    elsif names.size == 2
      names.join(' and ')
    else
      "#{names[0..-2].join(', ')} and #{names[-1]}"
    end
  end
end

module Hand
  ACE_VALUE = 11
  MAX_TOTAL = 21

  def add_card(deck)
    hand << deck.cards.shift
  end

  def card_names
    hand.map(&:name)
  end

  def card_values
    hand.map(&:value)
  end

  def busted?
    total > MAX_TOTAL
  end

  def total
    ace_count = card_values.count(ACE_VALUE)
    total = card_values.sum

    while total > MAX_TOTAL && ace_count > 0
      total -= 10
      ace_count -= 1
    end

    total
  end
end

class Participant
  include Hand, Formatting

  attr_accessor :hand

  def initialize
    @hand = []
  end

  def <<(cards)
    (hand << cards).flatten!
  end

  def turn(deck)
    loop do
      if hit_or_stay == :hit
        hit(deck)
        break bust if busted?
      else
        stay
        break
      end
    end
  end

  def display_hand_and_total
    name = self.class == Player ? "You have" : "Dealer has"
    puts "#{name}: #{display_hand}. Total: #{total}."
  end

  private

  def display_hand(options = { unknown: false })
    join_and(card_names, options[:unknown])
  end
end

class Player < Participant
  def >(dealer)
    total <=> dealer.total
  end

  private

  def hit_or_stay
    hit_or_stay_prompt

    action = nil
    loop do
      action = gets.chomp.strip.downcase
      break if %w(h hit s stay).include?(action)
      spacer
      puts "Sorry that is an invalid answer. Please try again."
    end

    spacer
    action.start_with?('s') ? :stay : :hit
  end

  def hit(deck)
    clear
    turn_banner
    puts "You hit!"
    spacer
    add_card(deck)
    display_hand_and_total
    spacer
  end

  def stay
    clear
    turn_banner
    stay_msg
    spacer
    display_hand_and_total
    enter_to("continue to dealer's turn")
  end

  def bust
    puts "***** You busted! The dealer wins. *****" if busted?
    spacer
  end

  def hit_or_stay_prompt
    puts "-------------------------------------"
    puts 'Would you like to: (h)it or (s)tay?'
  end

  def turn_banner
    puts "*-*-*-*-*-*-* PLAYER TURN *-*-*-*-*-*-*"
    spacer
  end

  def stay_msg
    puts "You stay."
  end
end

class Dealer < Participant
  MIN_HAND_TOTAL = 17

  def hit_or_stay
    sufficient_hand_total? ? :stay : :hit
  end

  def display_hand_unknown_and_total
    puts "Dealer has: #{display_hand(unknown: true)}."
  end

  def hit(deck)
    hits_header
    add_card(deck)
    display_hand_and_total

    return if busted?

    enter_to("see dealer's next action")
    clear if sufficient_hand_total?
  end

  def hits_header
    turn_banner
    puts "The dealer hits."
    spacer
  end

  def stay
    turn_banner
    stay_msg
    spacer
    display_hand_and_total
    enter_to("see the game results")
  end

  def bust
    hits_header
    display_hand_and_total
    spacer
    puts "***** The dealer busted! You win! *****" if busted?
    spacer
  end

  def turn_banner
    clear
    puts "*-*-*-*-*-*-* DEALER TURN *-*-*-*-*-*-*"
    spacer
  end

  def stay_msg
    puts "The dealer stays."
  end

  def sufficient_hand_total?
    total >= MIN_HAND_TOTAL
  end
end

class Deck
  attr_reader :cards

  def initialize
    @cards = create_deck.shuffle
  end

  def create_deck
    Card::SUITS.each_with_object([]) do |suit, cards|
      Card::VALUES.each do |num|
        cards << Card.new(suit, num)
      end
    end
  end
end

class Card
  SUITS = %w(Spades Hearts Diamonds Clubs)
  VALUES = (2..14).to_a

  attr_reader :name, :value

  def initialize(suit, num)
    @suit = suit
    @value = card_value(num)
    @name = card_name(num)
  end

  private

  def card_name(num)
    case num
    when 2..10 then num
    when 11 then 'Jack'
    when 12 then 'Queen'
    when 13 then 'King'
    else 'Ace'
    end
  end

  def card_value(num)
    case num
    when 2..10 then num
    when 11..13 then 10
    else 11
    end
  end
end

class Game
  include Formatting

  TOP_TWO_CARDS = 2

  attr_accessor :player, :dealer
  attr_reader :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    loop do
      main_game
      break unless play_again?
      reset
    end

    goodbye_msg
  end

  private

  def play_again?
    answer = nil
    loop do
      play_again_prompt
      answer = gets.chomp.downcase
      break if %w(y yes no n).include?(answer)

      spacer
      puts "Sorry that is an invalid answer. Please try again."
      spacer
    end

    answer.start_with?('y')
  end

  def play_again_prompt
    puts "------------------------------------"
    puts "Would you like to play again? (y/n)."
  end

  def main_game
    game_banner
    deal_cards
    show_initial_cards
    player.turn(deck)

    return if player.busted?

    dealer.turn(deck)
    show_result unless dealer.busted? || player.busted?
  end

  def deal_cards
    [player, dealer].each do |participant|
      participant << deck.cards.shift(TOP_TWO_CARDS)
    end
  end

  def show_initial_cards
    dealer.display_hand_unknown_and_total
    player.display_hand_and_total
    spacer
  end

  def reset
    @deck = Deck.new
    @player.hand = []
    @dealer.hand = []
  end

  # || RESULTS

  def show_result
    results_banner
    player.display_hand_and_total
    dealer.display_hand_and_total
    spacer
    display_winner
  end

  def display_winner
    return if player.busted? || dealer.busted?

    case (player > dealer)
    when 0 then puts "***** It's a tie! *****"
    when 1 then puts "***** You are the winner! *****"
    else        puts "***** Dealer is the winner! *****"
    end

    spacer
  end

  # || HELPERS

  def goodbye_msg
    spacer
    puts "Thank you for playing Twenty-One. Goodbye!"
    spacer
  end

  def game_banner
    clear
    puts "*-*-*-*-*-*-* TWENTY-ONE *-*-*-*-*-*-*"
    spacer
  end

  def results_banner
    clear
    puts "*-*-*-*-*-*-*-* RESULTS *-*-*-*-*-*-*-*"
    spacer
  end
end

Game.new.start
