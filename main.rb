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
				@initDeck.push(Card.new('CandleFlame'))
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

class Card
    attr_accessor :name, :targetType, :cost, :text
    def initialize(name)
		@name = name
		@targetType = ''	#me, player, allplayer, otherplayer, allotherplayer, enemy, allenemy, allother, all, card
        @cost = 1
        @atk = 0
        @defence = 0
		@heal = 0
        @text = ''
	    case name
        when 'Sword'
			@targetType = 'enemy'
            @atk = 10
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'Wand'
			@targetType = 'enemy'
            @atk = 3
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'Shield'
			@targetType = 'me'
            @defence = 8
            @text = @name + " [def " + @defence.to_s + "] [" + @cost.to_s + "]"
        when 'MercyLight'
			@targetType = 'otherplayer'
            @heal = 10
			@cost = 2
            @text = @name + " [heal " + @heal.to_s + "] [" + @cost.to_s + "]"
        when 'CandleFlame'
			@targetType = 'enemy'
            @atk = 6
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'Flame'
			@targetType = 'enemy'
            @atk = 12
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'HellFlame'
			@targetType = 'enemy'
            @atk = 20
            @text = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        end
    end
	def play(player, targetArr)
		targetArr.each do |target|
			if @atk != 0
				#死者はスキップ
				if target.life > 0
					if target.defence >= @atk
						puts player.name + " が " + target.name + " に " + @atk.to_s + " の攻撃。" + target.name + " は防御が " + (target.defence - @atk).to_s + " に減少。"
						target.defence = target.defence - @atk
					else
						puts player.name + " が " + target.name + " に " + @atk.to_s + " の攻撃。" + target.name + " のlifeは " + (target.life + target.defence - @atk).to_s + " に減少。"
						target.life = target.life + target.defence - @atk
						target.defence = 0
					end
				end
			end
			if @defence != 0
				puts player.name + " は防御を " + @defence.to_s + " 増加。"
				target.defence = target.defence + @defence
			end
			if @heal != 0
				#死者はスキップ
				#既にターゲットのlifeが最大値になっていればスキップ
				if target.life > 0 && target.life < target.maxLife
					if target.life + @heal > target.maxLife
						puts player.name + " が " + target.name + " のlifeを " + (target.maxLife - target.life).to_s + " 回復し、lifeは " + target.maxLife.to_s + " になった。"
						target.life = target.maxLife
					else
						puts player.name + " が " + target.name + " のlifeを " + @heal.to_s + " 回復し、lifeは " + (target.life + @heal).to_s + " になった。"
						target.life = target.life + @heal
					end
				end
			end
		end
	end
end

