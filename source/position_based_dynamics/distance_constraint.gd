tool
extends Node2D
class_name LinkNode

export(NodePath) var node_path_1:NodePath setget set_node_1
export(NodePath) var node_path_2:NodePath setget set_node_2

var point_1:PointMass
var point_2:PointMass

var mass_ratio_1 :float = 0
var mass_ratio_2 :float = 0

var constrain_vector  := Vector2( 0.0, 0.0 )
var rest_length       := 0.0
var compress_stiffness:= 0.1
var stretch_stiffness := 0.1

func set_node_1(value:NodePath):
	node_path_1 = value
	if Engine.is_editor_hint() and has_node(value):
		point_1 = get_node(value) as PointMass
	
func set_node_2(value:NodePath):
	node_path_2 = value
	if Engine.is_editor_hint() and has_node(value):
		point_2 = get_node(value) as PointMass
	
func initialize( node_1:PointMass, node_2:PointMass ):
	point_1 = node_1
	point_2 = node_2
	constrain_vector = point_2.position - point_1.position #- d
	rest_length = constrain_vector.length()
	
func _ready():
#	if !Engine.is_editor_hint():
	if !point_1:
		point_1 = get_node(node_path_1) as PointMass
	if !point_2:
		point_2 = get_node(node_path_2) as PointMass
	point_1.add_neighbor(point_2)
	point_2.add_neighbor(point_1)
	mass_ratio_1 = point_1.mass / (point_1.mass + point_2.mass)
	mass_ratio_2 = point_2.mass / (point_1.mass + point_2.mass)


func _physics_process(_delta):
	if point_1 and point_2 :
		position            = 0.5 * ( point_1.position + point_2.position )
		
		var relation_vector := point_1.position - point_2.position
		rotation            = atan2( relation_vector.x, -relation_vector.y )
		scale.y             = max(10, relation_vector.length()) / 128.0
		scale.x             = 32.0 / clamp( relation_vector.length(), 32.0, 128.0 )

