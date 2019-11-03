#tool
extends PositionBasedDynamics
class_name Puncher

export var verticles:int = 10
export var verticles_distance:float = 10.0

var wind:float = 0.0
var punch_position:= Vector2.ZERO
var punch_velocity:= Vector2.ZERO

func _ready():
#	if !Engine.is_editor_hint():
	generate_rope_body( verticles, verticles_distance )
	$Sprite.visible = false

func _physics_process(delta):
	wind += delta
	for node in $verticles.get_children():
		if node.is_static != true:
#			external_force.x = abs(sin(wind + node.position.y/100.0) + abs(sin((wind+ node.position.y/100.0)*3.67))) * 1000
			aplly_external_forces( node, delta )
			apply_velocity_damping( node, delta, damping )
			calculate_projected_position( node, delta )

	solve_distance_constraint( 2, 1.0 )
	solve_floor_collision_constraint( 700.0 - position.y )
	update_vertex_position( delta )
	update_line2D_verticles()
	var distance = ($verticles.get_child(verticles -1).position - punch_position).length()
	$verticles.get_child(verticles -1).position += (punch_velocity + Vector2(0,180))* delta
	if distance > punch_position.length():
		punch_velocity -= ($verticles.get_child(verticles -1).position - punch_position) *10 * delta
	elif distance < punch_position.length():
		punch_velocity -= ($verticles.get_child(verticles -1).position - punch_position) *30 * delta

	punch_velocity *= 0.98
	
	for node in get_node("../stiff_soft_box/verticles").get_children():
		print ()
		distance = (node.global_position - $verticles.get_child(verticles -1).global_position )
		if distance.length() < 20:
			node.velocity += distance.normalized() * 1000
			
#	$verticles.get_child(verticles -1).position = punch_position
func update_line2D_verticles ():
	var i:int = 0
	for node in $verticles.get_children():
		$Line2D.points[i] = node.position
		i += 1

func generate_rope_body( verticles:int = 2, separation:int = 10 ):
	for i in range(verticles):
		var new_position = Vector2( separation * i, 0  )
		if i == 0 or i == verticles-1:
			add_vertex( new_position, true )
		else:
			add_vertex( new_position, false )
		$Line2D.add_point( new_position )
	punch_position = $verticles.get_child($verticles.get_child_count()-1).position - Vector2(20,0)
	$verticles.get_child($verticles.get_child_count()-1).get_node("sprite").visible = true

	for i in range(verticles-1):
		add_spring( $verticles.get_child_count() -i -1, $verticles.get_child_count() -i -2, compress_stiffness, stretch_stiffness )

