# OOP Blackjack Game

# Define Classes / Modules
class Card 
  attr_accessor :suit, :value

  def initialize(suit, value)
    @suit = suit
    @value = value
  end

  def display
    "#{value} of #{suit}"
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = []
    ['Heart', 'Diamond', 'Spade', 'Club'].each do |suit| 
      ['2', '3', '4', '5', '6', '7', '8', '9', '10', 'Jack', 'Queen', 'King', 'Ace'].each do |face_value|
        @cards << Card.new(suit, face_value)
      end
    end
    cards.shuffle!
  end

  def deal
    cards.pop
  end
end

# requires 'hand', 'name', 'card_total' instance variables from Player / Dealer Classes
module Hand
  # evaluates total of player/dealer hand
  def evaluate_total
    ace_count = 0 
    total = 0
    hand.each do |card|
      if card.value == 'Ace'
        ace_count += 1
        total += 11
      elsif card.value == 'Jack' || card.value == 'Queen' || card.value == 'King'
        total += 10
      else
        total += card.value.to_i
      end
    end

    # ace correction
    ace_count.times do
      total -= 10 if total > 21
    end

    self.card_total = total # updates 'card_total' instance variable
    "#{name} total: #{card_total}" # returns card total in string format
  end

  def display_card(card_object)
    "#{name} drew a #{card_object.display}"
  end
end

class Player
  include Hand
  attr_accessor :name, :card_total, :hand

  def initialize(name='Player')
    @name = name
    @card_total = 0
    @hand = []
  end
end

class Dealer
  include Hand
  attr_accessor :name, :card_total, :hand

  def initialize
    @name = 'Dealer'
    @card_total = 0
    @hand = []
  end
end

# game engine - creates objects out of the classes, objects are put into action
class BlackJack
  attr_accessor :player, :dealer, :deck
  @@game_count = 0

  def initialize
    @player = Player.new
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def get_player_name
    puts "---Welcome to Blackjack!!!---"
    print "Please enter your name: "
    player.name = gets.chomp.capitalize
    puts "Hello #{player.name}!! Let's begin the game!!"
    puts 
  end

  def deal_cards(person) # person = either dealer or player
    card = deck.deal
    person.hand << card
    
    if person == dealer && person.hand.size == 1
      puts "#{person.name}'s first card is hidden."
    else 
      puts person.display_card(card)
    end
  end

  def player_turn
    puts "-----#{player.name}'s Turn-----"
    player.evaluate_total # evaluates total value of player's hand
    while player.card_total < 21 # loop executes until player enters 'stay' or player busts
    
      print "Please enter 'hit' or 'stay': "
      hit_or_stay = gets.chomp
      if !['hit', 'stay'].include?(hit_or_stay.downcase)
        puts "Error Invalid Input"
        next
      elsif hit_or_stay == 'stay'
        break
      else
        new_card = deck.deal # draw a card
        puts player.display_card(new_card)
        player.hand << new_card
        puts player.evaluate_total 
      end   
    end
  end

  def dealer_turn
    puts "-----#{dealer.name}'s Turn-----"
    puts "#{dealer.name} reveals his first card: #{(dealer.hand[0]).display}"
    puts dealer.evaluate_total
    while dealer.card_total < 17
      puts "#{dealer.name} hits!"
      new_card = deck.deal
      puts dealer.display_card(new_card)
      dealer.hand << new_card
      puts dealer.evaluate_total
    end
  end

  def decide_winner
    puts "-------Result-------"
    puts "#{player.evaluate_total}, #{dealer.evaluate_total}"
    if player.card_total > 21
      puts "#{player.name} Busts. #{player.name} Loses..."
    else
      if dealer.card_total > 21
        puts "#{dealer.name} Busts. #{player.name} Wins!!!"
      elsif player.card_total > dealer.card_total
        if player.card_total == 21 && player.hand.count == 2
          print "BLACKJACK!!! "
        end
        puts "#{player.name} wins!!"
      elsif player.card_total < dealer.card_total
        puts "#{dealer.name} wins..."
      else
        puts "Draw."
      end
    end
    puts
  end

  def play_again?
    print "Play Again (yes or no)? "
    play_again = gets.chomp
    if play_again.downcase == "no"
      puts "Thanks for playing. Goodbye!"
      exit
    elsif play_again.downcase == "yes"
      puts
      puts "-----New Game-----"
      
      # re-initialize all instance variables except player name
      self.deck = Deck.new
      self.dealer = Dealer.new
      player.hand = []
      player.card_total = 0
      @@game_count += 1 
      run
    else 
      puts "Please enter 'yes' or 'no'."
      play_again?
    end
  end

  # game flow
  def run
    get_player_name if @@game_count < 1 # only executes once so we don't prompt for player name multiple times

    # deal cards and print total value for player
    2.times { deal_cards(player) }
    puts player.evaluate_total
    
    # deal cards for dealer
    2.times { deal_cards(dealer) }
  
    player_turn
    dealer_turn if player.card_total <= 21 # dealer's turn executed as long as player doesn't bust

    decide_winner
    play_again?
  end
end

blackjack = BlackJack.new
blackjack.run

