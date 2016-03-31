extends KinematicBody2D

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
# PLAYER INVENTORY
class Weapon:
	var inventory_pos
	var inventory_sprite
	var damage
	var delay
	var sprite

# INITALIZE PLAYER
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	set_fixed_process(true)
	animnode = get_node("Sprite/AnimationPlayer")
	animnode.set_current_animation("idle_down")
	get_node("Exp_bar").set_value(100*experience_current/experience_tolevel)
	get_node("Exp_bar/Exp_label").set_text("EXP")

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
	#if(attack): #stand-in test
	
	# GET MOVEMENT DIRECTION EVEN (IN)SANER X2
	dir[1] = down-up
	dir[0] = right-left
	if(acceleration<speed):
		acceleration += 4*delta
	elif(acceleration>speed):
		acceleration = speed
	self.move(Vector2(dir[0], dir[1]).normalized()*acceleration)