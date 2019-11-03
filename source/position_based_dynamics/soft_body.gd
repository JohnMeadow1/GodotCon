#tool
class_name Boop
extends Node2D

var link_object  := load("res://link.tscn") as PackedScene
var point_object := load("res://point_mass.tscn") as PackedScene

export var external_force := Vector2( 0.0, 980.0 )

export var compress_stiffness:= 0.5
export var stretch_stiffness := 0.5

func _ready():
#	if !Engine.is_editor_hint():
	generate_test_body( Vector2( 500, 300 ), 10, 20 )

func _physics_process(delta):
	for node in $verticles.get_children():
		if node.is_static != true:
			aplly_external_forces( node, delta )
			apply_velocity_damping( node, delta )
			calculate_projected_position( node, delta )

	solve_floor_collision_constraint()
	solve_distance_constraint()
	update_vertex_position( delta )
	
func aplly_external_forces( node, delta ):
	node.velocity += node.inverted_mass * (external_force + node.gravity) * delta

func apply_velocity_damping( node, delta ):
	node.velocity -= node.velocity * 10 * delta

func calculate_projected_position( node, delta ):
	node.projected_position = node.position + node.velocity * delta
	
func solve_distance_constraint():
	var relax_iterations = 1
	var over_relaxation  = 1 # 1.0-2.0
	for i in range(relax_iterations):
	# consider constrains and calculate projection correction
		for link in $constraints.get_children():
			var displacement = link.point_1.projected_position - link.point_2.projected_position

			var correction:Vector2 = (displacement.length() - link.rest_length) * displacement.normalized()
			correction = link.constrain_vector + displacement
			if displacement.length() < link.rest_length:
				correction = compress_stiffness * correction
			else:
				correction = stretch_stiffness * correction

			link.point_1.correction_projection -= 0.5 * correction * link.point_1.inverted_mass
			link.point_2.correction_projection += 0.5 * correction * link.point_2.inverted_mass
	#		var torque =  point_2.cross((link.point_2.position-link.point_2.projected_position)*delta)
	#		link.c_param = link.c_param.rotated(0.01)

		# update projections
		for node in $verticles.get_children():
			node.projected_position += node.correction_projection / float(relax_iterations) * over_relaxation
			node.correction_projection = Vector2.ZERO

func solve_floor_collision_constraint():
	for node in $verticles.get_children():
		if node.projected_position.y > 800:
			node.projected_position.y = 800

func update_vertex_position( delta ):
	var i:int = 0
	for node in $verticles.get_children():
		if node.is_static != true:
			node.velocity = (node.projected_position - node.position) / delta
			node.previous_position = node.position
			node.position = node.projected_position
#			node.position += node.velocity * delta
		else:
			node.projected_position   = node.position
			node.correction_projection = Vector2.ZERO
		$Line2D.points[i] = node.position
		i += 1

func generate_test_body(pos:Vector2 = Vector2( 300, 500 ), size:int = 2, separation:int = 10 ):
	for i in range(size):
		if i == 0:
			add_vertex( Vector2( pos.x+i*2, pos.y - separation * i  ), true)
		else:
			add_vertex( Vector2( pos.x+i*2, pos.y - separation * i  ), false)
		$Line2D.add_point( Vector2( pos.x+i*2, pos.y - separation * i) )
#	$verticles.get_child(0).get_node("sprite").visible = true
	$verticles.get_child($verticles.get_child_count()-1).get_node("sprite").visible = true

	for i in range(size-1):
		add_spring( $verticles.get_child_count() -i -1, $verticles.get_child_count() -i -2  )

func generate_square_body( square_position:Vector2, size:float )->void:
	for i in range(4):
		for j in range(4):
#			if i == 0:
#				add_vertex(  Vector2( j, i ) * size + square_position, true)
#			else:
				add_vertex(  Vector2( j, i ) * size + square_position, false)

	for i in range(4):
		for j in range(4):
			if j < 3:
				add_spring($verticles.get_child_count()-16 + i*4 + j, $verticles.get_child_count()-16 + i*4 + (j+1) )
			if i < 3:
				add_spring($verticles.get_child_count()-16 + i*4 + j, $verticles.get_child_count()-16 + (i+1)*4 + j )

func add_vertex( new_position:Vector2 = Vector2( 300.0, 300.0 ), is_static:bool = false ) -> void :
	var new_point_mass := point_object.instance() as PointMass
	new_point_mass.is_static = is_static
	new_point_mass.position = new_position
	new_point_mass.previous_position = new_position
	$verticles.add_child(new_point_mass)

func add_spring( node_index_1, node_index_2 )->void:
	var link := link_object.instance()
	(link as LinkNode).initialize( $verticles.get_child(node_index_1), $verticles.get_child(node_index_2) )
	$constraints.add_child( link )
