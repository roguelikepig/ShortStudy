require './player.rb'
require './card.rb'
require './gm.rb'

#ゲーム初期化
experience = 0
startCharacterNameArr = [
	["Fighter"],
	["Healer"],
#	["TestPlayer"],
]
enemySetArr = [	#いずれGMにわたすものは敵リストだけでなく、マップ・ルートも含めたシナリオのようなものに置き換わっていく
	["A Ghost"],
	[
		"A Tiny Ghost", 
		"A Tiny Ghost", 
		"A Tiny Ghost"
	],
	["The King of Ghost"],
]
gm = GM.new(startCharacterNameArr, enemySetArr)
experience = gm.startGame

