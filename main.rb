require './player.rb'
require './card.rb'
require './gm.rb'

#ゲーム初期化
gm = GM.new
plyArr = []
plyArr.push(Player.new("Fighter"))
#plyArr.push(Player.new("Healer"))
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
