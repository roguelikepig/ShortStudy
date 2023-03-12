require 'json'
require './map.rb'
require './player.rb'
require './card.rb'

class Account
#	attr_accessor :name, :currentExp, :accumlatedExp, :unlockItemArr, :npcConfigArr, :plyArrOwned, :npcArrOwned, :plyArr, :npcArr, :enmArr, :map, :currentWaveNum, :currentCellNum
	def initialize(name)
		@name = name
		@currentExp = 0
		@accumlatedExp = 0
		@unlockItemArr = []
		@npcConfigArr = []
		@ownedPlayerNameArr = [Player::CharacterNameArrArr[0]]
		@ownedNPCNameArr = []
		@plyArr = []
		@npcArr = []
		@enmArr = []
		@map = nil
		@currentWaveNum = 0
		@currentCellNum = 0
	end
	private def displayScene
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
	private def targeting(ply, targetType)
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
			return @plyArr
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
	#バトル終了条件判定
	#戻り値: String→"", "Player勝利", "Player敗北", "相打ち"
	private def judgeBattleEnd
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
	#バトル処理
	#戻り値: String→"", "Player勝利", "Player敗北", "相打ち"
	private def battle
		#戦闘準備
		#いずれここにNPCが入る
		@enmArr = @map.cellArrArr[@currentWaveNum - 1][@currentCellNum - 1].enemyArr
		@plyArr.each do |ply|
			ply.battlePrep
		end
		@enmArr.each do |enm|
			enm.battlePrep
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
					displayScene
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
								targetArr = targeting(ply, crd.targetType)
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
					displayScene
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
		battleEndFlg
	end
	private def displayMap
		(@currentWaveNum - 1).upto(@map.cellArrArr.length - 1) do |i|
			if i == @currentWaveNum - 1
				puts 'wave ' + (i + 1).to_s + ' <-here now'
			else
				puts 'wave ' + (i + 1).to_s
			end
			0.upto(@map.cellArrArr[i].length - 1) do |j|
				if i == @currentWaveNum - 1 && j + 1 == @currentCellNum
					print '<' + (j + 1).to_s + '>' + @map.cellArrArr[i][j].dispname + ' <-here now '
				else
					print '<' + (j + 1).to_s + '>' + @map.cellArrArr[i][j].dispname + ' '
				end
			end
			puts
		end
	end
	private def startAdventure
		@currentWaveNum = 1
		@currentCellNum = 0
	end
	private def adventure
		startAdventure
		while true
			#マップクリア判定
			if @currentWaveNum > @map.cellArrArr.length
				puts 'Well done! Back to home...'
				puts
				return
			end
			puts '### Map: ' + @map.name + ' ### [ ' + @name + ' ]'
			puts 'Please choose the next cell on the next wave you want to move on to.'
			#マップ全体表示
			displayMap		#自分がいるwave以降のみ表示
			#次選択マス入力受付
			strInput = gets.strip
			puts
			if strInput =~ /^[0-9]+$/
				if strInput.to_i >= 1 && strInput.to_i <= @map.cellArrArr[@currentWaveNum - 1].length
					@currentCellNum = strInput.to_i
					case @map.cellArrArr[@currentWaveNum - 1][@currentCellNum - 1].role
					when 'battle'
						rtn = battle
						#戻り値: String→"", "Player勝利", "Player敗北", "相打ち"
						#勝敗に応じて処理を変える
						case rtn
						when 'Player勝利'
							#勝った場合、カードをもらう
							puts
							puts rtn
							@currentWaveNum = @currentWaveNum + 1
							@currentCellNum = 0
							next
						when 'Player敗北'
							#負けた場合、プレイ結果の統計を表示してホームに戻る
							puts
							puts rtn
							return
						when '相打ち'
							puts
							puts rtn
							return
						when ''
						end
					when 'safe area'
						puts 'safe area'
						puts '未実装'
						@currentWaveNum = @currentWaveNum + 1
						@currentCellNum = 0
						next
				end
				elsif strInput == '0'
					#設定
				end
			end
			puts 'The id you entered is incorrect.'
			puts
		end
	end
	private def finalCheck
		while true
			puts '### Home > Select Character > Select Turret > Select Course > Final Check ### [ ' + @name + ' ]'
			puts "Please let me know if you can depart."
			puts "<1> OK"
			puts '<9> Back to Select Course'
			strInput = gets.strip
			puts
			if strInput =~ /^[0-9]+$/
				if strInput == '1'
					adventure
					return 'back'
				elsif strInput == '9'
					return 'back'
				end
			end
			puts 'The id you entered is incorrect.'
			puts
		end
	end
	private def selectCourse
		while true
			puts '### Home > Select Character > Select Turret > Select Course ### [ ' + @name + ' ]'
			puts "Please choose course(s) you are going to dive into."
			i = 0
			Map::MapNameArr.each do |mapName|
				i = i + 1
				print '<' + i.to_s + '> ' + mapName
				puts
			end
			puts '<9> Back to Select Turret'
			strInput = gets.strip
			puts
			if strInput =~ /^[0-9]+$/
				if strInput.to_i <= Map::MapNameArr.length
					@map = Map.new(Map::MapNameArr[strInput.to_i - 1])
					if finalCheck == 'back'
						next
					end
					break
				elsif strInput == '9'
					return 'back'
				end
			end
			puts 'The id you entered is incorrect.'
			puts
		end
	end
	private def selectNPC
		while true
			puts '### Home > Select Character > Select Turret ### [ ' + @name + ' ]'
			puts "Please choose your turret(s) that will fight with you."
			puts '<0> No turret'
			1.upto(@ownedNPCNameArr.length) do |i|
				print '<' + i.to_s + '> '
				j = 0
				@ownedNPCNameArr[i - 1].each do |name|
					if j > 0
						print ', '
					end
					print name
					j = j + 1
				end
				puts
			end
			puts '<9> Back to Select Character'
			strInput = gets.strip
			puts
			if strInput =~ /^[0-9]+$/
				if strInput == '0'
					@npcArr = []
					if selectCourse == 'back'
						next
					end
				elsif strInput == '9'
					return 'back'
				elsif strInput.to_i <= @ownedNPCNameArr.length
					@npcArr = Player.createNPCArr(@ownedNPCNameArr[strInput.to_i - 1][0])
					if selectCourse == 'back'
						next
					end
					break
				end
			end
			puts 'The id you entered is incorrect.'
			puts
		end
	end
	private def selectCharacter
		while true
			puts '### Home > Select Character ### [ ' + @name + ' ]'
			puts "Please choose your character(s)."
			1.upto(@ownedPlayerNameArr.length) do |i|
				print '<' + i.to_s + '> '
				j = 0
				@ownedPlayerNameArr[i - 1].each do |name|
					if j > 0
						print ', '
					end
					print name
					j = j + 1
				end
				puts
			end
			puts '<9> Back to Home'
			strInput = gets.strip
			puts
			if strInput =~ /^[0-9]+$/
				if strInput.to_i <= @ownedPlayerNameArr.length
					@plyArr = Player.createCharacterArr(@ownedPlayerNameArr[strInput.to_i - 1][0])
					if selectNPC == 'back'
						next
					end
					break
				elsif strInput == '9'
					break
				end
			end
			puts 'The id you entered is incorrect.'
			puts
		end
	end
	def homeMenu
		while true
			puts '### Home ### [ ' + @name + ' ]'
			puts 'Please choose item from the menu below.'
			puts '<1> Go to Battle'
			puts '<2> Skill Tree'
			puts '<3> NPC Config'
			puts '<4> Confirm Account Info'
			puts '<5> Save'
			puts '<9> Back to Opening'
			strInput = gets.strip
			puts
			case strInput
			when '1'
				selectCharacter
			when '2'
			when '3'
			when '4'
			when '5'
			when '9'
				break
			else
				puts 'The id you entered is incorrect.'
				puts
			end
		end
	end
