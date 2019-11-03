#tool
class_name PointMass
extends Node2D

var velocity          := Vector2( 0.0, 0.0 )
var previous_position := Vector2( 0.0, 0.0 )

var mass:float           = 1.0 setget set_mass
var inverted_mass:float  = 1.0 / mass

var neighbors:Array      = []

var projected_position   := Vector2.ZERO
var correction_projection := Vector2.ZERO

#onready var debug = get_node("../../GUI/Debug")

export(bool) var is_static:bool = false setget set_static

func set_static(value):
	is_static = value
	if is_static:
		get_node("sprite").modulate = Color( 1.0, 0.0, 0.0 )
	else:
		get_node("sprite").modulate = Color( 1.0, 1.0, 1.0 )

func add_neighbor(point_mass):
	neighbors.append(point_mass)
#	resting_length.append((point_mass.position - position).length())
#	stiffness.append(20)
	
func _ready():
	previous_position = position - velocity * get_physics_process_delta_time()
	projected_position = position
	correction_projection = Vector2.ZERO
	
#func _physics_process(delta):
#	$prev_pos_indicator.position = previous_position - position
#	update()
#func get_force():
#	force = Vector2()
#	torque = 0.0 
#	for i in range( neighbors.size() ):
#		var direction = neighbors[i].position - position
#		var distance  = direction.length() - resting_length[i]
#		var relative_velocity = velocity - neighbors[i].velocity
#		var damping   = relative_velocity.project(direction)
#		if distance > 0:
#			force += stiffness[i] * distance * direction.normalized() - damping
#
#	force += gravity - self.velocity *0.1

#func euler( delta ):
#	get_force()
#	position += velocity * delta
#	velocity += ( force + gravity )  * delta - velocity * 0.01
#
#func symplectic_euler( delta ):
#	get_force()
#	velocity += force  * delta
#	position += velocity * delta #- velocity * 0.01

func set_mass( new_mass ):
	mass = max(new_mass,0.01)
	inverted_mass = pow( new_mass, -1.0 )

#func _draw():
#	draw_line(Vector2(),projected_position-position, Color.red,5)
#	draw_line(Vector2(),corection_projection, Color.blue,3)
#	draw_line(Vector2(),velocity, Color.green,3)
