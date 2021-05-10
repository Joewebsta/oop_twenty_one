module Hand
  ACE_VALUE = 11

  def hit(deck)
    hand << deck.cards.shift
  end

  def busted?
    total > 21
  end

  def total
    ace_count = card_values.count(ACE_VALUE)
    total = card_values.sum

    while total > 21 && ace_count > 0
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

  private

  def card_names
    hand.map(&:name)
  end

  def card_values
    hand.map(&:value)
  end

  def spacer
    puts
  end
end

class Player < Participant
  def display_hand_and_total
    puts "You have: #{join_and(card_names)}. Total: #{total}."
  end

  def hit_or_stay
    puts 'Would you like to: hit(h) or stay(s)?'

    action = nil
    loop do
      action = gets.chomp.downcase
      break if %w(h hit s stay).include?(action)
      spacer
      puts "Sorry that is an invalid answer. Please try again."
    end

    spacer
    action.start_with?('s') ? :stay : :hit
  end

  def >(dealer)
    total <=> dealer.total
  end

  private

  def join_and(names)
    if names.size == 2
      names.join(' and ')
    else
      "#{names[0..-2].join(', ')} and #{names[-1]}"
    end
  end
end

class Dealer < Participant
  def display_hand(options = { unknown: false })
    join_and(card_names, options[:unknown])
  end

  def display_hand_and_total
    puts "Dealer has: #{display_hand}. Total: #{total}."
  end

  def display_hand_unknown_and_total
    puts "Dealer has: #{display_hand(unknown: true)}."
  end

  def sufficient_hand_total?
    total >= 17
  end

  private

  def join_and(names, unknown_card)
    if unknown_card
      "#{names[0]} and an unknown card"
    else
      "#{names[0..-2].join(', ')} and #{names[-1]}"
    end
  end
end

class Deck
  SUITS = %w(Spades Hearts Diamonds Clubs)

  attr_reader :cards

  def initialize
    @cards = create_deck.shuffle
  end

  def create_deck
    SUITS.each_with_object([]) do |suit, cards|
      (2..14).each do |num|
        cards << Card.new(suit, value(num), name(num))
      end
    end
  end

  private

  def name(num)
    case num
    when 2..10 then num
    when 11 then 'Jack'
    when 12 then 'Queen'
    when 13 then 'King'
    else 'Ace'
    end
  end

  def value(num)
    case num
    when 2..10 then num
    when 11..13 then 10
    else 11
    end
  end
end

class Card
  attr_reader :name, :value

  def initialize(suit, value, name)
    @suit = suit
    @value = value
    @name = name
  end
end

class Game
  TOP_TWO_CARDS = 2

  attr_accessor :player, :dealer
  attr_reader :deck

  def initialize
    @deck = Deck.new
    @player = Player.new
    @dealer = Dealer.new
  end

  def start
    game_banner
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result unless dealer.busted? || player.busted?
  end

  private

  def game_banner
    clear
    puts "*-*-*-*-*-*-* TWENTY-ONE *-*-*-*-*-*-*"
    spacer
  end

  def deal_cards
    [player, dealer].each do |participant|
      participant << deck.cards.shift(TOP_TWO_CARDS)
    end
  end

  def show_initial_cards
    dealer.display_hand_unknown_and_total
    player.display_hand_and_total
    2.times { spacer }
  end

  def player_turn
    loop do
      break if player.hit_or_stay == :stay

      clear
      player_turn_banner
      hit_and_display_hand

      break if player_busts
    end
  end

  def player_busts
    return unless player.busted?

    clear
    results_banner
    spacer

    player.display_hand_and_total
    spacer
    puts "***** You busted! The dealer wins. *****"
    spacer
    true
  end

  def player_turn_banner
    puts "*-*-*-*-*-*-* PLAYER TURN *-*-*-*-*-*-*"
    spacer
  end

  def hit_and_display_hand
    player.hit(deck)
    player.display_hand_and_total
    spacer
  end

  def dealer_turn
    return if player.busted?

    if dealer.sufficient_hand_total?
      dealer.display_hand_and_total
      dealer_stays_msg
      return
    end

    dealer.display_hand_and_total
    enter_for_dealer_action

    dealer_hits
  end

  def enter_for_dealer_action
    puts "Press 'enter' to see dealer's next action."
    gets.chomp
  end

  def dealer_hits
    loop do
      puts "The dealer choses to hit."
      dealer.hit(deck)

      break if dealer_busts
      break if dealer_stays

      dealer.display_hand_and_total
      enter_for_dealer_action
    end
  end

  def dealer_busts
    return unless dealer.busted?

    dealer.display_hand_and_total
    puts "The dealer busted! You win!"
    true
  end

  def dealer_stays
    return unless dealer.sufficient_hand_total?

    dealer.display_hand_and_total
    puts "The dealer choses to stay."
    true
  end

  def show_result
    # clear
    results_banner
    player.display_hand_and_total
    dealer.display_hand_and_total
    display_winner
  end

  def results_banner
    puts "*-*-*-*-*-*-*-* RESULTS *-*-*-*-*-*-*-*"
  end

  def display_winner
    case (player > dealer)
    when 0 then puts "It's a tie!"
    when 1 then puts "You are the winner!"
    else        puts "Dealer is the winner!"
    end
  end

  def clear
    system "clear"
  end

  def spacer
    puts
  end
end

Game.new.start
