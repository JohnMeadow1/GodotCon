#tool
extends Node2D
class_name PositionBasedDynamics

var link_object  := load("res://distance_constraint.tscn") as PackedScene
var point_object := load("res://point_mass.tscn") as PackedScene

export var is_stiff_body:bool = true
export var is_tearable_body:bool = true

export var compress_stiffness:= 0.5
export var stretch_stiffness := 0.5

export var external_force := Vector2( 0.0, 0.0 )
export var gravity := Vector2( 0,  980 )

export var damping := 1

var correction:= Vector2.ZERO

func _ready():
	pass
	
func aplly_external_forces( node, delta ):
	node.velocity += node.inverted_mass * ( external_force + gravity ) * delta

func apply_velocity_damping( node, delta, damping:float = 10.0 ):
	# this can be rewritten to only to damp velocity projected on constrain 
	# so it damps only the velocity in reltaion to constrains 
	node.velocity -= node.velocity * damping * delta

func calculate_projected_position( node, delta ):
	node.projected_position = node.position + node.velocity * delta
	
func solve_distance_constraint( relax_iterations:int = 1, over_relaxation:int = 1 ):
	# over_relaxation should be in range ( 1.0 - 2.0 ) 
	for i in range(relax_iterations):
		# consider constrains and calculate projection correction
		for link in $constraints.get_children():
			var displacement = link.point_1.projected_position - link.point_2.projected_position

			if is_stiff_body:
				correction = link.constrain_vector + displacement
			else: 
				correction = (displacement.length() - link.rest_length) * displacement.normalized()
				
			if displacement.length() < link.rest_length:
#				correction = link.compress_stiffness * correction 
				correction = (1 - pow(1 - link.compress_stiffness, 1.0/float(relax_iterations))) * correction
			elif displacement.length() > link.rest_length:
#				correction = link.stretch_stiffness * correction
				correction = (1 - pow(1 - link.stretch_stiffness, 1.0/float(relax_iterations)))  * correction
				
			if is_tearable_body and displacement.length() > link.rest_length*4:
				correction = (1 - pow(1 - link.stretch_stiffness, 1.0/float(relax_iterations)))  * correction
				link.queue_free()
				
			link.point_1.correction_projection -= link.mass_ratio_1 * correction * link.point_1.inverted_mass 
			link.point_2.correction_projection += link.mass_ratio_2 * correction * link.point_2.inverted_mass

		# update projections
		for node in $verticles.get_children():
			node.projected_position += node.correction_projection * over_relaxation
			node.correction_projection = Vector2.ZERO

func solve_floor_collision_constraint( level:float = 600 ):
	# so yes. I should have handeled collisions here.
	for node in $verticles.get_children():
		if node.projected_position.y > level:
			node.projected_position.y = level


func update_vertex_position( delta ):
	for node in $verticles.get_children():
		if node.is_static != true:
			node.velocity = (node.projected_position - node.position) / delta
			node.previous_position = node.position
			node.position = node.projected_position
		else:
			node.projected_position   = node.position
			node.correction_projection = Vector2.ZERO

func add_vertex( new_position:Vector2 = Vector2( 300.0, 300.0 ), is_static:bool = false, new_mass:float = 1.0 ) -> void :
	var new_point_mass := point_object.instance() as PointMass
	new_point_mass.is_static = is_static
	new_point_mass.position = new_position
	new_point_mass.previous_position = new_position
	new_point_mass.set_mass(new_mass)
	$verticles.add_child(new_point_mass)

func add_spring( node_index_1, node_index_2, new_compress, new_stretch  )->void:
	var link := link_object.instance()
	(link as LinkNode).initialize( $verticles.get_child(node_index_1), $verticles.get_child(node_index_2) )
	link.compress_stiffness = new_compress
	link.stretch_stiffness = new_stretch
	$constraints.add_child( link )
