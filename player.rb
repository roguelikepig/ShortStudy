class Player
	CharacterNameArrArr = [
		#1行目がアカウント新規作成時の初期キャラクター（群）となる。
		#各行1セル目はその行のキャラクター群の呼び名
		['Fighter solo', 'Fighter'],
		['Fighter + Healer pair', 'Fighter', 'Healer'],
		['TestScenario', 'TestPlayer'],
	]
	NPCNameArrArr = [
		#各行1セル目はその行のNPC群の呼び名
		['Light Turret', 'Light Turret'],
		['Heavy Turret', 'Heavy Turret'],
	]
	def self.createCharacterArr(name)
		plyArr = []
		0.upto(CharacterNameArrArr.length - 1) do |i|
			if name == CharacterNameArrArr[i][0]
				1.upto(CharacterNameArrArr[i].length - 1) do |n|
					plyArr.push(self.new(CharacterNameArrArr[i][n]))
				end
			end
		end
		plyArr
	end
	def self.createNPCArr(name)
		npcArr = []
		0.upto(NPCNameArrArr.length - 1) do |i|
			if name == NPCNameArrArr[i][0]
				1.upto(NPCNameArrArr[i].length - 1) do |n|
					npcArr.push(self.new(NPCNameArrArr[i][n]))
				end
			end
		end
		npcArr
	end
	attr_accessor :name, :role, :life, :maxLife, :defence, :poison, :slackenerPeriod, :hand, :mana, :maxMana
	def initialize(name)
		@name = name
		@role = 'player'	#プレイヤーかNPCかのフラグ
		@maxLife = 0
		@defence = 0
		@poison = 0
        @slackenerPeriod = 0    #筋弛緩状態のターン数
        @initMana = 3	#戦闘開始時のマナ数
		@initDeck = []
		@deck = []
		@hand = []
		@discardPile = []
		@initNumofHandCard = 0
		@initNumOfDrawCard = 4
	    case name
        when 'TestPlayer'
            @initNumOfDrawCard = 20
			@maxLife = 1000
            @initDeck.append(Card.new('Sword'))
            @initDeck.append(Card.new('Sword'))
            @initDeck.append(Card.new('Sword'))
            @initDeck.append(Card.new('Sword'))
            @initDeck.append(Card.new('Slackener1'))
            @initDeck.append(Card.new('Slackener2'))
#            @initDeck.append(Card.new('Wand'))
            @initDeck.append(Card.new('Shield'))
            @initDeck.append(Card.new('Shield'))
            @initDeck.append(Card.new('Shield'))
            @initDeck.append(Card.new('Shield'))
#            @initDeck.append(Card.new('MercyLight'))
#            @initDeck.append(Card.new('DivideBy2'))
#            @initDeck.append(Card.new('DivideBy3'))
#            @initDeck.append(Card.new('CandleFlame'))
#            @initDeck.append(Card.new('Flame'))
#            @initDeck.append(Card.new('HellFlame'))
        when 'Fighter'
			@maxLife = 50
			6.times do
				@initDeck.append(Card.new('Sword'))
			end
			4.times do
				@initDeck.append(Card.new('Shield'))
			end
        when 'Healer'
			@maxLife = 50
			4.times do
				@initDeck.append(Card.new('Wand'))
			end
			4.times do
				@initDeck.append(Card.new('Shield'))
			end
			2.times do
				@initDeck.append(Card.new('MercyLight'))
			end
        when 'A Ghost'
			@maxLife = 53
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.append(Card.new('Flame'))
			end
        when 'A Tiny Ghost'
			@maxLife = 15
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.append(Card.new('CandleFlame'))
			end
		when 'The King of Ghost'
			@maxLife = 101
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.append(Card.new('Flame'))
			end
			1.times do
				@initDeck.append(Card.new('HellFlame'))
			end
		end
		@life = @maxLife
	end
	def battlePrep
		@maxMana = @initMana	#戦闘中でターン開始時のマナ数
		@mana = @maxMana
        @defence = 0
		@poison = 0
        @slackenerPeriod = 0
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
        if @poison > 0
			puts @name + " の体を毒が蝕んでいく。" + @name + " は " + @poison.to_s + " のダメージを受け、lifeが " + (@life - @poison).to_s + " に減少。"
			@life = @life - @poison
			@poison = @poison - 1
		end
		if @slackenerPeriod > 0
            @slackenerPeriod = @slackenerPeriod - 1
        end
		@hand.each do |crd|
			@discardPile.append(crd)
		end
		@hand = []
	end
	def draw
		if @deck.length == 0
			@deck = @discardPile.dup.shuffle!
			@discardPile = []
		end
		if @deck.length > 0
			@hand.append(@deck.shift)
		end
	end
	def discard(n)
		@discardPile.append(@hand.delete_at(n))
	end
	def disp
		puts @name + ' [Life ' + @life.to_s + '/' + @maxLife.to_s +  ', Defence ' + @defence.to_s + ', Mana ' + @mana.to_s + '/' + @maxMana.to_s + ', Deck ' + @deck.length.to_s + ', Discard ' + @discardPile.length.to_s + ']'
        if @poison > 0
            puts 'Poisoned Lv ' + @poison.to_s
        end
        if @slackenerPeriod > 0
            puts 'Slackened in ' + @slackenerPeriod.to_s + ' turn'
        end
		i = 0
		@hand.each do |crd|
			i = i + 1
			puts "\t<" + i.to_s + "> " + crd.text
		end
	end
end