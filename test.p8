pico-8 cartridge // http://www.pico-8.com
version 43
__lua__
function _init()
	version="0.2.1"
	screen = "menu"
	--screen="initial"
	initial_lifes=9
	initial_enemylife=10
	initial_discards=1
	position=user_positions[1]
	enemymove=1
	enemydebuff=1
	current_enemy=1
	bag_max_size=6
	last_boss=3
	still_alive=true
	powerup=""
	change_to_game=false
	cls(0)
	palt(0,false) 
	palt(11,true)
	animations={}
	music(0)
	add(animations,{timer=30,name="intro"})
end

function _draw()
	if screen=="menu" then
		loadintro()
		end
	if screen=="initial" then
		initialsetup()
		screen="game"
		end
	if screen=="game" then
		loadmainscene()
		end
	if screen=="finishedgame" then
		finishedscene(still_alive)
		end
	if screen=="showinfo" and position==user_positions[3] then
		showinfo(defuffs_texts[enemydebuff])
		end
end

function _update()
-- for i=0,5 do
-- 	if(btnp(i)) then
--   --debug text
-- 	end
-- end
 if btnp(button_accept) and screen=="menu" then
		screen="initial"
	end
	if btnp(button_accept) and screen=="finishedgame" then
		if current_enemy<last_boss then
		 if(still_alive) then
				setupnewround()
				change_to_game=true
			else
			 add(animations,{timer=30,name="intro"})
				screen="menu"
			end
		else
		 add(animations,{timer=30,name="intro"})
		 screen="menu"
		end
	end
	if(not btnp(button_accept) and change_to_game==true and screen=="finishedgame") then
		--this avoids missclic in starting hand
		change_to_game=false
		screen="game"
	end
 if(screen=="game" or screen=="showinfo") then
	 currentpositionelected()
 end
 --animations handler
 for anim in all(animations) do
  anim.timer -= 1
  if anim.timer <= 0 then
   del(animations, anim)
  end
 end
end

function getanimtimer(name)
 for anim in all(animations) do
  if anim.name == name then
   return anim.timer
  end
 end
