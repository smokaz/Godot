extends KinematicBody2D
# MEMBER VARIABLES (CANNOT BE GLOBAL?)
# MOVEMENT VARIABLES
var down
var up
var left
var right
var attack
var dir = [0,0]
# ANIMATION VARIABLES
var anim_prev
var anim_next
var animnode
var anim_prev_weapon
var animnode_weapon
var anim_state = ""
var anim_facing = ""
var anim_array = [["walk_leftup","walk_up","walk_rightup"],
					["walk_left","idle","walk_right"],
					["walk_leftdown","walk_down","walk_downright"]]
var anim_dict = {
					"walk_left" : "idle_left",
					"attack_left" : "idle_left",
					"walk_leftdown" : "idle_leftdown",
					"attack_leftdown" : "idle_leftdown",
					"walk_leftup" : "idle_leftdown",
					"attack_leftup" : "idle_leftup",
					"walk_right" : "idle_right",
					"attack_right" : "idle_right",
					"walk_rightdown" : "idle_rightdown",
					"attack_rightdown" : "idle_rightdown",
					"walk_rightup" : "idle_rightup",
					"attack_rightup" : "idle_rightup",
					"walk_up" : "idle_up",
					"attack_up" : "idle_up",
					"walk_down" : "idle_down",
					"attack_down" : "idle_down",
					"idle_right" : "idle_right",
					"idle_left" : "idle_left",
					"idle_down" : "idle_down",
					"idle_up" : "idle_up"
					}

# PLAYER STATISTICS VARIABLES
var acceleration = 0 #used to smooth movement startup
var speed = 2
var health_current
var health_increase
var health_max
var level = 1
var experience_current = 25
var experience_tolevel = 100
var strength
var agility
#PLAYER INVENTORY VARIABLES
var weapontimer = 0 #used for test melee weapon
var current_weapon

# INITALIZE PLAYER
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#initalize player inventory
	init_playerinventory()
	add_to_group("Player_group")
	#initalize animation
	animnode = get_node("Player_Sprite/Player_AnimationPlayer")
	animnode_weapon = get_node("Weapon_Sprite/Weapon_AnimationPlayer")
	animnode.set_current_animation("idle_right")
	animnode_weapon.set_current_animation("attack_right")
	#initalize hp, mana, exp
	get_node("Exp_bar").set_value(100*experience_current/experience_tolevel)
	get_node("Exp_bar/Exp_label").set_text("EXP")
	set_fixed_process(true)
	pass

# Weapons class TEST
class Weapon:
	var name = ""
	var delay = 0.0
	var damage
	var sprite
	var animationtime
# PLAYER INVENTORY TEST
func init_playerinventory():
	Globals.set("player_maximum_melee_attack_range",50)
	var sword = Weapon.new()
	sword.name = "Short Sword"
	sword.delay = 1.5
	sword.animationtime = 1
	sword.damage = 1
	current_weapon = sword
	
func deal_damage_to(var enemy):
	enemy.set("health",enemy.get("health")-current_weapon.damage*strength)
	get_node("Label").set_text(str(current_weapon.damage*strength))
	get_node("Label").set_pos(enemy.get_pos()-get_pos())
	
# PROCESS 
func _fixed_process(delta):
	get_node("Exp_bar").set_value(100*experience_current/experience_tolevel)
	# GET PLAYER INPUT
	down = Input.is_action_pressed("move_down")
	up = Input.is_action_pressed("move_up")
	left = Input.is_action_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	attack = Input.is_action_pressed("move_attack_melee")
	# GET MOVEMENT DIRECTION 
	dir[1] = down-up
	dir[0] = right-left
	# ACCELERATE TO SPEED
	if(acceleration<speed):
		acceleration += 4*delta
	elif(acceleration>speed):
		acceleration = speed
	# STORE NEW POSITION GLOBALLY AND MOVE
	Globals.set("player_pos",get_pos())
	move(Vector2(dir[0], dir[1]).normalized()*acceleration)
	
	##### ANIMATION #####
	# Get previous animation
	anim_prev = animnode.get_current_animation()
	# Get next animation, do not change if we are attacking
	if(anim_state != "attacking"):
		anim_next = anim_array[dir[1]+1][dir[0]+1]
		if(anim_next == "idle"):
			acceleration = 0
			anim_next = anim_dict[anim_prev] #get facing for idle
			if(anim_next != anim_prev or anim_state == "finished"): #looping case
				animnode.set_current_animation(anim_next)
				animnode.seek(0.0)
				anim_state = "idling"
		else:
			if(anim_next != anim_prev or anim_state == "finished"):
				anim_state = "walking"
				animnode.set_current_animation(anim_next)
				animnode.seek(0.0)

	#ATTACK TEST - need to figure out how to load only one specific node
	if(attack and weapontimer>= (current_weapon.delay/(agility/10)) ):
		if(anim_dict[anim_prev] == "idle_right"):
			#if(anim_prev != "attack_right"):
			animnode.set_current_animation("attack_right")
			animnode_weapon.set_current_animation("attack_right")
			animnode_weapon.seek(0.0)
			animnode.seek(0.0)
			anim_state = "attacking"
		weapontimer = 0
		Globals.set("player_is_attacking",true)
		var slash = load("res://effects.scn")
		var slashi = slash.instance()
		get_parent().get_child(self.get_index()).add_child(slashi)
		slashi.get_child(0).set_pos(Vector2(get_pos()))
		slashi.get_child(0).hide()
		#print(slashi)
	else:
		Globals.set("player_is_attacking",false)
	weapontimer+=delta
	
	
	#Advance animation to next frame
	if(animnode.get_current_animation_pos() 
	< animnode.get_current_animation_length()):
		animnode.advance(delta)
		#print("playing")
	else:
		#print("finished" + anim_state)
		anim_state = "finished"
	if(animnode_weapon.get_current_animation_pos()
	< animnode_weapon.get_current_animation_length()):
		animnode_weapon.advance(delta)


	
	#SPinBox
	strength = get_node("SpinBox").get_value()
	agility = get_node("SpinBox 2").get_value()