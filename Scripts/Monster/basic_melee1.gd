extends KinematicBody2D
# Script for melee monster that follows player if it is close enough

#MEMBER VARS
var delay = 2 #attack delay in seconds
var movespeed = 1
var visible_range = 150
var attack_range = 30
var accum_delay = 0
var pathvec = Vector2(0.0,0.0) #monster does not know where player is
var pathlength = 0 #we neeed this quite often
var health = 100
var state_foundplayer = false
var state_attackplayer = false
var state_underattack = false
#INITALIZE
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	add_to_group("Monsters")
	set_fixed_process(true)
	pass
#PROCESS AI
func _fixed_process(delta):

	#SEARCH FOR PLAYER, AND SET THE STATES
	if(Globals.has("player_pos")): #check if player position is defined first
		pathvec = Globals.get("player_pos")-get_pos() #update rel. pos to player
		pathlength = pathvec.length()
		if(pathvec.length()<visible_range): #check if monster sees player
			state_foundplayer = true
			if(pathlength<attack_range): #check if close enough to attack
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
	#First check if monster is under attack
	if(state_underattack):
		if(accum_delay<delay): #we can't attack, run away
			move(-pathvec.normalized()*4*movespeed) #move away from player
			get_node("Label").set_text("RUN AWAY")
			state_underattack = false
		elif(accum_delay>=delay):
			state_underattack = false #ignore it and attack
	
	if(state_foundplayer and not state_underattack): #is player visible and not attacking
		if(state_attackplayer): #is player close enough to attack
			if(accum_delay>=delay):# TO_DO: implement attacking
				get_node("Label").set_text("ATTACK") #too fast to see
				accum_delay = 0
				# IMPlEMENT ATTACK
			else:
				get_node("Label").set_text("ATTACK + WAIT") #refresh cooldown
				accum_delay+=delta
		else: #no attack? then close in on player!
			get_node("Label").set_text("MOVE")
			move(pathvec.normalized()*movespeed) #move towards player
			if(accum_delay<delay):
				get_node("Label").set_text("MOVE + WAIT")
				accum_delay+= delta #refresh cooldown if nearby player
	elif(not state_foundplayer): #can't see player? sit on your ass then
		get_node("Label").set_text("IDLE")
		accum_delay = delay #reset cooldown in case player comes
	# Collison
	if(health<=0):
		get_node("Label").set_text("DEAD")
		set_fixed_process(false)
		#free()