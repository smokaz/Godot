extends KinematicBody2D

# member variables here, example:
# var a=2
# var b="textvar"
var bodies
func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	#get_node("AnimationPlayer").play("auto")
	set_fixed_process(true)
	pass
func _fixed_process(delta):
	bodies = get_node("Area2D").get_overlapping_bodies()
	for i in bodies:
		if i.is_in_group("Monsters"):
			i.set("health",-10) 
	#if(!get_node("AnimationPlayer").is_playing()):
		#get_node(".").free()


