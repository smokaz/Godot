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
var animnode
# PLAYER STATISTICS VARIABLES
var acceleration = 0 #used to smooth movement startup
var speed = 2
var health_current
var health_increase
var health_max
var level = 1
var experience_current = 25
var experience_tolevel = 100
#PLAYER INVENTORY VARIABLES
var weapontimer = 0 #used for test melee weapon
var current_weapon

# INITALIZE PLAYER
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#initalize player inventory
	init_playerinventory()
	
	#initalize animation
	animnode = get_node("Player_Sprite/Player_AnimationPlayer")
	animnode.set_current_animation("idle_down")
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
	sword.damage = 25
	current_weapon = sword
	

# PROCESS 
func _fixed_process(delta):
	# GET PLAYER INPUT
	down = Input.is_action_pressed("move_down")
	up = Input.is_action_pressed("move_up")
	left = Input.is_action_pressed("move_left")
	right = Input.is_action_pressed("move_right")
	attack = Input.is_action_pressed("move_attack_melee")
	# FIND WHICH ANIMATION TO PLAY
	anim_prev = animnode.get_current_animation()
	if(dir[0]==0 and dir[1] == 0):
		acceleration = 0
		if(anim_prev == "walk_right"):
			animnode.set_current_animation("idle_right")
		elif(anim_prev == "walk_up"):
			animnode.set_current_animation("idle_up")
		elif(anim_prev == "walk_left"):
			animnode.set_current_animation("idle_left")
		elif(anim_prev == "walk_down"):
			animnode.set_current_animation("idle_down")
	elif(dir[0]==1 and dir[1] == 0):
		if(anim_prev != "walk_right"):
			animnode.set_current_animation("walk_right")
	elif(dir[0]==0 and dir[1] == -1):
		if(anim_prev != "walk_up"):
			animnode.set_current_animation("walk_up")
	elif(dir[0]==0 and dir[1] == 1):
		if(anim_prev != "walk_down"):
			animnode.set_current_animation("walk_down")
	elif(dir[0]==-1 and dir[1] == 0):
		if(anim_prev != "walk_left"):
			animnode.set_current_animation("walk_left")
	if(!animnode.is_playing()):
		animnode.play(animnode.get_current_animation())
	#ATTACK TEST
	if(attack and weapontimer>= current_weapon.delay ):
		weapontimer = 0
		Globals.set("player_is_attacking",true)
		var aoe = Area2D.new()
		aoe.set_enable_monitoring(true)
		aoe.set_collision_mask(0)
		aoe.scale(Vector2(3.0,3.0))
		print(aoe)
		var bodies = aoe.get_overlapping_bodies()
		for i in bodies:
			print(i)
			i.set("health",0)
		aoe.free()
	else:
		Globals.set("player_is_attacking",false)
	weapontimer+=delta
	# GET MOVEMENT DIRECTION EVEN (IN)SANER X2
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
	#if(is_colliding()):
	#	get_collider().set("health",0)
	#	print("colloding with ", get_collider())