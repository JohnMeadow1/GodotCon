extends Sprite

var velocity = Vector2()
var timer    = 0
var asteroid = Vector2()
var gravity  = Vector2()
var target   = Vector2()
var id       = 0

onready var player   = get_node("../../spaceship")


func _process(delta):
	position += velocity

	timer = timer + delta
	if ( timer > 5 ):
		queue_free()

	if (id == 1):
		if ((player.position -position).length()<20):
			player.explosion()
			queue_free()
#	else:
#		for node in get_node("../../rockets").get_children():
#			if ((node.position - position).length()<20 && node.active == true):
#				node.destroy()
#				queue_free()
