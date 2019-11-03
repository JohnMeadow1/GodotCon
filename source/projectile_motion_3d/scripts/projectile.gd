extends Spatial

var velocity:Vector3 = Vector3.ZERO
var time:float     = 0.0

var gravity:float = 0.0

var origin_translation:Vector3 = Vector3()
onready var target = $"../../target"

func _ready():
	origin_translation = translation

func _physics_process(delta):
	time += delta
	translation = origin_translation + velocity * time
	translation.y -= ((gravity * time * time )/ 2)
	
	if (target.transform.origin-transform.origin).length() < 0.1:
		queue_free()

	if translation.y < 0:
		queue_free()
