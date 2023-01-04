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
