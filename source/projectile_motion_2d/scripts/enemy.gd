extends Node2D

onready var player = $"../Spaceship"
var bullet = preload( "res://scenes/bullet.tscn" )
var rocket = preload( "res://scenes/rocket.tscn" )

var vector_to_player = Vector2()
var orientation      = 90.0
var facing           = Vector2()
var velocity         = Vector2()

var laser_timer      = 0.0
var laser_delay      = 2.5
var laser_toggle     = false

var rocket_timer     = 2.0
var rocket_delay     = 3.0
var rocket_toggle    = false

var target_heading   = 0.0
var target_solution  = false
var predictive_aim   = Vector2()

var time_to_target_1 = 0.0
var time_to_target_2 = 0.0
var bullet_speed = 15.0

var display_toggle  = true

func _ready():
	pass
	
func _physics_process( delta ):
	vector_to_player = player.position - self.position
	process_input()
#	follow_player()
	calculate_targeting_solution( self, player, bullet_speed )
	display_aiming()
	use_weapons(delta)

func calculate_targeting_solution( origin, target, projectileVelocity ):
	target_solution      = false
	vector_to_player     = target.position - origin.position
	var relativeVelocity = target.velocity  - origin.velocity

	var a = relativeVelocity.length_squared() - pow( projectileVelocity, 2 )
	var b = 2.0 * relativeVelocity.dot( vector_to_player )
	var c = vector_to_player.length_squared()
	var root = b * b - 4.0 * a * c
	if root >= 0:
		var distance = sqrt( root )
		time_to_target_1   = ( -b - distance ) / ( 2.0 * a )
		time_to_target_2   = ( -b + distance ) / ( 2.0 * a )

		if time_to_target_1 >= 0.0 || time_to_target_2 >= 0.0 :
			var best_time = time_to_target_1
			if time_to_target_1 < 0.0 || (time_to_target_2 < time_to_target_1 && time_to_target_2 >= 0.0):
				best_time = time_to_target_2
			predictive_aim  = vector_to_player + relativeVelocity * best_time
			target_heading  = atan2( predictive_aim.y, predictive_aim.x )
			target_solution = true

func process_input():
	if  Input.is_action_just_pressed("toggle_laser"):
		laser_toggle = not laser_toggle

	if  Input.is_action_just_pressed("toggle_missile"):
		rocket_toggle = not rocket_toggle
		
	if  Input.is_action_just_pressed("toggle_display"):
		display_toggle = not display_toggle
		
func follow_player():
	velocity *= 0.96
	if vector_to_player.length() > 400:
		velocity += vector_to_player.normalized() * ( vector_to_player.length() - 400 ) / 30
	position += velocity 

	orientation = atan2( vector_to_player.y, vector_to_player.x)
	facing      = Vector2 ( cos( orientation ), sin( orientation ) )
	$Sprite.rotation = orientation
	
func display_aiming():
	if target_solution:
		$aim.position = predictive_aim
		$aim.visible = true 
		update()
	else:
		get_node("aim").visible = false

func use_weapons( delta ):
	laser_timer  += delta
	if laser_timer >= laser_delay:
		if laser_timer >= 3:
			laser_delay = rand_range( 1.8, 2.5 )
			laser_timer = 0
		laser_delay += ( rand_range( 0.05, 0.07 ) + rand_range( 0.05, 0.07 ) )
		if target_solution and rocket_toggle:
			create_bullet( target_heading )

	rocket_timer += delta
	if rocket_timer > rocket_delay and laser_toggle :
		create_rocket()
		pass

func create_bullet( angle ):
	var new_bullet      = bullet.instance()
	new_bullet.id       = 1
	new_bullet.velocity = velocity + Vector2 ( cos( angle ), sin( angle ) ) * bullet_speed
	new_bullet.position = self.position
	new_bullet.rotation = angle
	$"../bullets".add_child( new_bullet )

func create_rocket():
	rocket_timer           = 0
	var new_rocket         = rocket.instance()
	new_rocket.velocity    = vector_to_player.normalized()
	new_rocket.orientation = orientation
	get_node("../rockets").add_child( new_rocket )
	new_rocket.position = self.position

func _draw():
	if target_solution:
		draw_line( Vector2(), predictive_aim, Color( 1.0, 0.0, 0.0, 0.5 ),1 )
		if display_toggle:
			draw_circle_arc_poly(player.position-position, (player.velocity-velocity).length()*time_to_target_1, 0, 360, Color(0,0,0))
			draw_circle_arc_poly(Vector2(), bullet_speed * time_to_target_1, 0, 360, Color(0,0,0))
			draw_circle_arc_poly(player.position-position, (player.velocity-velocity).length()*time_to_target_2, 0, 360, Color(0,0,1))
			draw_circle_arc_poly(Vector2(), bullet_speed * time_to_target_2, 0, 360, Color(0,0,1))

func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var nb_points  = 36
	var points_arc = PoolVector2Array()
	var prev_point = center + Vector2(0,-1) * radius
#	points_arc.push_back( prev_point )
	
	for i in range( nb_points + 1 ):
		var angle_point = deg2rad(angle_from + i * ( angle_from - angle_to ) / nb_points - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)
		
	points_arc.push_back( prev_point )
	draw_polyline( points_arc, color, 1, true )
