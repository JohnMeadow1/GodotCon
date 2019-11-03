#tool
extends PositionBasedDynamics
class_name ClothPDB

export var verticles:int = 10
export var verticles_distance:float = 10.0

var wind:float = 0.0
var tree_top:Node2D

func _ready():
	generate_cloth_body( verticles, verticles_distance )
	
func _physics_process(delta):
	wind += delta
#	delta *= 0.01
	for node in $verticles.get_children():
		if node.is_static != true:
#			external_force.x = abs(sin(wind + node.global_position.x/1000.0) + abs(sin((wind+ node.global_position.x/1000.0)*3.67))) * 1000
			aplly_external_forces( node, delta )
			apply_velocity_damping( node, delta, damping )
			calculate_projected_position( node, delta )

	solve_floor_collision_constraint( 700.0 - position.y )
	solve_distance_constraint( 2, 1 )
	update_vertex_position( delta )
#	update_line2D_verticles()

func update_line2D_verticles ():
	var i:int = 0
	for node in $verticles.get_children():
		$Line2D.points[i] = node.position
		i += 1

func generate_cloth_body( nodes:int, size:float )->void:
	for i in range(nodes):
		for j in range(nodes):
			if i == 0:
				add_vertex(  Vector2( j, i ) * size, true , 1.0)
			else:
				add_vertex(  Vector2( j, i ) * size, false , 1.0)
	var total_nodes = nodes*nodes
	for i in range(nodes):
		for j in range(nodes):
			if j < nodes-1:
				add_spring($verticles.get_child_count() - total_nodes + i * nodes + j, $verticles.get_child_count() - total_nodes + i*nodes + (j+1), compress_stiffness, stretch_stiffness )
			if i < nodes-1:
				add_spring($verticles.get_child_count() - total_nodes + i * nodes + j, $verticles.get_child_count() - total_nodes + (i+1)*nodes + j, compress_stiffness, stretch_stiffness )

	for link in $constraints.get_children():
		link.get_node("spring").visible = true
#	for link in $verticles.get_children():
#		link.get_node("sprite").visible = true
	