end
-->8
--dawing functions
function drawhand(hand,x,y)
	if cardinhandselected == 1 and position==user_positions[2] then
			drawcard(deck[hand[1]],35,80)
			drawhint(deck[hand[1]].move+1,39,97)
		else
			drawcard(deck[hand[1]],35,90)
		end
	if cardinhandselected == 2 and position==user_positions[2] then
			drawcard(deck[hand[2]],55,80)
			drawhint(deck[hand[2]].move+1,59,97)
		else
			drawcard(deck[hand[2]],55,90)
		end
	if cardinhandselected == 3 and position==user_positions[2] then
			drawcard(deck[hand[3]],75,80)
			drawhint(deck[hand[3]].move+1,79,97)
		else
			drawcard(deck[hand[3]],75,90)
		end
	if cardinhandselected == 4 and position==user_positions[2] then
		print("\#0"..#deck_todraw.." left",95,82,7)
		end
	if cardinhandselected==0 and position==user_positions[2] then
  spr(36,14,106)
  if(btn(button_secondary)) then
   showdiscardpile()
   end
		end		 
end

function drawkeybinds()
 if (position==user_positions[3]) then
  drawblackbox(2)
  print(button_accept_s.." see",1,117,7)
  print("⬇️ back",1,123,7)
  return
  end
 if (position==user_positions[4]) then
  drawblackbox(2)
  print(button_accept_s.." use",1,117,7)
  print("⬆️ back",1,123,7)
  return
  end
	if (cardinhandselected>0 and cardinhandselected <4) then
  drawblackbox(3)
  print(button_accept_s.." play",1,111,7)
  print(button_secondary_s.." dis ("..discards_remaining..")",1,117,7)
  print("⬇️ bag",1,123,7)
  end
 if cardinhandselected==0 then
 	drawblackbox(2)
  print(button_secondary_s.." show",1,117,7)
  print("⬆️ debuff",1,123,7)
  end
end

function drawblackbox(rows)
 box_y={122,116,110,104}
 rectfill(0,box_y[rows],45,127)
end

function drawmap()
map(0,0,0,0,16,16)
end

function drawlife(life)
	spr(8,110,60,2,2)
	print(life,116,66,0)
	--drawing losing lives
	drawlosinglive()
end

function drawcard(card,x,y)
	local colorbyvalue={11,10,8}
	spr(6,x,y,2,2)
	spr(card.move*2,x,y,2,2)
	circfill(x+1,y+2,3,colorbyvalue[card.value])
	print(card.value+extra_power,x,y,0)
end

function drawhint(user,x,y)
 local result = calculatewinmove(user,enemymove)
 if(result=="win") then
 	spr(196,x,y)
 	end
 if(result=="lose") then
 	spr(197,x,y)
 	end
 if(result=="tie") then
 	spr(198,x,y)
 	end
 if(result=="invalid") then
  spr(199,x,y)
  end
end

function drawenemy(enemy)
	x=32
	y=15
	local timer=getanimtimer("enemylosinglives")
 if(timer!=nil) then
  local anim_x = x - (timer%4)
  --drawing arms
  sspr(96,32,16,32,anim_x-16,y,32,64)
		sspr(96,32,16,32,anim_x+48,y,32,64,true)
		--drawing face
		sspr(enemies[enemy].mask,32,32,16,anim_x,y,64,32)
		sspr(enemies[enemy].face,48,32,16,anim_x,y+32,64,32)
 else
		--drawing arms
		armposition=y+(6+5*(flr(time() * 2) % 2))
		sspr(96,32,16,32,x-16,armposition,32,64)
		sspr(96,32,16,32,x+48,armposition,32,64,true)
		--drawing face
		headposition=(2*(flr(time() * 2) % 2))
		sspr(enemies[enemy].mask,32,32,16,x,y+headposition,64,32)
		sspr(enemies[enemy].face,48,32,16,x,y+headposition+32,64,32)
		end
	--drawing moves
	drawenemymove()
	--drawing life
	drawenemylife()
	--drawing debuffs
	drawenemydebuffs()
	--animation changing move
	drawchangeenemymove()
end

function drawenemymove()
	local spr_texture = move_sprite[enemymove]
	circfill(15,35,10,6)
	spr(spr_texture,8,27,2,2,false,true)
	circ(15,35,10,0)
end

function drawenemydebuffs()
	local spr_texture = debuffs_sprites[enemydebuff]
	circfill(112,35,10,6)
	if(enemydebuff==2) then
		local blocked_move=(((enemymove+1)%3)+1)
		spr(move_sprite[blocked_move],105,27,2,2)
	 end
	spr(spr_texture,105,28,2,2)
	circ(112,35,10,0)
	if(position==user_positions[3]) then
	 circ(112,35,11,7)
	 circ(112,35,12,7)
	 end
end

function drawenemylife()
 local timer=getanimtimer("enemylosinglives")
 if(timer!=nil) then
  pal(8,1)
 end
	for i=1,enemylife do
		spr(35,10+(i*9),5,1,1)
	end
	pal(8,8)
end

function drawtable()
	rectfill(7,80,120,110,4)
	for y = 80, 120, 8 do
		for x =8, 112, 8 do
			spr(32,x,y)
			end
		end
	drawdiscardpile()
	drawdrawpile()
end

function drawbag()
 rectfill(62,116,125,125,9)
 rect(61,115,126,126,0)
 print("\#0bag",115,109,7)
 for i=1,#bag do
  local local_x=55+(i*10)
 	spr(powerups_sprites[bag[i]],local_x,117)
 end
 for i=1,6-#bag do
  local local_x=127-(i*10)
 	line(local_x-1,120,local_x+4,120)
 	line(local_x-1,121,local_x+4,121)
 end
 if position==user_positions[4] then
  local local_x = 54
  local_x = local_x+bag_item_selected*10
  rect(local_x,116,local_x+9,125,7)
 end
end

function drawdrawpile()
	if #deck_todraw == 0 then
		spr(40,100,90,2,2)
	else
		spr(38,100,90,2,2)
	end
end

function drawdiscardpile()
	if #discardpile == 0 then
		spr(40,10,90,2,2)
	else
		drawcard(deck[discardpile[#discardpile]],10,90)
	end
end

function showdiscardpile()
	rectfill(30,25,100,110,0)
 print("dicard pile",40,30,7)
	print("card   value",40,38,7)
	local y=0
	for c in all(discardpile) do
		print(move[deck[c].move+1],40,50+(10*y),7)
		print(deck[c].value,80,50+(10*y),7)
		y=y+1
	end
end

function drawlosinglive()
	 local timer=getanimtimer("losinglives")
	 if(timer!=nil) then
	  if(timer<16 and timer > 12) then
			 cls(8)
			 return
			 end
			local local_y = 75 - (timer)
			if(local_y<75) then
					spr(10,110,local_y,2,2)
					if(losing_lives_amount!=nil)then
						print("-"..losing_lives_amount
									,114,local_y+8)
					else
					 print("-"..enemies[current_enemy].force
									,114,local_y+8)
					end
			end
		end
end

function drawchangeenemymove()
	 local timer=getanimtimer("drawchangeenemymove")
	 if(timer!=nil) then
			local local_x = 10 - (timer%4)
		 -- move
			circfill(15,35,10,6)
			spr(12,local_x,27,2,2,false,true)
		 circ(15,35,10,0)
		 -- debuff
		 circfill(112,35,10,6)
		 spr(14,105,28,2,2)
		 circ(112,35,10,0)
		end
end

function drawselectpowerup()
	rect(6,16,21,31,7)
	spr(powerups_sprites[random_powerup_1],10,20)
	print(powerups_texts[random_powerup_1][2],25,25)

	rect(6,46,21,61,7)
	spr(powerups_sprites[random_powerup_2],10,50)
	print(powerups_texts[random_powerup_2][2],25,55)
	
	rect(6,76,21,91,7)
	spr(powerups_sprites[random_powerup_3],10,80)
	print(powerups_texts[random_powerup_3][2],25,85)
	
	if(poweupselected==1) then
	 powerup=powerups[random_powerup_1]
	 rect(4,14,110,33,7)
	 end
	if(poweupselected==2) then
	 powerup=powerups[random_powerup_2]
	 rect(4,44,110,63,7)
	 end
	if(poweupselected==3) then
	 powerup=powerups[random_powerup_3]
	 rect(4,74,110,93,7)
	 end
	 
	print("\#0"..powerups_texts[random_powerup_1][1],25,14)
	print("\#0"..powerups_texts[random_powerup_2][1],25,44)
	print("\#0"..powerups_texts[random_powerup_3][1],25,74)
 
 print(button_accept_s.." select",1,123)
end
-->8
--load main scene
function loadmainscene()
cls(6)
drawmap()
drawenemy(current_enemy)
drawtable()
drawhand(hand)
drawlife(lifes)
drawkeybinds()
drawbag()
end

function initialsetup()
still_alive=true
current_enemy=1
bag={}
enemylife=initial_enemylife
lifes=initial_lifes
round_discards=initial_discards
extra_power=0
shuffledeck()
getcard()
getcard()
getcard()
enemymove=getrandomenemymove()
enemydebuff=getrandomenemydebuff()
music(-1)
end
-->8
--load intro
function loadintro()
local intro_y = 15
local timer=getanimtimer("intro")
cls(0)

if(timer!=nil) then
	intro_y=intro_y-(timer*2)
	end
	
sspr(0,96,32,32,35,intro_y,64,64)

if(intro_y>14) then
		print("welcome to",20,80)
		print("sicissors card",20,92)
		print("a rock and paper game",20,104)
		print("please press "..button_accept_s.." button",20,116)
		print(version,105,0)
	end
end
-->8
--game core
deck_todraw={}
discardpile={}
hand={}
bag={}
cardinhandselected=0
discards_remaining=1
poweupselected=1
bag_item_selected=1
round_discards=1
extra_power=0

function shuffledeck()
deck_todraw={1,2,3,4,5,6,7,8,9}

deck_todraw=filtrar_array(deck_todraw,hand)

discardpile={}
	for i = #deck_todraw, 2, -1 do
 	local j = flr(rnd(i)) + 1
  deck_todraw[i], deck_todraw[j] = deck_todraw[j], deck_todraw[i]
	end
end

function getcard()
 if #deck_todraw == 0 then
 	shuffledeck()
 	end
	add(hand,deli(deck_todraw,1))
end

function discardcard(card)
	add(discardpile,card)
end

function currentpositionelected()
	if(btnp(button_up) and position==user_positions[2] and screen=="game") then
		position=user_positions[3]
		end
	if(btnp(button_down) and position==user_positions[2] and screen=="game") then
		position=user_positions[4]
		end
	if(position==user_positions[4]) and screen=="game" then
		if(btnp(button_up)) then
			position=user_positions[2]
			end
		if(btnp(button_right) and bag_item_selected<#bag) then
			bag_item_selected+=1
			end
		if(btnp(button_left) and bag_item_selected>1) then
			bag_item_selected-=1
			end
		if(btnp(button_accept) and screen=="game") then
		 local bag_item = bag[bag_item_selected]
		 if(enemydebuff==3 and bag_item==5) then
   		sfx(3)
				return
		 end
		 deli(bag,bag_item_selected)
		 activatebagitem(bag_item)
		 end
		return
		end
	if(position==user_positions[3]) then
		if(btnp(button_down)) then
		 position=user_positions[2]
		 end
		if(btn(button_accept)) then
		 screen="showinfo"
		else
		 screen="game"
		 end
		return
		end
	if(btnp(button_right)) and cardinhandselected < 4 then
		sfx(0)
		cardinhandselected=cardinhandselected+1
		end
	if(btnp(button_left)) and cardinhandselected > 0 then
		sfx(0)
		cardinhandselected=cardinhandselected-1
		end
	if btnp(button_accept) and cardinhandselected>0 and cardinhandselected <4  and screen=="game" then
		playcard()
		end
	if btnp(button_secondary) and cardinhandselected>0 and cardinhandselected <4 then
		if(enemydebuff==6 or discards_remaining==0) then
   		sfx(3)
		elseif(discards_remaining>0) then
		 discards_remaining=discards_remaining-1
		 sfx(4)
		 discardcard(deli(hand,cardinhandselected))
	  getcard()
	  end
		end	
	if(position==user_positions[1]) then
		for i = 0, 3 do
   if (btn(i)) then
    position=user_positions[2]
    cardinhandselected=1
    end
   end
		end					
end

function playcard()
 local cardplayed=deck[hand[cardinhandselected]]
 local card_damage=cardplayed.value
 local won = calculatewinmove(cardplayed.move+1,enemymove)
	if(won=="invalid") then
		local card1 = deck[hand[1]]
		local card2 = deck[hand[2]]
		local card3 = deck[hand[3]]
		--this avoids block hand
		if(card1.move!=card2.move or card1.move!=card3.move) then
			sfx(3)
			return
		end
		won="lose"
	end
	if(won=="win") then
	 if(enemydebuff==4) then
			lifes-=1
			losing_lives_amount=1
			add(animations,{timer=15,name="losinglives"})
		end
		if(enemydebuff==5) then
			card_damage-=1
			if(card_damage<0) then
				card_damage=0
			end
		end
		local damage_deal=card_damage+extra_power
		if(damage_deal>0) then
		 enemylife=enemylife-damage_deal
		 sfx(2)
		 add(animations,{timer=10,name="enemylosinglives"})	
		end
	elseif(won=="lose") then
		lifes=lifes-enemies[current_enemy].force
	 losing_lives_amount=enemies[current_enemy].force
	 sfx(1)
	 add(animations,{timer=15,name="losinglives"})
	end
	discardcard(deli(hand,cardinhandselected))
	getcard()
	enemymove=getrandomenemymove()
	enemydebuff=getrandomenemydebuff()
	checkendhand()
end

function activatebagitem(bag_item)
 if(bag_item==2) then
  lifes+=2
	 if(lifes>initial_lifes) then
	  lifes=initial_lifes
	  end
	 return
 end
 if(bag_item==3) then
  enemydebuff=1
	 return
 end
 if(bag_item==5) then
 	sfx(2)
		add(animations,{timer=10,name="enemylosinglives"})
  enemylife-=2
  checkendhand()
	 return
 end
end

function checkendhand()
	if(lifes<1) then
		still_alive=false
		get3randompowerup()
		screen="finishedgame"
	end
	if(enemylife<1) then
	 get3randompowerup()
		screen="finishedgame"
	end
end

--aux function to filter array
function filtrar_array(original, remove)
	local new_array = {}
		for v in all(original) do
			if not includes(remove, v) then
   	add(new_array, v)
    end
   end 
 return new_array
end

function includes(table, value)
	for v in all(table) do
		if v == value then return true end
  end
	return false
end

function calculatewinmove(user,enemy)
	if(user==enemy) then
		return "tie"
	elseif(user==1 and enemy==2) then
		if(enemydebuff==2) then
			return "invalid"
		end
		if(enemydebuff==3) then
			return "tie"
		end
		return "win"
	elseif(user==2 and enemy==3) then
		if(enemydebuff==2) then
			return "invalid"
		end
		if(enemydebuff==3) then
			return "tie"
		end
		return "win"
	elseif(user==3 and enemy==1) then
		if(enemydebuff==2) then
			return "invalid"
		end
		if(enemydebuff==3) then
			return "tie"
		end
		return "win"
	else
		return "lose"
	end
end

function getrandomenemymove()
 add(animations,{timer=10,name="drawchangeenemymove"})
	return flr(rnd(3)) + 1
end

function getrandomenemydebuff()
	enemydebuffs = enemies[current_enemy].debuffs
	enemydebuffs_probs=enemies[current_enemy].debuffs_probs
	probs=0
	-- sum all probs to create a probability pool
	for i=1,#enemydebuffs_probs do
  probs=probs+enemydebuffs_probs[i]
  end 
 debuff_prob=flr(rnd(probs))
 
 -- substract points until it reached 0 or below
 -- to take the random debuff
 for i=1,#enemydebuffs_probs do
 	debuff_prob=debuff_prob-enemydebuffs_probs[i]
  if(debuff_prob<0) then
   return enemydebuffs[i]
  end
 end
 
	return enemydebuffs[flr(rnd(#enemydebuffs))+1]
end

function get3randompowerup()
 local local_powerups={}
 local to_return = {}
 
 for i=1,#powerups do
  add(local_powerups,i)
 end
 
 for i=1,3 do
  local powerup=flr(rnd(#local_powerups))+1
  add(to_return,local_powerups[powerup])
  deli(local_powerups,powerup)
 end
 
 random_powerup_1=to_return[1]
 random_powerup_2=to_return[2]
 random_powerup_3=to_return[3]
end

function setupnewround()
	cardinhandselected=1
	current_enemy+=1
	bag_item_selected=1
	poweupselected=1
	enemylife=initial_enemylife
	enemymove=getrandomenemymove()
	enemydebuff=getrandomenemydebuff()
	hand={}
	shuffledeck()
	getcard()
	getcard()
	getcard()
	if(powerup==powerups[1]) then
	 round_discards+=1
	 end
	if(powerup==powerups[2]) then
	 add(bag,2)
	end
	if(powerup==powerups[3]) then
	 add(bag,3)
	end
	if(powerup==powerups[4]) then
	 extra_power+=1
	end
 if(powerup==powerups[5]) then
	 add(bag,5)
	end
	powerup=""
	position=user_positions[2]
	discards_remaining=round_discards
end
-->8
--constants
button_right=1
button_left=0
button_up=2
button_down=3
button_accept=4
button_accept_s="🅾️"
button_secondary=5
button_secondary_s="❎"

user_positions={
"init",
"hand",
"debuffs",
"bag"
}

deck={
	{move=0,value=1},
	{move=0,value=2},
	{move=0,value=3},
	{move=1,value=1},
	{move=1,value=2},
	{move=1,value=3},
	{move=2,value=1},
	{move=2,value=2},
	{move=2,value=3}
}

move={
"stone",
"scissors",
"paper"
}

powerups={
"discard",
"lives",
"remove_debuff",
"power",
"bomb"
}

powerups_texts={
 {"+1 discard",
 "gain 1 per round"},
 {"live potion",
 "gain 2 lives (max 9)"},
 {"stop",
 "remove enemy effect"},
 {"power",
 "+1 in card strenght"},
 {"bomb",
 "-2 to enemy life"}
}

defuffs_texts={
--1
"nothing\n\n"..
 "play free",
--2
"avoid losing\n\n"..
 "winning move can not be \n"
 .."played",
--3
"shield\n\n"..
	"enemy can not lose lifes",
--4
"spines\n\n"..
	"if you won\n"..
	"you will lose 1 live",
--5
"powerless\n\n"..
	"your cards\n"..
	"make -1 damage",
--6
"no discards\n\n"..
	"you cannot use\n"
	.."discard action\n"
}

enemies = {
	[1] = {
		mask=0,
		face=0,
		force=1,
		debuffs={1,3,5},
		debuffs_probs={75,30,15}
--		debuffs={5},
--		debuffs_probs={100}
		},
	[2] = {
		mask=32,
		face=32,
		force=2,
		debuffs={1,2,3,4,5,6},
		debuffs_probs={50,25,50,25,75,75}
	},
	[3] = {
		mask=64,
		face=64,
		force=3,
		debuffs={2,3,4,5,6},
		debuffs_probs={75,75,25,25,50}
	}
}

--sprites
move_sprite={0,2,4}

debuffs_sprites={160,162,164,166,168,170}

powerups_sprites={144,145,146,147,148}
-->8
--load finishedgame scene
function finishedscene()
 cls(0)
 if(current_enemy==last_boss and still_alive) then
		print("you won!!!!",44,40,7)
		print(button_secondary_s.." return to main menu",31,110,7)
 elseif(still_alive) then
 	if(btnp(button_down) and poweupselected <3) then
 	 poweupselected+=1
 	 end
 	if(btnp(button_up) and poweupselected >1) then
 	 poweupselected-=1
 	 end
 	drawselectpowerup()
 else
 	print("you lost...",42,64,7)
 	print(button_secondary_s.." restart?",42,110)
 	if(btnp(button_secondary))then
			screen="menu"
		end
 end
end
-->8
-- load infoscene
function showinfo(text)
cls(0)
print(text,10,60)
end

__gfx__
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777bbbbbb000000000000bbbbbbbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbb0bbb0bbbbbbbbbbbbb0bbbbbbbbbbb7777777777bbbb00ee000000ee00bbbbbbb0880bbbbbbbbbb11011011bbbbbbbbbbbbbbbbbbbb
bbbbbb00b00bbbbbbbbbbc0bbcbbbbbbbbbbb00c00bbbbbbbb777777777777bb00eeee0000eeee00bbbbbb0880bbbbbbbb10dd1dd1dd1bbbbbbbbbbbbbbbbbbb
bbbb001c0cc0bbbbbbbbbc0b0cbbbbbbbbbb0c010c0bbbbbbb777777777777bb0eeeeee00eeeeee0bbbbb088880bbbbbb110dd1dd1dd1bbbbbbbb000000bbbbb
bbb0cc0c1cc0bbbbbbbbb1cb0cbbbbbbbbb00101010bbbbbbb777777777777bb0eeeeeeeeeeeeee0bbbbb088880bbbbbb110111111111bbbbbbb07f4fff0bbbb
bbb0cc0c1cc0bbbbbbbbb0c0c0bbbbbbbb0c0101010bbbbbbb777777777777bb0eeeeeeeeeeeeee0bbbb08888880bbbbb110110110110bbbbbb07f4feeef0bbb
bbb0cccc0000bbbbbbbbb010c0bbbbbbbb010101010b0bbbbb777777777777bb0eeeeeeeeeeeeee0bbb0888888880bbbb000000ddddd1bbbbb07f47eeffef0bb
bbb00ccc0ccc0bbbbbbb0c011cbbbbbbbb010ccccc0c1bbbbb777777777777bb0eeeeeeeeeeeeee0bbb0888888880bbbb0111101ddddd1bbbb0f47effeffe0bb
bbb01000001c0bbbbbbb01c0ccbbbbbbbb01cccccccc0bbbbb777777777777bb0eeeeeeeeeeeeee0bb088888888880bbb01dddd0001dd1bbbb0f4fefffeee0bb
bbb01ccccccc0bbbbbbb0c011cbbbbbbbbb0ccccccc0bbbbbb777777777777bb00eeeeeeeeeeee00bb088888888880bbb01dddd111ddd1bbbb0e4eeeeee440bb
bbb011ccccc0bbbbbbbb011cccbbbbbbbbb0cccccc10bbbbbb777777777777bb000eeeeeeeeee000bb088888888880bbb01dddddddddd1bbbbb00eeeee4e0bbb
bbbb0111110bbbbbbbbb01ccc0bbbbbbbbbb0cccc10bbbbbbb777777777777bb0000eeeeeeee0000bb088888888880bbb01ddddddddd10bbbbbbb0000000bbbb
bbbb0ccccc0bbbbbbbbbb01110bbbbbbbbbbb0ccc0bbbbbbbb777777777777bb00000eeeeee00000bb088888888880bbbb01111111110bbbbbbbbbbbbbbbbbbb
bbbb000000bbbbbbbbbbb00000bbbbbbbbbbb01110bbbbbbbb777777777777bb000000eeee000000bbb0888888880bbbbbb000000000bbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00000bbbbbbbbb7777777777bbbb000000ee000000bbbbb08888880bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb77777777bbbbbb000000000000bbbbbbb000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000b00000000000000bb00bb00bbbbbbbbb00000000bbbb66666666bbbbbbbb76767676bbbb000000000000000000000000000000000000000000000000
444499f4044664466446644008800880bbbaabbb00000000bbb6787878786bbbbbb60b0b0b0b7bbb000000000000000000000000000000000000000000000000
44444444041661166aa66a4008888880bbaaaabb00000000bb678787878786bbbb70b0b0b0b0b6bb000000000000000000000000000000000000000000000000
44444444041661166aa66a4008888880baaaaaab00000000bb687878787876bbbb6b0b0b0b0b07bb000000000000000000000000000000000000000000000000
000000000416611661a66a4008888880aaaaaaaa00000000bb678787878786bbbb70b0b0b0b0b6bb000000000000000000000000000000000000000000000000
444444440416611661166a40b088880bbbbbbbbb00000000bb687878787876bbbb6b0b0b0b0b07bb000000000000000000000000000000000000000000000000
f99444440416611661166140bb0880bbbbbbbbbb00000000bb678787878786bbbb70b0b0b0b0b6bb000000000000000000000000000000000000000000000000
444444440416611661166140bbb00bbbbbbbbbbb00000000bb687878787876bbbb6b0b0b0b0b07bb000000000000000000000000000000000000000000000000
444444400416611661166140666666660000000000000000bb678787878786bbbb70b0b0b0b0b6bb000000000000000000000000000000000000000000000000
444444400416611661166140666666660000000000000000bb687878787876bbbb6b0b0b0b0b07bb000000000000000000000000000000000000000000000000
444444400416611661166140666666660000000000000000bb678787878786bbbb70b0b0b0b0b6bb000000000000000000000000000000000000000000000000
000000000416611661166140666666660000000000000000bb687878787876bbbb6b0b0b0b0b07bb000000000000000000000000000000000000000000000000
444044440416611661166140666666660000000000000000bb678787878786bbbb70b0b0b0b0b6bb000000000000000000000000000000000000000000000000
444044440416611661166140666666660000000000000000bb687878787876bbbb6b0b0b0b0b07bb000000000000000000000000000000000000000000000000
444044440446644664466440666666660000000000000000bbb6878787876bbbbbb7b0b0b0b06bbb000000000000000000000000000000000000000000000000
00000000b00000000000000b666666660000000000000000bbbb66666666bbbbbbbb67676767bbbb000000000000000000000000000000000000000000000000
bbb0000000000bbbbbbbbbbbbbb000bbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bbb00000000000bbbb000000000000bbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbb0000cccccccccc000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000bb00000000000000000000000bbbbbbbbbbbb0005555555555000bbbbbbbbb33bbb011ccccccccccccc110bbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000bb000000000011000000000000000bbbbbbbb0005655666665000bbbbbbbbb33bbb011ccccccccccccc110bbbb33bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
bb000000000000011000000000000000bbbbbb00665565566656566600bbbbbbb00bbb0cc1ccccccccccc1cc0bbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
000000000000000110000000000000bbbbbbbb00665566666666566600bbbbbbb00bbb0cc1ccccccccccc1cc0bbbb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
00000000000000000000000000000000bbbb005666556666666656666500bbbbb00b00000000000000000000000bb00bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb
b0000000000000000000000000000000bbbb005666556556665656666500bbbbb000000000000000000000000000000bbbbbbbbb000bbbbbbbbbbbbbbbbbbbbb
b00000000000000110000000000000bbbbbb005566556556666656655500bbbb000d001ddddd6776ddddddddd110d000bbbbbb00ccc0bbbbbbbbbbbbbbbbbbbb
bb000000dddddd0110dddddd000000bbbb0055555000005555000005555500bb00dd011dddd6776dddddddd00000dd00bbbbb0cccccc0bbbbbbbbbbbbbbbbbbb
bb0000ddcccccc0000ccccccdd0000bbbb0055550000005555000000555500bb001101dddd6776ddddddd000a0001100bbbb0cccc77cc0bbbbbbbbbbbbbbbbbb
b00000ccccccccddddcccccccc00000bbb0055500ddddd0000ddddd0055500bb001101ddd6776dddddddd00000001100bbb01ccc7777c0bbbbbbbbbbbbbbbbbb
000000ccc7777cccccc7777ccc00000000605550c7777c0000c7777c05550600b00101dd6776ddd00dddd0080030100bbbb01ccc777cc0bbbbbbbbbbbbbbbbbb
0c00ddccc7007cccccc7007cccdd00c006705550c7007cddddc7007c05550760bbb001dd776ddd0cc0ddd00000000bbbbbb01cccccccc0bbbbbbbbbbbbbbbbbb
0c00ccccc7007cccccc7007ccccc00c006605550c7007cccccc7007c05550660bbb00111111110cccc01111111100bbbbbb01ccccccc10bbbbbbbbbbbbbbbbbb
0c00ccccc7777cccccc7777ccccc00c006605550c7777cccccc7777c05550660bbbbb000000000cccc000000000bbbbbbbb011cccccc00bbbbbbbbbbbbbbbbbb
bbb0cccccccccccccccccccccccc0bbbbbb0cccccccccccccccccccccccc0bbbbbb0cccccccccccccccccccccccc0bbbbbbb011cccc10bbbbbbbbbbbbbbbbbbb
bbb0c0000cccccccccccccc0000c0bbbbbb0cccccccccccccccccccccccc0bbbbbb0ccccccc0000000000ccccccc0bbbbbb0111ddd1c0bbbbbbbbbbbbbbbbbbb
bbb0c00e00cccccccccccc00e00c0bbbbbb0cccccccccccccccccccccccc0bbbbbb0ccccc000777777770000cccc0bbbbbb01dd111c70bbbbbbbbbbbbbbbbbbb
bbb0c007700cccccccccc007700c0bbbbbb0ccccc00000000000000ccccc0bbbbbb0ccc000777000000778000ccc0bbbbbb01ccc1cc70bbbbbbbbbbbbbbbbbbb
bbb0c007770000ccccc00077700c0bbbbbb0cccc00e0ee0ee0ee0e00cccc0bbbbbb0cc00777000000000078800cc0bbbbbb01c7cdcc70bbbbbbbbbbbbbbbbbbb
bbb0c0007777700000007777000c0bbbbbb0cccc0070770770770700cccc0bbbbbb0cc007700cccccccc007800cc0bbbbbb0017cdccc0bbbbbbbbbbbbbbbbbbb
bbb0ccc000777777777777000ccc0bbbbbb0cccc0070770770770700cccc0bbbbbb0cc00000cccccccccc00000cc0bbbbbbb01ccdccc0bbbbbbbbbbbbbbbbbbb
bbbb00cc0000777777770000cc00bbbbbbbb00cc0070770770770700cc00bbbbbbbb00cc00cccccccccccc0ccc00bbbbbbbb0d1cdcc0bbbbbbbbbbbbbbbbbbbb
bbbb00cccc000000000000cccc00bbbbbbbb00cc00e0ee0ee0ee0e00cc00bbbbbbbb00cccccccccccccccccccc00bbbbbbbb0d1cdcc0bbbbbbbbbbbbbbbbbbbb
bbbb00dccccc00000000cccccd00bbbbbbbb00dcc00000000000000ccd00bbbbbbbb00dccccccccccccccccccd00bbbbbbbb0dccdcc0bbbbbbbbbbbbbbbbbbbb
bbbbbb00cccccccccccccccc00bbbbbbbbbbbb00cccccccccccccccc00bbbbbbbbbbbb00cccccccccccccccc00bbbbbbbbbb0111dccc00bbbbbbbbbbbbbbbbbb
bbbbbb00dccccccccccccccd00bbbbbbbbbbbb00dccccccccccccccd00bbbbbbbbbbbb00dccccccccccccccd00bbbbbbbbbb0d1ddddccc0bbbbbbbbbbbbbbbbb
bbbbbbbb000cccccccccc000bbbbbbbbbbbbbbbb000cccccccccc000bbbbbbbbbbbbbbbb000cccccccccc000bbbbbbbbbbbb0dd1111ddcc0bbbbbbbbbbbbbbbb
bbbbbbbb000dccccccccd000bbbbbbbbbbbbbbbb000dccccccccd000bbbbbbbbbbbbbbbb000dccccccccd000bbbbbbbbbbbbb01dddddddd0bbbbbbbbbbbbbbbb
bbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbb0011111110bbbbbbbbbbbbbbbb
bbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbbbbbb0000000000bbbbbbbbbbbbbbbbbb000000000bbbbbbbbbbbbbbbb
bbbbbbbbbbb66bbb0000000000000000bbbbbbbbbbb66bbb0000000000000000bbbbbbbbbbb66bbb000000000000000000000000000000000000000000000000
bbbb00bbbb6bb6bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb0bbbbbbb6bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb0bb0bbb555555b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b000b0bbb55bb55b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb0bb0bbb55aa55b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb000bb555555b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb88bbbbb8bb8bbbb8888bbbb8888bbbbbbb8bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b888888bb888888bb888888bb888008bbbbb6bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb8bb8bb888888888888888888088088bbb67bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb8bb8bb888888888877778880008088bb7007bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb8bb8bb888888888877778888088088b707007b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb8bb8bbb888888b8888888888880008b700007b0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb8888bbbb8888bbb888888bb888888bbb7007bb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbb88bbbbb8888bbbb8888bbbbb77bbb0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbb8bbb00000000000bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000bbb8b00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbb888b0777666666660bbbbb75bbb75bbb75bbbbbbbbbbbbbbbbbbbbbbbb00000b88800000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbb888bb0769944444460bbbbb75bbb75bbb75bbbbbb00000bbbbbbbb0bbbb00000888b00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbb888bb076999444444460bbbb75bbb75bbb75bbbbb0888880bbbbbbb0bbbb0000888bb00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbb888bbb079994494444460bbbb75bbb75bbb75bbbb088800880bbbbbb0bbbb000888bbb00000000000000000000000000000000
888888888888888bbbbbbbbbb888bbbb079949944444460bbb765bb765bb765bbb08888808880bbb0b0b0bbb0888bbbb00000000000000000000000000000000
888888888888888bbbbbbbbb888bbbbb079944444444460bbb765bb765bb765bbb08888808880bbbb000bbbb888bbbbb00000000000000000000000000000000
888888888888888bbbbbbbb888bbbbbb077944444444460bbb765bb765bb765bbb08000808880bbbbb0bbbb888bbbbbb00000000000000000000000000000000
888888888888888bbbbbbb888bbbbbbbb0799494444460bbbb765bb765bb765bbb08888808880bbbbbbbbb888bbbbbbb00000000000000000000000000000000
888888888888888bbbbbb888bbbbbbbbbb07949444460bbbb7665b7665b7665bbb08888000880bbbbbbbb88800bbbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbb888bbbbbbbbbbb07994444460bbbb7665b7665b7665bbbb088888880bbbbbbbb88800000bbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbb888bbbbbbbbbbbbb079444460bbbbb7665b7665b7665bbbbb0888880bbbbbbbb888b0bb0bbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbbb888bbbbbbbbbbbbbb079944460bbbbb7665b7665b7665bbbbbb00000bbbbbbbb888bb0bb0bbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbb888bbbbbbbbbbbbbbbb0769460bbbbbb7665b7665b7665bbbbbbbbbbbbbbbbbb888bbb0bb0bbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbb888bbbbbbbbbbbbbbbbbb06660bbbbbbb7665b7665b7665bbbbbbbbbbbbbbbbb888bbbb0bb0bbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbb8bbbbbbbbbbbbbbbbbbbb000bbbbbbbb7775b7775b7775bbbbbbbbbbbbbbbbbb8bbbbb0000bbbbb00000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb3333bbbb8888bbbb5555bbbb0000bb0000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbb00bbbbbbbbbbbbbbbb333333bb888888bb555555bb000000b0000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbb000cc000bbbbbbbbbbbb333333738878878855555555007007000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbb0cc0cc0cc00bbbbbbbbbb333337338887788855666655007707000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb000cc0cc0cc0c0bbbbbbbbb337373338887788855666655007077000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb0cc0cc0c10cc0c0bbbbbbbbb333733338878878855555555007007000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb00cccc10c10cc0c10bbbbbbbbb333333bb888888bb555555bb000000b0000000000000000000000000000000000000000000000000000000000000000
bbbbbbb0cc00c10c10cc0c10bbbbbbbbbb3333bbbb8888bbbb5555bbbb0000bb0000000000000000000000000000000000000000000000000000000000000000
bbbbbbb0ccc0000000000c10bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb0cccccc100cccc10bbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb00cccccc0ccccc0bbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb10ccccc0cccc10bbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbb00ccc010cc00bbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb00bb0000ccc000bbbb0bbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb00b1c0b0cccccccc0bbb1c0bbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb0c101c100000000000bb1cc0bb00b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb0cc00cc0bbbbbbbbbbb0cc0bb1c0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0c00cc01c0bbbbbbbbbb01c0bb0cc0b000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0cc00c10ccbbb00bbbbb0cc0b0cc0bb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b01cc0cc0cc0b0cc0bb001c000cc0bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb01cc0cccc101c10b0cc0100cc0bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b0c00ccccccc1cc0b0c1cc01cc0bbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb0c10cccc11cc10b0cc0cc001c0bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb0ccccc11ccc0b0ccc10001cc0bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb0ccc111ccc0b0cccc10cc10c0bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbb0cccc1ccc0b0cccc01000cc0bbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbb0cccccc11001cc0cc0cc10bbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbb0cccccc100ccccccc100bbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbb01ccc00bb01cccc00bbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbb0110bbbbb01100bbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbb00bbbbbbb000bbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__label__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000cccc00000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000cccc00cccc00cccc00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000cccc00cccc00cccc00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000cccc00cccc00cccc00cc0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000cccc00cccc00cccc00cc0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000cccc00cccc00cc1100cccc00cc0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000cccc00cccc00cc1100cccc00cc0000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000cccccccc1100cc1100cccc00cc1100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000cccccccc1100cc1100cccc00cc1100000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000cccc0000cc1100cc1100cccc00cc1100000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000cccc0000cc1100cc1100cccc00cc1100000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000cccccc00000000000000000000cc1100000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000cccccc00000000000000000000cc1100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000cccccccccccc110000cccccccc1100000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000cccccccccccc110000cccccccc1100000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000cccccccccccc00cccccccccc0000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000cccccccccccc00cccccccccc0000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000001100cccccccccc00cccccccc110000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000001100cccccccccc00cccccccc110000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000cccccc001100cccc00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000cccccc001100cccc00000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000cccccc000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000cccccc000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000011cc000000cccccccccccccccc0000000011cc00000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000011cc000000cccccccccccccccc0000000011cc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000cc110011cc110000000000000000000000000011cccc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000cc110011cc110000000000000000000000000011cccc00000000000000000000000000000000000000000
0000000000000000000000000000000000000000000cccc0000cccc00000000000000000000000000cccc00000011cc000000000000000000000000000000000
0000000000000000000000000000000000000000000cccc0000cccc00000000000000000000000000cccc00000011cc000000000000000000000000000000000
000000000000000000000000000000000000000cc0000cccc0011cc00000000000000000000000011cc00000000cccc000000000000000000000000000000000
000000000000000000000000000000000000000cc0000cccc0011cc00000000000000000000000011cc00000000cccc000000000000000000000000000000000
000000000000000000000000000000000000000cccc0000cc1100cccc0000000000000000000000cccc000000cccc00000000000000000000000000000000000
000000000000000000000000000000000000000cccc0000cc1100cccc0000000000000000000000cccc000000cccc00000000000000000000000000000000000
00000000000000000000000000000000000000011cccc00cccc00cccc000000cccc000000000011cc000000cccc0000000000000000000000000000000000000
00000000000000000000000000000000000000011cccc00cccc00cccc000000cccc000000000011cc000000cccc0000000000000000000000000000000000000
0000000000000000000000000000000000000000011cccc00cccccccc110011cc11000000cccc00110000cccc000000000000000000000000000000000000000
0000000000000000000000000000000000000000011cccc00cccccccc110011cc11000000cccc00110000cccc000000000000000000000000000000000000000
000000000000000000000000000000000000000cc0000cccccccccccccc11cccc000000cc11cccc0011cccc00000000000000000000000000000000000000000
000000000000000000000000000000000000000cc0000cccccccccccccc11cccc000000cc11cccc0011cccc00000000000000000000000000000000000000000
00000000000000000000000000000000000000000cc1100cccccccc1111cccc11000000cccc00cccc000011cc000000000000000000000000000000000000000
00000000000000000000000000000000000000000cc1100cccccccc1111cccc11000000cccc00cccc000011cc000000000000000000000000000000000000000
0000000000000000000000000000000000000000000cccccccccc1111cccccc000000cccccc1100000011cccc000000000000000000000000000000000000000
0000000000000000000000000000000000000000000cccccccccc1111cccccc000000cccccc1100000011cccc000000000000000000000000000000000000000
000000000000000000000000000000000000000000000cccccc111111cccccc000000cccccccc1100cccc1100cc0000000000000000000000000000000000000
000000000000000000000000000000000000000000000cccccc111111cccccc000000cccccccc1100cccc1100cc0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000cccccccc11cccccc000000cccccccc0011000000cccc0000000000000000000000000000000000000
00000000000000000000000000000000000000000000000cccccccc11cccccc000000cccccccc0011000000cccc0000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cccccccccccc1111000011cccc00cccc00cccc11000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000cccccccccccc1111000011cccc00cccc00cccc11000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000cccccccccccc110000cccccccccccccc110000000000000000000000000000000000000000000
000000000000000000000000000000000000000000000000000cccccccccccc110000cccccccccccccc110000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000011cccccc000000000011cccccccc00000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000011cccccc000000000011cccccccc00000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001111000000000000001111000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000001111000000000000001111000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000

__map__
0000000000000000000000000021220000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000031320000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
3030303030303030303030303030303000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003a0503a0503a0503905039050390503905038050380503805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00030000203501e3511c3511b3512a202292022720225202241022d3022b3021f20226302203021f3021d3021b302144021b30211402163020b202123020f4020e4020e4020c4020c4020c4020c4010c4010c001
0004000000000104500e4500d4500c4500b4500a4000840007400054000a6000a6000e6000a6000a6000a6000a6000a6000a6000a6000a6000a6000a600000000000000000000000000000000000000000000000
000200001f4001e4002b3002630021300073500735007350073500735007350104000f4000e4000d4000c4000c400000000000000000000000000000000000000000000000000000000000000000000000000000
00040000223501f3501b350143501f3001b30014300103000c3000930003300000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000c0500800000000000001305000000000000000016050000000000000000110500000000000000000c050080000000000000130500000000000000001605000000000000000011050000000000000000
0010000030000000000000000000000002d100370000000018030000000000000000000002d1001f0300000000000000000000000000260300000000000000002103000000000000000000000000000000000000
001000000000000000000000000000000000000000000550000000000000000000000000000000000000055000000000000000000000000000000000000005500000000000000000000000000000000000000550
001000001a60014600000000000000000000000000000000000601460000000000000000000000000000000000060000000000000000000000000000000000000000000000000000000000000000000000000000
000b000000000000000c8000c8000e8002d0000f80010800210000e8000e8002000000000000000e8000e8000e8000c8000c8000c8000c8000c8000c80010800128001d800128000d8000f8000c0002000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00100000300542f00000000340541a000000003705400000000003b05400000000003905400000000003705400000000003405432000000003005400000000000000000000000000000000000000000000000000
001000003835231300313523830034352000003835200000393520000030352000003435200000393520000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000001815700000000000000000000000000000000000211570000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000d756000000d15600000000000000000000000000d156000000d156000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__music__
03 14151617
00 1e1f2021

