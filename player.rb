class Player
	attr_accessor :name, :life, :maxLife, :defence, :hand, :mana, :maxMana
	def initialize(name)
		@name = name
		@maxLife = 0
		@defence = 0
		@initMana = 3	#戦闘開始時のマナ数
		@initDeck = []
		@deck = []
		@hand = []
		@discardPile = []
		@initNumofHandCard = 0
		@initNumOfDrawCard = 4
	    case name
        when 'Fighter'
			@maxLife = 50
			6.times do
				@initDeck.push(Card.new('Sword'))
			end
			4.times do
				@initDeck.push(Card.new('Shield'))
			end
        when 'Healer'
			@maxLife = 50
			4.times do
				@initDeck.push(Card.new('Wand'))
			end
			4.times do
				@initDeck.push(Card.new('Shield'))
			end
			2.times do
				@initDeck.push(Card.new('MercyLight'))
			end
        when 'A Ghost'
			@maxLife = 50
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.push(Card.new('Flame'))
			end
        when 'A Tiny Ghost'
			@maxLife = 20
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.push(Card.new('CandleFlame'))
			end
		when 'The King of Ghost'
			@maxLife = 100
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.push(Card.new('Flame'))
			end
			1.times do
				@initDeck.push(Card.new('HellFlame'))
			end
		end
		@life = @maxLife
	end
	def battlePrep
		@maxMana = @initMana	#戦闘中でターン開始時のマナ数
		@mana = @maxMana
		@deck = @initDeck.dup
		@numOfHandCard = @initNumofHandCard
		@numOfDrawCard = @initNumOfDrawCard
		@deck.shuffle!
		@hand = []
		@discardPile = []
		@numOfHandCard.times do
			self.draw
		end
	end
	def turnBegin
		@mana = @maxMana
		@defence = 0
		@numOfDrawCard.times do
			self.draw
		end
	end
	def turnEnd
		@hand.each do |crd|
			@discardPile.push(crd)
		end
		@hand = []
	end
	def draw
		if @deck.length == 0
			@deck = @discardPile.dup.shuffle!
			@discardPile = []
		end
		if @deck.length > 0
			@hand.push(@deck.shift)
		end
	end
	def discard(n)
		@discardPile.push(@hand.delete_at(n))
	end
	def disp
		puts @name + ' [Life ' + @life.to_s + ', Defence ' + @defence.to_s + ', Mana ' + @mana.to_s + '/' + @maxMana.to_s + ', Deck ' + @deck.length.to_s + ', Discard ' + @discardPile.length.to_s + ']'
		i = 0
		@hand.each do |crd|
			i = i + 1
			puts "\t<" + i.to_s + "> " + crd.text
		end
	end
end