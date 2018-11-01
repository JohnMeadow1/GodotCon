extends Node2D

const TRACK_LENGTH = 300
var track_front  = PoolIntArray()
var track_back   = PoolIntArray()
var track1 = PoolVector2Array()
var track2 = PoolVector2Array()
var track3 = PoolVector2Array()
var track4 = PoolVector2Array()

func _process(delta):
	if( track_front.size() >= TRACK_LENGTH ):
		track_back.remove(0)
		track_front.remove(0)
		track1.remove(0)
		track2.remove(0)
		track3.remove(0)
		track4.remove(0)
	track1.append($car/turning_pivot/body/rubber_right.global_position)
	track2.append($car/turning_pivot/body/rubber_left.global_position)
	track3.append($car/turning_pivot/body/pivot_right/rubber.global_position)
	track4.append($car/turning_pivot/body/pivot_left/rubber.global_position)
	track_back.append($car.skid_size_back)
	track_front.append($car.skid_size_front)
	update()

func _draw():
	for i in range(track_front.size() -1 ):
		if track_front[i] > 0:
			draw_line(track3[i], track3[i+1], Color(0, 0, 0, 0.5), track_front[i])
			draw_line(track4[i], track4[i+1], Color(0, 0, 0, 0.5), track_front[i])
		if track_back[i] > 0:
			draw_line(track1[i], track1[i+1], Color(0, 0, 0, 0.5), track_back[i])
			draw_line(track2[i], track2[i+1], Color(0, 0, 0, 0.5), track_back[i])
