module Hand
end

class Player
  def initialize
    # what would the "data" or "states" of a Player object entail?
    # maybe cards? a name?
  end

  def hit; end

  def stay; end

  def busted?; end

  def total
    # definitely looks like we need to know about "cards" to produce some total
  end
end

class Dealer
  def initialize
    # seems like very similar to Player... do we even need this?
  end

  def deal
    # does the dealer or the deck deal?
  end

  def hit; end

  def stay; end

  def busted?; end

  def total; end
end

class Participant
  # what goes in here? all the redundant behaviors from Player and Dealer?
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
  def initialize(suit, value, name)
    @suit = suit
    # HOW DOES ACE AFFECT THE VALUE?
    @value = value
    @name = name
  end
end

class Game
  def initialize
    @deck = Deck.new
  end

  def start
    deal_cards
    show_initial_cards
    player_turn
    dealer_turn
    show_result
  end
end

# Game.new.start
