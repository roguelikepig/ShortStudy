class Player
	attr_accessor :name, :life, :defence, :hand, :mana, :maxMana
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
			@maxLife = 40
			6.times do
				@initDeck.push(Card.new('Sword'))
			end
			4.times do
				@initDeck.push(Card.new('Shield'))
			end
        when 'A Ghost'
			@maxLife = 50
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.push(Card.new('Fire'))
			end
		when 'The King of Ghost'
			@maxLife = 100
			@initMana = 1
			@initNumofHandCard = 0
			@initNumOfDrawCard = 1
			1.times do
				@initDeck.push(Card.new('Fire'))
			end
			1.times do
				@initDeck.push(Card.new('Flame'))
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
		puts "Name: " + @name
		puts "Life: " + @life.to_s
		puts "Defence: " + @defence.to_s
		puts "Deck: " + @deck.length.to_s + " cards"
		puts "Discard: " + @discardPile.length.to_s + " cards"
		puts "Mana: " + @mana.to_s + "/" + @maxMana.to_s
		puts "Hand:"
		i = 0
		@hand.each do |crd|
			i = i + 1
			puts "(" + i.to_s + ") " + crd.text
		end
	end
end

class Card
    attr_accessor :name, :targetType, :targetNum, :cost, :text
    def initialize(name)
		@name = name
		@targetType = ''	#me, player, otherplayer, enemy, both
		@targetNum = '1'	#1,n,all
        @cost = 1
        @atk = 0
        @defence = 0
        @text = ''
	    case name
        when 'Sword'
			@targetType = 'enemy'
            @atk = 10
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'Shield'
			@targetType = 'me'
            @defence = 8
            @text = @name + " [def " + @defence.to_s + "] [" + @cost.to_s + "]"
        when 'Fire'
			@targetType = 'enemy'
            @atk = 10
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'Flame'
			@targetType = 'enemy'
            @atk = 20
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        end
    end
	def play(player, target)
		if @atk != 0
			if target.defence >= @atk
				puts player.name + " が " + target.name + " に " + @atk.to_s + " の攻撃。" + target.name + " は防御が " + target.defence.to_s + " に減少。"
				target.defence = target.defence - @atk
			else
				puts player.name + " が " + target.name + " に " + @atk.to_s + " の攻撃。" + target.name + " は " + (@atk - target.defence).to_s + " のダメージを受けた。"
				target.life = target.life + target.defence - @atk
				target.defence = 0
			end
		end
		if @defence != 0
			puts player.name + " は防御を " + @defence.to_s + " 増加。"
			target.defence = target.defence + @defence
		end
	end
end

class GM
	def battle(plyArr, enmArr)
		#戦闘準備
		enmArr.each do |enm|
			enm.battlePrep
		end
		plyArr.each do |ply|
			ply.battlePrep
		end
		#戦闘開始
		battleEndFlg = ""
		while battleEndFlg == "" do
			flgAllEnemyDead = true
			flgAllPlayerDead = true
			#ターン開始処理
			plyArr.each do |ply|
				ply.turnBegin
			end
			enmArr.each do |enm|
				enm.turnBegin
			end
			#ターン
			plyArr.each do |ply|
				maxHandCardCost = 0
				ply.hand.each do |crd|
					if crd.cost > maxHandCardCost
						maxHandCardCost = crd.cost
					end
				end
				while ply.mana >= maxHandCardCost && ply.hand.length > 0
					#状況表示
					puts "■相手の状況"
					enmArr.each do |enm|
						enm.disp
						puts
					end
					puts "■自分の状況"
					plyArr.each do |ply|
						ply.disp
						puts
					end
					puts "■行動指示: " + ply.name
					puts "Handの番号を入力してください(0→Skip)"
					#入力受付
					strInput = gets.chomp
					#入力解釈
					if strInput == "q"
						battleEndFlg = "forced termination"
						break
					end
					if strInput == "0"
						#ターンエンド
						break
					end
					i = 0
					ply.hand.each do |crd|
						i = i + 1
						if i.to_s == strInput
							if ply.mana >= crd.cost
								ply.mana = ply.mana - crd.cost
								case crd.targetType
								when 'me'
									crd.play(ply, ply)
								when 'enemy'
									#本来はここでターゲットが複数ありうる場合選択する処理が入る
									crd.play(ply, enmArr[0])
								end
								ply.discard(i - 1)
								#勝敗判定
								flgAllEnemyDead = true
								enmArr.each do |enm|
									if enm.life > 0
										flgAllEnemyDead = false
									end
								end
								flgAllPlayerDead = true
								plyArr.each do |ply|
									if ply.life > 0
										flgAllPlayerDead = false
									end
								end
								if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
									break
								end
							end
						end
					end
					if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
						break
					end
					puts
				end
				ply.turnEnd
			end
			if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
				break
			end
			enmArr.each do |enm|
				maxHandCardCost = 0
				enm.hand.each do |crd|
					if crd.cost > maxHandCardCost
						maxHandCardCost = crd.cost
					end
				end
				while enm.mana >= maxHandCardCost && enm.hand.length > 0
					#状況表示
					puts "■相手の状況"
					enmArr.each do |enm|
						enm.disp
						puts
					end
					puts "■自分の状況"
					plyArr.each do |ply|
						ply.disp
						puts
					end
					enm.hand.each do |crd|
						if enm.mana >= crd.cost
							enm.mana = enm.mana - crd.cost
							case crd.targetType
							when 'me'
								crd.play(enm, enm)
							when 'enemy'
								#本来はここでターゲットが複数ありうる場合選択する処理が入る
								crd.play(enm, plyArr[0])
							end
							enm.discard(0)
							#勝敗判定
							flgAllEnemyDead = true
							enmArr.each do |enm|
								if enm.life > 0
									flgAllEnemyDead = false
								end
							end
							flgAllPlayerDead = true
							plyArr.each do |ply|
								if ply.life > 0
									flgAllPlayerDead = false
								end
							end
							if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
								break
							end
						end
					end
					if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
						break
					end
					puts
				end
				enm.turnEnd
			end
			#ターン終了処理
			#勝敗判定
			if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
				break
			end
		end
		if battleEndFlg == ""
			if flgAllEnemyDead == true && flgAllPlayerDead == false
				battleEndFlg = "Player勝利"
			elsif flgAllEnemyDead == false && flgAllPlayerDead == true
				battleEndFlg = "Player敗北"
			elsif flgAllEnemyDead == true && flgAllPlayerDead == true
				battleEndFlg =  "相打ち"
			else
				battleEndFlg "不明"
			end
		end
		puts battleEndFlg
		battleEndFlg
	end
end

#ゲーム初期化
gm = GM.new
#1面
puts "Please defeat A Ghost"
puts "Press ENTER key to continue"
gets
plyArr = []
ply = Player.new("Fighter")
plyArr.push(ply)
enmArr = []
enm = Player.new("A Ghost")
enmArr.push(enm)
if gm.battle(plyArr, enmArr) != "Player勝利"
	puts "再挑戦してください"
	exit
end
#2面
puts "Please defeat The King of Ghost"
puts "Press ENTER key to continue"
gets
enmArr = []
enm = Player.new("The King of Ghost")
enmArr.push(enm)
if gm.battle(plyArr, enmArr) != "Player勝利"
	puts "再挑戦してください"
	exit
end
#クリア
puts "ゲームクリア"
