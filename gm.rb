class GM
	attr_accessor :plyArr, :enmArr
	def initialize(startCharacterNameArr, enemySetArr)
		@startCharacterNameArr = startCharacterNameArr
		@enemySetArr = enemySetArr
		@plyArr = []
		@enmArr = []
	end
	def startGame
		#プレイヤーキャラクター選択
		puts "Please choose your Character(s)."
		i = 0
		@startCharacterNameArr.each do |chrNameArr|
			i = i + 1
			print '(' + i.to_s + ') '
			j = 0
			chrNameArr.each do |chrName|
				if j > 0
					print ', '
				end
				print chrName
				j = j + 1
			end
			puts
		end
		puts
		strInput = gets.strip
		if strInput =~ /^[0-9]+$/
			if @startCharacterNameArr.length >= strInput.to_i
				@startCharacterNameArr[strInput.to_i - 1].each do |chrName|
					@plyArr.append(Player.new(chrName))
				end
			end
		end
		if @plyArr.length == 0
			puts "プレイヤーキャラクター選択が正しくありませんでした。やり直してください"
			exit
		end
		print "You choice is "
		i = 0
		@plyArr.each do |ply|
			if i > 0
				print ', '
			end
			print ply.name
			i = i + 1
		end
		puts
		puts "Good luck."
		#ステージループ
		i = 0
		@enemySetArr.each do |enmNameArr|
			@enmArr = []
			i = i + 1
			puts
			puts "Stage #" + i.to_s
			print "Please defeat "
			j = 0
			enmNameArr.each do |enmName|
				if j > 0
					print ', '
				end
				print enmName
				@enmArr.append(Player.new(enmName))
				j = j + 1
			end
			puts
			puts
			if self.battle != "Player勝利"
				puts "再挑戦してください"
				exit
			end
		end
		#クリア
		puts
		puts "You have completed your mission."
		return i - 1
	end
	def displayScene
		puts "#Enemy"
		i = 0
		@enmArr.each do |enm|
			print "<" + dec_to_a(i) + "> "
			enm.disp
			puts
			i = i + 1
		end
		puts "#You"
		i = 0
		@plyArr.each do |ply|
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
	def targeting(ply, targetType)
		#まず入力なしで特定できるケースを先に終わらせる
		#@targetType = ''	#me, player, allplayer, otherplayer, allotherplayer, enemy, allenemy, allother, all, card
		case targetType
		when "me"
			return [ply]
		when "player"
			if @plyArr.length == 1
				return [@plyArr[0]]
			elsif @plyArr.length == 2
				if @plyArr[0] == ply
					return [@plyArr[1]]
				elsif @plyArr[1] == ply
					return [@plyArr[0]]
				else
					puts "fatal error in targeting"
					exit
				end
			end
		when "allplayer"
			return @plyarr
		when "otherplayer"
			if @plyArr.length == 1
				#otherplayerが存在しない
				return nil
			elsif @plyArr.length == 2
				if @plyArr[0] == ply
					return [@plyArr[1]]
				elsif @plyArr[1] == ply
					return [@plyArr[0]]
				else
					puts "fatal error in targeting"
					exit
				end
			end
		when "allotherplayer"
			if @plyArr.length == 1
				#otherplayerが存在しない
				return nil
			elsif @plyArr.length == 2
				if @plyArr[0] == ply
					return [@plyArr[1]]
				elsif @plyArr[1] == ply
					return [@plyArr[0]]
				else
					puts "fatal error in targeting"
					exit
				end
			else
				rtn = []
				@plyArr.each do |player|
					if player != ply
						rtn.append(player)
					end
				end
				return rtn
			end
		when "enemy"
			if @enmArr.length == 1
				return [@enmArr[0]]
			end
		when "allenemy"
			return @enmArr
		when "allother"
			rtn = []
			@plyArr.each do |player|
				if player != ply
					rtn.append(player)
				end
			end
			@enmArr.each do |enemy|
				rtn.append(enemy)
			end
			return rtn
		when "all"
			rtn = []
			@plyArr.each do |player|
				rtn.append(player)
			end
			@enmArr.each do |enemy|
				rtn.append(enemy)
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
				@enmArr.each do |enm|
					if dec_to_a(i).to_s == strInput
						rtn.append(enm)
					end
					i = i + 1
				end
			end
		when /^[A-Z]+$/
			if targetType == "player"
				i = 0
				@plyArr.each do |player|
					if dec_to_A(i).to_s == strInput
						rtn.append(player)
					end
					i = i + 1
				end
			elsif targetType == "otherplayer"
				i = 0
				@plyArr.each do |player|
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
	#バトル処理
	#戻り値: String→"", "Player勝利", "Player敗北", "相打ち"
	def battle
		#戦闘準備
		@enmArr.each do |enm|
			enm.battlePrep
		end
		@plyArr.each do |ply|
			ply.battlePrep
		end
		#戦闘開始
		battleEndFlg = ""
		while battleEndFlg == "" do
			#ターン開始処理
			@plyArr.each do |ply|
				ply.turnBegin
			end
			@enmArr.each do |enm|
				enm.turnBegin
			end
			#ターン
			@plyArr.each do |ply|
				minHandCardCost = 10000
				ply.hand.each do |crd|
					if crd.cost < minHandCardCost
						minHandCardCost = crd.cost
					end
				end
				while ply.mana >= minHandCardCost && ply.hand.length > 0 && ply.life > 0
					self.displayScene
					puts "■行動指示: " + ply.name
					puts "プレイするHandの<id>を入力してください(0→Skip)"
					#入力受付
					strInput = gets.strip
					#入力解釈
					if strInput == "0"
						#ターンエンド
						break
					end
					i = 0
					ply.hand.each do |crd|
						i = i + 1
						if i.to_s == strInput
							if ply.mana >= crd.cost
								targetArr = self.targeting(ply, crd.targetType)
								if targetArr != nil
									ply.mana = ply.mana - crd.cost
									crd.play(ply, targetArr)
									ply.discard(i - 1)
									#勝敗判定
									(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
									break if battleEndFlg != ""
								else
									puts "有効な対象指定がなされなかったためカードプレイをスキップします"
								end
							end
						end
					end
					#勝敗判定
					(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
					break if battleEndFlg != ""
					puts
					minHandCardCost = 10000
					ply.hand.each do |crd|
						if crd.cost < minHandCardCost
							minHandCardCost = crd.cost
						end
					end
				end
				#勝敗判定
				(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
				break if battleEndFlg != ""
				ply.turnEnd
				#勝敗判定
				(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
				break if battleEndFlg != ""
			end
			#勝敗判定
			(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
			break if battleEndFlg != ""
			@enmArr.each do |enm|
				minHandCardCost = 10000
				enm.hand.each do |crd|
					if crd.cost < minHandCardCost
						minHandCardCost = crd.cost
					end
				end
				while enm.mana >= minHandCardCost && enm.hand.length > 0 && enm.life > 0
					self.displayScene
					enm.hand.each do |crd|
						if enm.mana >= crd.cost
							enm.mana = enm.mana - crd.cost
							case crd.targetType
							when 'me'
								crd.play(enm, [enm])
							when 'enemy'
								#本来はここでターゲットが複数ありうる場合選択する処理が入る
								crd.play(enm, [@plyArr[0]])
							end
							enm.discard(0)
							#勝敗判定
							(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
							break if battleEndFlg != ""
						end
					end
					#勝敗判定
					(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
					break if battleEndFlg != ""
					puts
					minHandCardCost = 10000
					enm.hand.each do |crd|
						if crd.cost < minHandCardCost
							minHandCardCost = crd.cost
						end
					end
				end
				#勝敗判定
				(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
				break if battleEndFlg != ""
				enm.turnEnd
				#勝敗判定
				(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
				break if battleEndFlg != ""
			end
			#勝敗判定
			(battleEndFlg = judgeBattleEnd) if battleEndFlg == "" 
			break if battleEndFlg != ""
		end
		puts battleEndFlg
		battleEndFlg
	end
	#バトル終了条件判定
	#戻り値: String→"", "Player勝利", "Player敗北", "相打ち"
	def judgeBattleEnd
		battleEndFlg = ""
		flgAllEnemyDead = true
		@enmArr.each do |enm|
			if enm.life > 0
				flgAllEnemyDead = false
			end
		end
		flgAllPlayerDead = true
		@plyArr.each do |ply|
			if ply.life > 0
				flgAllPlayerDead = false
			end
		end
		if flgAllEnemyDead == true && flgAllPlayerDead == false
			battleEndFlg = "Player勝利"
		elsif flgAllEnemyDead == false && flgAllPlayerDead == true
			battleEndFlg = "Player敗北"
		elsif flgAllEnemyDead == true && flgAllPlayerDead == true
			battleEndFlg = "相打ち"
		else
			battleEndFlg = ""
		end
		battleEndFlg
	end
end