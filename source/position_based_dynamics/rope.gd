#tool
extends PositionBasedDynamics
class_name Rope

export var verticles:int = 10
export var verticles_distance:float = 10.0

var wind:float = 0.0

func _ready():
#	if !Engine.is_editor_hint():
	generate_rope_body( verticles, verticles_distance )
	$Sprite.visible = false

func _physics_process(delta):
	wind += delta
	for node in $verticles.get_children():
		if node.is_static != true:
			external_force.x = abs(sin(wind + node.position.y/100.0) + abs(sin((wind+ node.position.y/100.0)*3.67))) * 1000
			aplly_external_forces( node, delta )
			apply_velocity_damping( node, delta, damping )
			calculate_projected_position( node, delta )

	solve_distance_constraint( 4, 1.0 )
	solve_floor_collision_constraint( 700.0 - position.y )
	update_vertex_position( delta )
	update_line2D_verticles()

func update_line2D_verticles ():
	var i:int = 0
	for node in $verticles.get_children():
		$Line2D.points[i] = node.position
		i += 1

func generate_rope_body( verticles:int = 2, separation:int = 10 ):
	for i in range(verticles):
		var new_position = Vector2( 0, separation * i  )
		if i == 0:
			add_vertex( new_position, true )
		else:
			add_vertex( new_position, false )
		$Line2D.add_point( new_position )

	$verticles.get_child($verticles.get_child_count()-1).get_node("sprite").visible = true

	for i in range(verticles-1):
		add_spring( $verticles.get_child_count() -i -1, $verticles.get_child_count() -i -2, compress_stiffness, stretch_stiffness )

