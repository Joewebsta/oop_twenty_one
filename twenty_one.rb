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
end

module Hand
  ACE_VALUE = 11
  MAX_TOTAL = 21

  def hit(deck)
    hand << deck.cards.shift
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
  include Hand

  attr_accessor :hand

  def initialize
    @hand = []
  end

  def <<(cards)
    (hand << cards).flatten!
  end

  def display_hand_and_total
    name = self.class == Player ? "You have" : "Dealer has"
    puts "#{name}: #{display_hand}. Total: #{total}."
  end

  private

  def display_hand(options = { unknown: false })
    join_and(card_names, options[:unknown])
  end

  def card_names
    hand.map(&:name)
  end

  def card_values
    hand.map(&:value)
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

  def spacer
    puts
  end
end

class Player < Participant
  include Formatting

  def turn(deck)
    loop do
      if hit_or_stay == :stay
        player_stays
        break
      end

      # I DO NOT LIKE PASSING DECK TO METHOD
      player_hit_and_display_hand(deck)

      if busted?
        player_busts
        return
      end
    end
  end

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

  def player_stays
    clear
    player_turn_banner
    player_stays_msg
    spacer
    display_hand_and_total
    enter_to("continue to dealer's turn")
  end

  def player_hit_and_display_hand(deck)
    clear
    player_turn_banner
    puts "You hit!"
    spacer
    hit(deck)
    display_hand_and_total
    spacer
  end

  def player_busts
    puts "***** You busted! The dealer wins. *****" if busted?

    spacer
  end

  def hit_or_stay_prompt
    puts "-------------------------------------"
    puts 'Would you like to: (h)it or (s)tay?'
  end

  def player_turn_banner
    puts "*-*-*-*-*-*-* PLAYER TURN *-*-*-*-*-*-*"
    spacer
  end

  def player_stays_msg
    puts "You stay."
  end
end

class Dealer < Participant
  MIN_HAND_TOTAL = 17

  def display_hand_unknown_and_total
    puts "Dealer has: #{display_hand(unknown: true)}."
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
    dealer_turn
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

  # || DEALER

  def dealer_turn
    return if player.busted?

    dealer_turn_header

    if dealer.sufficient_hand_total?
      spacer
      dealer_stays_msg
      enter_to("see the game results")
    else
      enter_to("see dealer's next action")
      dealer_hits
    end
  end

  def dealer_turn_header
    dealer_turn_banner
    dealer.display_hand_and_total
  end

  def dealer_hits_header
    dealer_turn_banner
    puts "The dealer hits."
    spacer
  end

  def dealer_hits
    loop do
      dealer_hits_header
      dealer.hit(deck)

      if dealer.busted?
        dealer_busts
        break
      end

      dealer.display_hand_and_total

      if dealer.sufficient_hand_total?
        enter_to("see dealer's next action")
        clear

        dealer_stays
        break
      end

      enter_to("see dealer's next action")
    end
  end

  def dealer_stays
    dealer_turn_banner
    dealer_stays_msg
    spacer
    dealer.display_hand_and_total
    enter_to("see the game results")
  end

  def dealer_busts
    dealer.display_hand_and_total
    spacer
    display_winner
    spacer
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
    puts "***** The dealer busted! You win! *****" if dealer.busted?

    return if player.busted? || dealer.busted?

    case (player > dealer)
    when 0 then puts "***** It's a tie! *****"
    when 1 then puts "***** You are the winner! *****"
    else        puts "***** Dealer is the winner! *****"
    end

    spacer
  end

  # || HELPERS

  def dealer_stays_msg
    puts "The dealer stays."
  end

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

  def dealer_turn_banner
    clear
    puts "*-*-*-*-*-*-* DEALER TURN *-*-*-*-*-*-*"
    spacer
  end

  def results_banner
    clear
    puts "*-*-*-*-*-*-*-* RESULTS *-*-*-*-*-*-*-*"
    spacer
  end
end

Game.new.start
