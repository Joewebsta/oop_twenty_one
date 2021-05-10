module Hand
  ACE_VALUE = 11

  def hit(deck)
    hand << deck.cards.shift
  end

  # def stay
  # end

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
end

class Player < Participant
  def display_hand
    join_and(card_names)
  end

  def display_hand_and_total
    puts "You have: #{display_hand}. Total: #{total}."
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

  private

  def join_and(names, unknown)
    if unknown
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
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result unless dealer.busted?
  end

  private

  def deal_cards
    [player, dealer].each do |participant|
      participant << deck.cards.shift(TOP_TWO_CARDS)
    end
  end

  def show_initial_cards
    dealer.display_hand_unknown_and_total
    player.display_hand_and_total
  end

  def player_turn
    loop do
      break if hit_or_stay == :stay

      hit_and_show_hand

      if player.busted?
        puts "You busted! The dealer wins."
        break
      end
    end
  end

  def hit_or_stay
    puts 'Hit(h) or stay(s)?'

    action = nil
    loop do
      action = gets.chomp.downcase
      break if %w(h hit s stay).include?(action)
      puts "Sorry that is an invalid answer. Please try again."
    end

    action.start_with?('s') ? :stay : :hit
  end

  def hit_and_show_hand
    player.hit(deck)
    player.display_hand_and_total
  end

  def dealer_turn
    return if player.busted?

    if dealer.total >= 17
      dealer.display_hand_and_total
      puts "The dealer choses to stay."
      return
    end

    dealer.display_hand_and_total
    puts "Press 'enter' to see dealer's next action."
    gets.chomp

    loop do
      puts "The dealer choses to hit."
      dealer.hit(deck)

      if dealer.busted?
        dealer.display_hand_and_total
        puts "The dealer busted! You win!"
        break
      end

      if dealer.total >= 17
        dealer.display_hand_and_total
        puts "The dealer choses to stay."
        break
      end

      dealer.display_hand_and_total
      puts "Press 'enter' to see dealer's next action."
      gets.chomp
    end
  end

  def show_result
    puts "RESULTS!"
    player.display_hand_and_total
    dealer.display_hand_and_total
  end
end

Game.new.start
