module Hand
  ACE_VALUE = 11

  def hit; end

  def stay; end

  def busted?; end

  def total
    ace_count = card_values.count(ACE_VALUE)
    total = card_values.sum

    # while !busted?
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
    hand.concat(cards)
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
    names = card_names

    case names.size
    when 2 then names.join(' and ')
    else "#{names[0..-2].join(', ')} and #{names[-1]}"
    end
  end
end

class Dealer < Participant
  def display_hand(options = { unknown: false })
    names = card_names

    if options[:unknown]
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
    # HOW DOES ACE AFFECT THE VALUE?
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
    # player_turn
    # dealer_turn
    # show_result
  end

  private

  def deal_cards
    [player, dealer].each do |participant|
      participant << deck.cards.shift(TOP_TWO_CARDS)
    end
  end

  def show_initial_cards
    puts "Dealer has: #{dealer.display_hand(unknown: true)}."
    puts "You have: #{player.display_hand}. Total: #{player.total}."
  end
end

Game.new.start
