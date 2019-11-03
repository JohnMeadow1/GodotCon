extends Node2D

# mouse drag param
var pressed             := false
var selectionDistance   := 20.0
var prev_mouse_position := Vector2.ZERO
var selection:PointMass

var use_mouse_point_drag = false

func _physics_process(delta):
	# mouse drag :
	if pressed && selection != null:
		if selection.is_static:
			selection.global_transform.origin =  get_local_mouse_position()
			selection.previous_position  = selection.position
		selection.global_transform.origin   = get_local_mouse_position()
		selection.velocity = -(selection.previous_position - selection.position) / delta
		selection.previous_position  = selection.position
		selection.projected_position = selection.position
	
func _input(event):
	if event is InputEventMouseButton:
		if event.pressed:
			pressed   = true
			selection = null
			for body in $Viewport.get_children():
				for node in body.get_node("verticles").get_children():
					if event.position.distance_to( node.global_transform.origin ) < selectionDistance:
						selection = node
						break
			for body in $soft_bodies.get_children():
				for node in body.get_node("verticles").get_children():
					if event.position.distance_to( node.global_transform.origin ) < selectionDistance:
						selection = node
						break
		else:
			pressed   = false
			selection = null

	if event.is_action_pressed("ui_accept"):
		$Viewport/puncher.punch_velocity += Vector2 (900, -200)
