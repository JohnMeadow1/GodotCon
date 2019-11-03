extends Spatial
var loop:float = 0.0
var direction = 1
func _ready():
	pass
func _process(delta):
	loop += direction * delta
	if abs(loop) >=1:
		loop -=direction * delta
		direction *= -1
#	translation.z += loop *0.1
	if Input.is_action_pressed("ui_down"):
		translation.z -= 0.1
	if Input.is_action_pressed("ui_up"):
		translation.z += 0.1
	if Input.is_action_pressed("ui_right"):
		translation.x -= 0.1
	if Input.is_action_pressed("ui_left"):
		translation.x += 0.1
	if Input.is_action_pressed("ui_page_up"):
		translation.y -= 0.1
	if Input.is_action_pressed("ui_page_down"):
		translation.y += 0.1
