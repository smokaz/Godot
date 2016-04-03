extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"
var bodies
var array_already_dealt_damage = []
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	get_node("Sprite/AnimationPlayer").play("auto")
	set_fixed_process(true)
	
	pass
func _fixed_process(delta): #get_parent 2 ganger fordi vi vil ha kinematic body
# dette har igjen noe å gjøre med at vi må finne en måte å ha finne en måte
#å hente ut en spesifikk node fra en scene når vi instancer
	bodies = get_node("Area2D").get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("Monsters"):
			if (!(i in array_already_dealt_damage)):
				get_parent().get_parent().deal_damage_to(i)
				array_already_dealt_damage.append(i)
	if(!get_node("Sprite/AnimationPlayer").is_playing()):
		get_parent().free()