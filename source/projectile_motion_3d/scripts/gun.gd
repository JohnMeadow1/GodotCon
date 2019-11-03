extends GeometryInstance

var gravity:float     = 9.8
var fire_timer:float  = 0.0

var projectile_object  = preload("res://scenes/projectile.tscn")
onready var target = $"../target"
onready var source = $base1
var projectile_speed:float = 10.0

var sollution_1 = Vector3()
var sollution_2 = Vector3()

func _physics_process(delta):
	$"../GUI/Label".text = ""
	fire_timer += delta
	calculate_trajecotry()
	if fire_timer > 0.8:
		fire_timer = 0
		create_bullet(sollution_1)
		create_bullet(sollution_2)
	
func calculate_trajecotry():
	
	var target_position    = target.global_transform.origin
	var base_position      = source.global_transform.origin
	var vect_2_to_target   = Vector2(target.global_transform.origin.x,target.global_transform.origin.z).normalized()
	var distance_to_target = (Vector2(target_position.z,target_position.x) - Vector2(base_position.z,  base_position.x)).length()
	var height_to_target   = target_position.y - base_position.y
	
	var a = projectile_speed * projectile_speed
	var b = 2 * height_to_target * a
	var c = gravity * distance_to_target * distance_to_target 
	
	var root = a * a - gravity * ( c + b )
	if root >= 0:
		var delta_sqrt = sqrt(root)
		var angle1 = atan2(a + delta_sqrt, gravity * distance_to_target)
		var angle2 = atan2(a - delta_sqrt, gravity * distance_to_target)
		
		sollution_1 = Vector3.BACK*cos(angle1) + Vector3.UP*sin(angle1)
		sollution_2 = Vector3.BACK*cos(angle2) + Vector3.UP*sin(angle2)

		# rotate the base 
		$base1.rotation = Vector3(angle1, 0,0)
		$base2.rotation = Vector3(angle2, 0,0)
		$base1.rotate(Vector3(0,1,0), atan2(vect_2_to_target.x,vect_2_to_target.y))
		$base2.rotate(Vector3(0,1,0), atan2(vect_2_to_target.x,vect_2_to_target.y))
		#rotate the cannon
		sollution_1 = sollution_1.rotated(Vector3(0,1,0), atan2(vect_2_to_target.x,vect_2_to_target.y))
		sollution_2 = sollution_2.rotated(Vector3(0,1,0), atan2(vect_2_to_target.x,vect_2_to_target.y))
		material_override.set("albedo_color", Color(1,1,1))
	else:
		$"../GUI/Label".text += "\nToo far."
		material_override.set("albedo_color", Color(1,0,0))
	
func create_bullet(sollution):
	var new_projectile         = projectile_object.instance()
	new_projectile.translation = $base1.global_transform.origin
	new_projectile.velocity    = sollution * projectile_speed
	new_projectile.gravity     = gravity
	get_node("../projectiles").add_child( new_projectile )
	
