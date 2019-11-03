extends Node2D

var velocity             = Vector2( 10.0, 0.0 )
var thrust               = 0.0
var ACCELERATION         = 0.35

var angular_velocity     = 0.0
var angular_acceleration = 0.005
var orientation          = 0.0
var facing               = Vector2 ( 0.0, 0.0 )

var projection           = Vector2 ( 0.0, 0.0 )

var bullet               = preload("res://scenes/bullet.tscn")
var fire_timer           = 0.0
var hp                   = 100

var draw_motion_vectors  = false

func _ready():
	pass

func _physics_process( delta ):
	process_input( delta )
#	check_payer_destroyed()

	angular_velocity = angular_velocity * 0.91
	orientation      = orientation + angular_velocity
	facing           = Vector2 ( cos( orientation ), sin( orientation ) )

	velocity      *= 0.94

	velocity      += facing * thrust
	self.position += velocity

	$Sprite_ship.rotation = orientation
	
	if draw_motion_vectors:
		update()

func process_input( delta ):

	thrust = 0
	if  Input.is_action_pressed("ui_up"):
		thrust =  ACCELERATION
		$Sprite_ship/AnimationPlayer.seek(0)
		$Sprite_ship/AnimationPlayer.play("fire")
	if Input.is_action_pressed("ui_down"):
		thrust = -ACCELERATION
		$Sprite_ship/AnimationPlayer.seek(0)
		$Sprite_ship/AnimationPlayer.play("fire")

	if Input.is_action_pressed("ui_left"):
		angular_velocity -= angular_acceleration
	if Input.is_action_pressed("ui_right"):
		angular_velocity += angular_acceleration

	if Input.is_action_pressed("ui_accept"):
		fire_timer += delta
		if fire_timer > 0.2:
			fire_timer = 0
			create_bullet()

	elif fire_timer < 0.2:
		fire_timer += delta
	
func create_bullet():
	for i in range(2):
		var new_bullet = bullet.instance()
		new_bullet.position = self.position
		new_bullet.rotation = orientation 
		new_bullet.velocity = (facing + Vector2(rand_range(-0.05,0.05),rand_range(-0.05,0.05))) * 20
		$"../bullets".add_child( new_bullet )
		
func check_payer_destroyed():
	if hp < 100:
		hp += 0.1
		$Health_bar.value   = hp
		$Health_bar.visible = true
	else:
		$Health_bar.visible = false
	if hp <= 0:
		get_tree().quit()

func explosion():
	$"Explosion/AnimationPlayer".play("boom")

func _draw():
	if draw_motion_vectors:
		draw_vector( Vector2( 0, 0 ), velocity * 10     , Color( 1.0, 1.0, 0.0, 0.5 ), 5 )
		draw_vector( Vector2( 0, 0 ), facing   * 60     , Color( 1.0, 1.0, 1.0, 0.5 ), 5 )
		draw_vector( Vector2( 0, 0 ), projection        , Color( 0.0, 1.0, 0.0, 0.5 ), 3 )

func draw_vector( origin, vector, color, arrow_size ):
	if vector.length_squared() > 1:
		var points    = []
		var direction = vector.normalized()
		points.push_back( vector + direction * arrow_size * 2 )
		points.push_back( vector + direction.rotated(  PI / 2 ) * arrow_size )
		points.push_back( vector + direction.rotated( -PI / 2 ) * arrow_size )
		draw_polygon( PoolVector2Array( points ), PoolColorArray( [color] ) )
		draw_line( origin, vector, color, arrow_size )
