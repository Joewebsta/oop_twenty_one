module Hand
  def hit; end

  def stay; end

  def busted?; end

  def total; end
end

class Participant
  attr_accessor :hand

  def initialize
    @hand = []
  end

  def <<(cards)
    hand.concat(cards)
  end

  def card_names
    hand.map(&:name)
  end
end

class Player < Participant
  def display_hand
    names = card_names
    names[-1] = "and #{names[-1]}"
    names.join(' ')
  end
end

class Dealer < Participant
  def display_hand(options = { unknown: false })
    names = card_names
    ending = options[:unknown] ? "and an unknown card" : "and #{names[-1]}"
    names[-1] = ending
    names.join(' ')
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

  def deal
    # does the dealer or the deck deal?
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
  attr_reader :name

  def initialize(suit, value, name)
    @suit = suit
    # HOW DOES ACE AFFECT THE VALUE?
    @value = value
    @name = name
  end
end

class Game
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
    [player, dealer].each { |participant| participant << deck.cards.shift(2) }
  end

  def show_initial_cards
    puts "Dealer has: #{dealer.display_hand(unknown: true)}."
    puts "You have: #{player.display_hand}."
  end
end

Game.new.start
