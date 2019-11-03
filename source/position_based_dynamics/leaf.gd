#tool
extends PositionBasedDynamics
class_name Leaf

export var verticles:int = 5
export var verticles_distance:float = 20.0
export var angle:int = 0

var wind:float = 0.0
var tree_top: = Vector2.ZERO

func _ready():
	randomize()
	angle += rand_range(-5,5)
	generate_leaf_body( verticles, verticles_distance, deg2rad(angle) )
	$Sprite.visible = false
	
func _physics_process(delta):
	wind += delta
#	external_force.x = (sin(wind) + sin((wind)*3.67)) * 100
	for node in $verticles.get_children():
		if node.is_static != true: 
			external_force.x = abs(sin(wind + node.position.x/10.0) + abs(sin((wind+ node.position.x/10.0)*3.67))) * 500
			external_force.y = abs(sin(wind + node.position.y/10.0) + abs(sin((wind+ node.position.y/50.0)*3.67))) * 500
			aplly_external_forces( node, delta )
			apply_velocity_damping( node, delta, damping )
			calculate_projected_position( node, delta )
		else:
			node.position = tree_top

	solve_floor_collision_constraint( 700 - position.y )
	solve_distance_constraint( 1, 1 )
	update_vertex_position( delta )
	update_line2D_verticles()

func update_line2D_verticles ():
	var i:int = 0
	for node in $verticles.get_children():
		$Line2D.points[i%verticles] = node.position
		i += 1

func generate_leaf_body( verticles:int = 2, separation:int = 10, angle:float = 0.0 ):
	
	var new_position := Vector2.ZERO
	for i in range( verticles ):
		if i == 0: add_vertex( new_position, true,  (verticles - i)/float(verticles)*10 )
		else:      add_vertex( new_position, false, (verticles - i)/float(verticles)*10 ) 
		$Line2D.add_point( new_position )
		var leaf_rotation = i * angle
		new_position += Vector2( sin(angle + leaf_rotation), -cos(angle + leaf_rotation) ) * separation 

	for i in range(verticles-1):
#		var new_stretch = (i+1) * (1.0/float(verticles)) * stretch_stiffness
		var new_stretch = stretch_stiffness
		var new_compress = (i+1) * (1.0/float(verticles)) * compress_stiffness
		add_spring( $verticles.get_child_count() -i -1, $verticles.get_child_count() -i -2, new_compress, new_stretch )
