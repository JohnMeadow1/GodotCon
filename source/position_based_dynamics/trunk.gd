#tool
extends PositionBasedDynamics
class_name Trunk

export var verticles:int = 10
export var verticles_distance:float = 10.0

var wind:float = 0.0
#var tree_top:Node2D

func _ready():
	generate_trunk_body( verticles, verticles_distance )
	$Sprite.visible = false
	
func _physics_process(delta):
	wind += delta
	for node in $verticles.get_children():
		if node.is_static != true:
			external_force.x = abs(sin(wind + node.global_position.x/1000.0) + abs(sin((wind+ node.global_position.x/1000.0)*3.67))) * 1000
			aplly_external_forces( node, delta )
			apply_velocity_damping( node, delta, damping )
			calculate_projected_position( node, delta )

#	solve_floor_collision_constraint( 700.0 - position.y )
	solve_distance_constraint( 1, 1 )
	update_vertex_position( delta )
	update_line2D_verticles()
	update_leafs_root()

func update_leafs_root():
	for leaf in $leafs.get_children():
		leaf.tree_top = $verticles.get_child( verticles - 1 ).position - leaf.position

func update_line2D_verticles ():
	var i:int = 0
	for node in $verticles.get_children():
		$Line2D.points[i] = node.position
		i += 1

func generate_trunk_body( verticles:int = 2, separation:int = 10 ):
	var new_position := Vector2.ZERO
	for i in range(verticles):
		if i == 0:
			add_vertex( new_position, true,  (verticles - i) / float(verticles) * 5 )
		else:
			add_vertex( new_position, false, (verticles - i) / float(verticles) * 5 )
		$Line2D.add_point( new_position )
		new_position += Vector2( 0, -separation * 1.6 )

	for leaf in $leafs.get_children():
		leaf.position = new_position - Vector2( 0, -separation * 1.6 )

	for i in range( verticles - 1 ):
		add_spring( $verticles.get_child_count() -i -1, $verticles.get_child_count() -i -2, compress_stiffness , stretch_stiffness  )
