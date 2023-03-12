class Cell
	attr_accessor :name, :dispname, :role, :enemyArr
	def initialize(name)
		@name = name
		@dispname = ''
		@role = ''
		@enemyArr = []
		case name
		when 'battle1', 'battle2', 'boss1'
			@dispname = 'battle'
			@role = 'battle'
		when 'safe area1'
			@dispname = 'safe area'
			@role = 'safe area'
		end
		tmpEnemyNameArr = []
		case name
		when 'battle1'
			tmpEnemyNameArr = ['A Ghost']
		when 'battle2'
			tmpEnemyNameArr = ['A Tiny Ghost', 'A Tiny Ghost', 'A Tiny Ghost']
		when 'boss1'
			tmpEnemyNameArr = ['The King of Ghost']
		end
		0.upto(tmpEnemyNameArr.length - 1) do |i|
			@enemyArr.push(Player.new(tmpEnemyNameArr[i]))
		end
	end
end

class Map
	MapNameArr = [
		'Training Center',
		'Forest',
		'Mountain',
		'Cave',
		'Castle',
	]
	attr_accessor :name, :cellArrArr
	def initialize(name)
		@name = name
		@cellArrArr = []
		tmp = []
		case name
		when 'Training Center'
			tmp = [['battle1'], ['battle2'], ['safe area1'], ['boss1']]
		else
			tmp = [['battle1']]
		end
		0.upto(tmp.length - 1) do |i|
			arr = []
			0.upto(tmp[i].length - 1) do |j|
				arr.push(Cell.new(tmp[i][j]))
			end
			@cellArrArr.push(arr)
		end
	end
end
