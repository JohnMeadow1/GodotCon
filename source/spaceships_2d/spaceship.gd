extends Node2D

var velocity             = Vector2( 0.0, 0.0 )
var thrust               = 0.0
var ACCELERATION         = 0.35

var angular_velocity     = 0.0
var angular_acceleration = 0.005

var orientation          = 0.0
var facing               = Vector2 ( 0.0, 0.0 )

var bullet               = preload("res://bullet.tscn")
var fire_timer           = 0.0

func _process( delta ):
	process_input( delta )

	angular_velocity = angular_velocity * 0.91
	orientation      = orientation + angular_velocity
	facing           = Vector2 ( cos( orientation ), sin( orientation ) )
	velocity         = velocity * 0.94

	velocity += facing * thrust
	position = position + velocity

	$body.rotation = orientation
	update()

func process_input( delta ):
	
	thrust = 0
	if Input.is_action_pressed("ui_up"):
		thrust =  ACCELERATION
		$body/AnimationPlayer.play("thrust")
	if Input.is_action_pressed("ui_down"):
		thrust = -ACCELERATION
		$body/AnimationPlayer.play("thrust")

	if Input.is_action_pressed("ui_left"):
		angular_velocity = angular_velocity - 0.01
	if Input.is_action_pressed("ui_right"):
		angular_velocity = angular_velocity + 0.01

	if Input.is_action_pressed("ui_select"):
		fire_timer += delta
		if fire_timer > 0.2:
			fire_timer = 0
			create_bullet()

	elif fire_timer < 0.2:
		fire_timer += delta

func create_bullet():
	for i in range(2):
		var new_bullet = bullet.instance()
		new_bullet.position = position
		new_bullet.rotation = orientation
		new_bullet.velocity = (facing + Vector2(rand_range(-0.05,0.05),rand_range(-0.05,0.05))) * 20
		get_node("../bullets").add_child( new_bullet )

func explosion():
	$explosion/AnimationPlayer.play("explode")

func _draw():
	draw_vector( Vector2( 0, 0 ), velocity * 10     , Color( 1.0, 1.0, 0.0, 0.5 ), 5 )
	draw_vector( Vector2( 0, 0 ), facing   * 60     , Color( 1.0, 1.0, 1.0, 0.5 ), 5 )

func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		vector += origin
		vector -= direction * arrow_size*2
		points.push_back( vector + direction * arrow_size*2  )
		points.push_back( vector + direction.rotated(  PI / 1.5 ) * arrow_size * 2 )
		points.push_back( vector + direction.rotated( -PI / 1.5 ) * arrow_size * 2 )
		draw_polygon( PoolVector2Array( points ), PoolColorArray( [color] ) )
		vector -= direction * arrow_size*1
		draw_line( origin, vector, color, arrow_size )