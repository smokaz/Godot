extends KinematicBody2D
# Script for melee monster that follows player if it is close enough

#MEMBER VARS
var delay = 1.5 #attack delay in seconds
var movespeed = 1.5 #exactly this
var visible_range = 150 #inside this monster paths to player
var attack_range = 30 #inside this monster attacks
var accum_delay = 0 #accumulation variable for attack delay
var pathvec = Vector2(0.0,0.0) #monster does not know where player is
var pathlength = 0 #we neeed this quite often
var health = 100 #health of monster
#stuff for AI
var state_foundplayer = false
var state_attackplayer = false
var state_underattack = false
#stuff for animations
var animnode
var anim_prev
var state_previous = "" #purely test for smooothing when leaving attack range
var state_facing
#INITALIZE
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	add_to_group("Monsters")	
	# init animations
	animnode = get_node("Monster_Sprite/AnimationPlayer")
	animnode.set_current_animation("idle_left")
	state_facing = "left"
	set_fixed_process(true)
	pass
#PROCESS AI
func _fixed_process(delta):

	#SEARCH FOR PLAYER, AND SET THE STATES
	if(Globals.has("player_pos")): #check if player position is defined first
		pathvec = Globals.get("player_pos")-get_pos() #update rel. pos to player
		pathlength = pathvec.length() #store length
		pathvec = pathvec.normalized() #normalize vector
		if(pathlength<visible_range): #check if monster sees player
			state_foundplayer = true
			if(pathlength<=attack_range): #check if close enough to attack
				state_attackplayer = true
			else:
				state_attackplayer = false
		else: #player has moved beyond sight, stop all activity
			state_foundplayer = false
			state_attackplayer = false #not needed usually

	#SEARCH IF PLAYER IS ATTACKING MONSTER
	if(Globals.has("player_is_attacking")): #check if defined
		if(Globals.get("player_is_attacking")): #I see an angry player!
			#Here implement monster trying to figure out if it was attacked
			if(Globals.has("player_maximum_melee_attack_range")): #check define
				if(pathlength<Globals.get("player_maximum_melee_attack_range")):
					state_underattack = true
				else:
					state_underattack = false
			# Can implement a max ranged weapon range to avoid kiting
			# probably better to just check if monster health changed
			# though this method could possibly have it avoid getting hit
	
	# PROCESS SEARCH STATES
	#First check if monster is under attack THIS FEATURE IS BROKEN
	if(state_underattack):  
		if(accum_delay<delay): #we can't attack, run away
			move(-pathvec*4*movespeed) #move away from player
			get_node("Label").set_text("RUN AWAY")
			state_underattack = false
		elif(accum_delay>=delay):
			state_underattack = false #ignore it and attack
	
	if(state_foundplayer and not state_underattack): #is player visible and not attacking
		if(state_attackplayer): #is player close enough to attack
			if(accum_delay>=delay):# TO_DO: implement attacking
				get_node("Label").set_text("ATTACK") #too fast to see
				accum_delay = 0
				state_previous = "state_attack_now" #this is to tell anim
				# to initaite an attack animation
				# IMPlEMENT ATTACK
			else:
				get_node("Label").set_text("ATTACK + WAIT") #refresh cooldown
				accum_delay+=delta
		else: #no attack? then close in on player!
			get_node("Label").set_text("MOVE")
			move(pathvec*movespeed)
			#LEEEEEWAAAAAAAAAAAAAAAAAAAAY DO NOT MOVE WHEN SO CLOSE
			#if(anim_prev != "left_attack" and state_previous != "state_attackplayer"
			#or pathlength<=attack_range): #fix leeway bug with or
			#move(pathvec*movespeed) #move towards player
			if(accum_delay<delay):
				get_node("Label").set_text("MOVE + WAIT")
				accum_delay+= delta #refresh cooldown if nearby player
	elif(not state_foundplayer): #can't see player? sit on your ass then
		get_node("Label").set_text("IDLE")
		accum_delay = delay #reset cooldown in case player comes

	# ANIMATIONS - very tricky ? still cardinal because fuck it
	anim_prev = animnode.get_current_animation()
	#First, we need to determine what direction we were facing
	if(anim_prev == "walk_right"
	or anim_prev == "idle_right"
	or anim_prev == "attack_right"):
		state_facing = "right"
	elif(anim_prev == "walk_left"
	or anim_prev == "idle_left"
	or anim_prev == "attack_left"):
		state_facing = "left"
	elif(anim_prev == "walk_up"
	or anim_prev == "idle_up"
	or anim_prev == "attack_up"):
		state_facing = "up"
	else:
		state_facing = "down"
	#Now we need to determine what state we are in
	#and then change animations accordingly
	if(not state_foundplayer):
		#we are currently idle
		if(state_facing == "right" and anim_prev != "idle_right"):
			animnode.set_current_animation("idle_right")
		elif(state_facing == "up" and anim_prev != "idle_up"):
			animnode.set_current_animation("idle_up")
		elif(state_facing == "left" and anim_prev != "idle_left"):
			animnode.set_current_animation("idle_left")
		elif( state_facing == "down" and anim_prev != "idle_down"):
			animnode.set_current_animation("idle_down")
		state_previous = "" #as in no state (maybe this is dumb)
	elif(state_attackplayer):
		#we are currently close enough to attack
		if(state_previous == "state_attack_now"):
			#OK, we need to attack NOW
			if(state_facing == "left"):
				animnode.set_current_animation("attack_left")
				animnode.play("attack_left")
			elif(state_facing == "right"):
				animnode.set_current_animation("attack_right")
				animnode.play("attack_right")
			elif(state_facing == "up"):
				animnode.set_current_animation("attack_up")
				animnode.play("attack_up")
			elif(state_facing == "down"):
				animnode.set_current_animation("attack_down")
				animnode.play("attack_down")
			state_previous = "state_attackplayer"
		else:
			#we are close enough to attack, but have to wait
			if(not animnode.is_playing() or state_previous != "state_attackplayer"):
				#we don't interrupt animation unless we were walking
				if(state_facing == "left" and anim_prev != "idle_left"):
					#but we still don't interrupt our own animation
					animnode.set_current_animation("idle_left")
				elif(state_facing == "right" and anim_prev != "idle_right"):
					animnode.set_current_animation("idle_right")
				elif(state_facing == "up" and anim_prev != "idle_up"):
					animnode.set_current_animation("idle_up")
				elif(state_facing == "down" and anim_prev != "idle_down"):
					animnode.set_current_animation("idle_down")
				state_previous = "idle_between_attacks"
	else: 
	#We are neither idle nor close enough to attack, so we must be moving
		if(abs(pathvec.x)>=abs(pathvec.y)): #check if x direction dominates
			if(pathvec.x<0): #going left
				if(state_previous == "idle_between_attacks"):
					if(pathlength>=attack_range*1.10):
						if(anim_prev == "idle_left" and anim_prev != "attack_left"):
							animnode.set_current_animation("walk_left")
							#state_previous = "state_walking"
				elif(state_previous == "state_attack_player"):
					if(!animnode.is_playing()):
						animnode.queue("walk_left")
				elif(anim_prev != "walk_left"):
					if(anim_prev == "attack_left"):
						animnode.clear_queue()
						animnode.queue("walk_left")
					if(pathlength>=attack_range*1.05): # <- this is were shit happens
						animnode.queue("walk_left")
						state_previous = "state_walking"
	#loop current animation
	if(not animnode.is_playing()):
		animnode.play(animnode.get_current_animation())
	#print(state_previous)
	# DEATH
	if(health<=0):
		get_node("Label").set_text("DEAD")
		get_node("CollisionShape2D").free()
		if(state_facing=="left"):
			animnode.play("die_left")
		set_fixed_process(false)
		for i in get_parent().get_children():
			if(i.is_in_group("Player_group")):
				i.set("experience_current",i.get("experience_current")+10)