class GM
	def displayScene(plyArr, enmArr)
		puts "■相手の状況"
		i = 0
		enmArr.each do |enm|
			print "<" + dec_to_a(i) + "> "
			enm.disp
			puts
			i = i + 1
		end
		puts "■自分の状況"
		i = 0
		plyArr.each do |ply|
			print "<" + dec_to_A(i) + "> "
			ply.disp
			puts
			i = i + 1
		end
	end
	private def dec_to_a(num)	#0->a, 25->z
		(num > 25 ? dec26(num / 26) : '') + ('a'.ord + num % 26).chr
	end
	private def dec_to_A(num)	#0->A, 25->Z
		(num > 25 ? dec26(num / 26) : '') + ('A'.ord + num % 26).chr
	end
	def targeting(ply, plyArr, enmArr, targetType)
		#まず入力なしで特定できるケースを先に終わらせる
		#@targetType = ''	#me, player, allplayer, otherplayer, allotherplayer, enemy, allenemy, allother, all, card
		case targetType
		when "me"
			return [ply]
		when "player"
			if plyArr.length == 1
				return [plyArr[0]]
			elsif plyArr.length == 2
				if plyArr[0] == ply
					return [plyArr[1]]
				elsif plyArr[1] == ply
					return [plyArr[0]]
				else
					puts "fatal error in targeting"
					exit
				end
			end
		when "allplayer"
			return plyarr
		when "otherplayer"
			if plyArr.length == 1
				#otherplayerが存在しない
				return nil
			elsif plyArr.length == 2
				if plyArr[0] == ply
					return [plyArr[1]]
				elsif plyArr[1] == ply
					return [plyArr[0]]
				else
					puts "fatal error in targeting"
					exit
				end
			end
		when "allotherplayer"
			if plyArr.length == 1
				#otherplayerが存在しない
				return nil
			elsif plyArr.length == 2
				if plyArr[0] == ply
					return [plyArr[1]]
				elsif plyArr[1] == ply
					return [plyArr[0]]
				else
					puts "fatal error in targeting"
					exit
				end
			else
				rtn = []
				plyArr.each do |player|
					if player != ply
						rtn.append(player)
					end
				end
				return rtn
			end
		when "enemy"
			if enmArr.length == 1
				return [enmArr[0]]
			end
		when "allenemy"
			return enmArr
		when "allother"
			rtn = []
			plyArr.each do |player|
				if player != ply
					rtn.append(player)
				end
			end
			enmArr.each do |e|
				rtn.append(e)
			end
			return rtn
		when "all"
			rtn = []
			plyArr.each do |player|
				rtn.append(player)
			end
			enmArr.each do |e|
				rtn.append(e)
			end
			return rtn
		end
		#入力必要なケース
		rtn = []
		puts "プレイしたいカードの対象<id>を入力してください"
		strInput = gets.strip
		case strInput
		when /^[0-9]+$/
			if targetType == "card"
				i = 0
				ply.hand.each do |crd|
					i = i + 1
					if i.to_s == strInput
						rtn.append(crd)
					end
				end
			end
		when /^[a-z]+$/
			if targetType == "enemy"
				i = 0
				enmArr.each do |enm|
					if dec_to_a(i).to_s == strInput
						rtn.append(enm)
					end
					i = i + 1
				end
			end
		when /^[A-Z]+$/
			if targetType == "player"
				i = 0
				plyArr.each do |player|
					if dec_to_A(i).to_s == strInput
						rtn.append(player)
					end
					i = i + 1
				end
			elsif targetType == "otherplayer"
				i = 0
				plyArr.each do |player|
					if player != ply
						if dec_to_A(i).to_s == strInput
							rtn.append(player)
						end
					end
					i = i + 1
				end
			end
		end
		if rtn.length == 0
			return nil
		else
			return rtn
		end
	end
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
				while ply.mana >= maxHandCardCost && ply.hand.length > 0 && ply.life > 0
					self.displayScene(plyArr, enmArr)
					puts "■行動指示: " + ply.name
					puts "プレイするHandの<id>を入力してください(0→Skip)"
					#入力受付
					strInput = gets.strip
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
								targetArr = self.targeting(ply, plyArr, enmArr, crd.targetType)
								if targetArr != nil
									ply.mana = ply.mana - crd.cost
									crd.play(ply, targetArr)
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
								else
									puts "有効な対象指定がなされなかったためカードプレイをスキップします"
								end
							end
						end
					end
					if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
						break
					end
					puts
					maxHandCardCost = 0
					ply.hand.each do |crd|
						if crd.cost > maxHandCardCost
							maxHandCardCost = crd.cost
						end
					end
				end
				if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
					break
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
				while enm.mana >= maxHandCardCost && enm.hand.length > 0 && enm.life > 0
					self.displayScene(plyArr, enmArr)
					enm.hand.each do |crd|
						if enm.mana >= crd.cost
							enm.mana = enm.mana - crd.cost
							case crd.targetType
							when 'me'
								crd.play(enm, [enm])
							when 'enemy'
								#本来はここでターゲットが複数ありうる場合選択する処理が入る
								crd.play(enm, [plyArr[0]])
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
					maxHandCardCost = 0
					enm.hand.each do |crd|
						if crd.cost > maxHandCardCost
							maxHandCardCost = crd.cost
						end
					end
				end
				if battleEndFlg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
					break
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
plyArr = []
plyArr.push(Player.new("Fighter"))
plyArr.push(Player.new("Healer"))
#1面
puts
puts
puts "Please defeat A Ghost"
puts "Press ENTER key to continue"
gets
enmArr = []
enmArr.push(Player.new("A Ghost"))
if gm.battle(plyArr, enmArr) != "Player勝利"
	puts "再挑戦してください"
	exit
end
#2面
puts
puts
puts "Please defeat Tiny Ghosts"
puts "Press ENTER key to continue"
gets
enmArr = []
3.times do
	enmArr.push(Player.new("A Tiny Ghost"))
end
if gm.battle(plyArr, enmArr) != "Player勝利"
	puts "再挑戦してください"
	exit
end
#3面
puts
puts
puts "Please defeat The King of Ghost"
puts "Press ENTER key to continue"
gets
enmArr = []
enmArr.push(Player.new("The King of Ghost"))
if gm.battle(plyArr, enmArr) != "Player勝利"
	puts "再挑戦してください"
	exit
end
#クリア
puts "ゲームクリア"