end

def readSaveFile(path)
	account = nil
	File.open(path) do |f|
		begin
			hashSaveData = JSON.load(f)
			name = hashSaveData['name']
			if name =~ /^[0-9a-zA-Z]+$/ && name.length <= 24
				account = Account.new(name)
				#ここでセーブデータの中身を読み取りaccountに設定する
			else
				account = nil
			end
		rescue JSON::ParserError
			account = nil
		end
	end
	account
end

#Main loop
while true
	puts '### Opening ###'
	puts 'Please choose item from the menu below.'
	puts '<1> New Game'
	puts '<2> Load Game'
	#puts '<3> Settings'
	puts '<9> Quit'
	strInput = gets.strip
	puts
	case strInput
	when '1'
		#新規アカウント
		while true
			puts 'Please enter your name with up to 24 characters [0-9a-zA-Z].'
			strInput = gets.strip
			puts
			if strInput =~ /^[0-9a-zA-Z]+$/
				account = Account.new(strInput)
				break
			else
				puts 'Invalid string...'
				puts
			end
		end
		account.homeMenu
	when '2'
		#saveフォルダの有無を確認
		if Dir.exist?('./save')
			#saveフォルダ内のファイルリストをidとともに出力
			#idを選ばせる
			cnt = 0
			saveFileArr = []
			Dir.foreach('./save') do |f|
				next if f == '.' or f == '..'
				puts '<' + (cnt + 1).to_s + '> ' + f
				saveFileArr.append(f)
				cnt = cnt + 1
			end
			if cnt == 0
				puts "No files exist in the 'save' directory. Failed to load saved data."
				puts
			else
				puts
				puts 'Please choose save file <id> to open and start game.'
				strInput = gets.strip
				puts
				fileFoundFlg = false
				cnt.times do |n|
					if strInput == (n + 1).to_s
						fileFoundFlg = true
						account = readSaveFile('./save/' + saveFileArr[n])
						if account == nil
							puts "'" + saveFileArr[n] + "' is corrupt or cannot to read... Very sorry."
							puts
						else
							account.homeMenu
						end
					end
				end
				if fileFoundFlg == false
					puts 'The id you entered is incorrect.'
					puts
				end
			end
		else
			puts "The 'save' directory did not exist. Failed to load saved data."
			puts
		end
	when '9'
		exit
	else
		puts 'The id you entered is incorrect.'
		puts
	end
end
