class Player
	attr_accessor :name, :life, :defence, :hand, :mana, :maxmana
	def initialize(name)
		@name = name
		@maxlife = 0
		@defence = 0
		@initmana = 3	#戦闘開始時のマナ数
		@initdeck = []
		@deck = []
		@hand = []
		@discardpile = []
		@initnumofhandcard = 0
		@initnumofdrawcard = 4
	    case name
        when 'fighter'
			@maxlife = 100
			6.times do
				@initdeck.push(Card.new('sword'))
			end
			4.times do
				@initdeck.push(Card.new('shield'))
			end
        when 'ghost'
			@maxlife = 100
			@initmana = 1
			@initnumofhandcard = 0
			@initnumofdrawcard = 1
			1.times do
				@initdeck.push(Card.new('fire'))
			end
		end
		@life = @maxlife
	end
	def battleprep
		@maxmana = @initmana	#戦闘中でターン開始時のマナ数
		@mana = @maxmana
		@deck = @initdeck.dup
		@numofhandcard = @initnumofhandcard
		@numofdrawcard = @initnumofdrawcard
		@deck.shuffle!
		@discardpile = []
		@numofhandcard.times do
			self.draw
		end
	end
	def turnbegin
		@mana = @maxmana
		@defence = 0
		@numofdrawcard.times do
			self.draw
		end
	end
	def turnend
		@hand.each do |crd|
			@discardpile.push(crd)
		end
		@hand = []
	end
	def draw
		if @deck.length == 0
			@deck = @discardpile.dup.shuffle!
			@discardpile = []
		end
		if @deck.length > 0
			@hand.push(@deck.shift)
		end
	end
	def discard(n)
		@discardpile.push(@hand.delete_at(n))
	end
	def disp
		puts "name: " + @name
		puts "life: " + @life.to_s
		puts "defence: " + @defence.to_s
		puts "deck: " + @deck.length.to_s + " cards"
		puts "discard: " + @discardpile.length.to_s + " cards"
		puts "mana: " + @mana.to_s + "/" + @maxmana.to_s
		puts "hand:"
		i = 0
		@hand.each do |crd|
			i = i + 1
			puts "(" + i.to_s + ") " + crd.strdisp
		end
	end
end

class Card
    attr_accessor :name, :targettype, :targetnum, :cost, :strdisp
    def initialize(name)
		@name = name
		@targettype = ''	#me, player, otherplayer, enemy, both
		@targetnum = '1'	#1,n,all
        @cost = 1
        @atk = 0
        @defence = 0
        @strdisp = ''
	    case name
        when 'sword'
			@targettype = 'enemy'
            @atk = 10
            @strdisp = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
        when 'shield'
			@targettype = 'me'
            @defence = 5
            @strdisp = @name + " [def " + @defence.to_s + "] [" + @cost.to_s + "]"
        when 'fire'
			@targettype = 'enemy'
            @atk = 7
            @strdisp = @name + " [atk " + @atk.to_s + "] [" + @cost.to_s + "]"
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

#ゲーム初期化
plyarr = []
ply = Player.new("fighter")
plyarr.push(ply)
enmarr = []
enm = Player.new("ghost")
enmarr.push(enm)
#戦闘準備
enmarr.each do |enm|
	enm.battleprep
end
plyarr.each do |ply|
	ply.battleprep
end
#戦闘開始
battleendflg = ""
while battleendflg == "" do
	flgAllEnemyDead = true
	flgAllPlayerDead = true
	plyarr.each do |ply|
		#ターン開始処理
		#mana回復
		ply.turnbegin
		maxhandcardcost = 0
		ply.hand.each do |crd|
			if crd.cost > maxhandcardcost
				maxhandcardcost = crd.cost
			end
		end
		while ply.mana >= maxhandcardcost && ply.hand.length > 0
			#状況表示
			puts "■相手の状況"
			enmarr.each do |enm|
				enm.disp
				puts
			end
			puts "■自分の状況"
			plyarr.each do |ply|
				ply.disp
				puts
			end
			puts "■行動指示: " + ply.name
			puts "handの番号を入力してください(0→Skip)"
			#入力受付
			strInput = gets.chomp
			#入力解釈
			if strInput == "q"
				battleendflg = "forced termination"
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
						case crd.targettype
						when 'me'
							crd.play(ply, ply)
						when 'enemy'
							#本来はここでターゲットが複数ありうる場合選択する処理が入る
							crd.play(ply, enm)
						end
						ply.discard(i - 1)
						#勝敗判定
						flgAllEnemyDead = true
						enmarr.each do |enm|
							if enm.life > 0
								flgAllEnemyDead = false
							end
						end
						flgAllPlayerDead = true
						plyarr.each do |ply|
							if ply.life > 0
								flgAllPlayerDead = false
							end
						end
						if battleendflg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
							break
						end
					end
				end
			end
			if battleendflg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
				break
			end
			puts
		end
		ply.turnend
	end
	if battleendflg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
		break
	end
	enmarr.each do |enm|
		#ターン開始処理
		#mana回復
		enm.turnbegin
		maxhandcardcost = 0
		enm.hand.each do |crd|
			if crd.cost > maxhandcardcost
				maxhandcardcost = crd.cost
			end
		end
		while enm.mana >= maxhandcardcost && enm.hand.length > 0
			#状況表示
			puts "■相手の状況"
			enmarr.each do |enm|
				enm.disp
				puts
			end
			puts "■自分の状況"
			plyarr.each do |ply|
				ply.disp
				puts
			end
			enm.hand.each do |crd|
				if enm.mana >= crd.cost
					enm.mana = enm.mana - crd.cost
					case crd.targettype
					when 'me'
						crd.play(enm, enm)
					when 'enemy'
						#本来はここでターゲットが複数ありうる場合選択する処理が入る
						crd.play(enm, ply)
					end
					enm.discard(0)
					#勝敗判定
					flgAllEnemyDead = true
					enmarr.each do |enm|
						if enm.life > 0
							flgAllEnemyDead = false
						end
					end
					flgAllPlayerDead = true
					plyarr.each do |ply|
						if ply.life > 0
							flgAllPlayerDead = false
						end
					end
					if battleendflg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
						break
					end
				end
			end
			if battleendflg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
				break
			end
			puts
		end
		enm.turnend
	end
	#ターン終了処理
	#勝敗判定
	if battleendflg != "" || flgAllEnemyDead == true || flgAllPlayerDead == true
		break
	end
end
if battleendflg != ""
	puts battleendflg
elsif flgAllEnemyDead == true && flgAllPlayerDead == false
	puts "Player勝利"
elsif flgAllEnemyDead == false && flgAllPlayerDead == true
	puts "Player敗北"
elsif flgAllEnemyDead == true && flgAllPlayerDead == true
	puts "相打ち"
end
