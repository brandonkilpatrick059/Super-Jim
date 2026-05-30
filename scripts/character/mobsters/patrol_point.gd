@tool
extends Node2D

@export var next_points : Array[Node] = []
@export var has_prev_point = false

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	if(Engine.is_editor_hint()):
		queue_redraw()

func has_next_point():
	return next_points.size() > 0

#gets next point, weighted in favor
#of points with fewer nearby mobs
func get_next_point():
	if(has_next_point()):
		if(next_points.size() == 1):
			return next_points[0]
		else:
			var mob_weights : Array[point_weight]
			for point in next_points:
				if(point != null):
					var weight : point_weight =  point_weight.new()
					weight.weight = point.get_num_nearby_mobs()
					weight.point = next_points.find(point)
					mob_weights.append(weight)
			mob_weights.sort_custom(ascending_weight_sorter)
			var index = 0
			while(index < mob_weights.size()):
				var node = next_points[mob_weights[index].point]
				if(randf_range(0.0,1.0) > 0.50):
					return node
				index = index + 1
			return next_points[mob_weights[0].point]

#old code for get_next_point()
#func get_next_point():
	#if(has_next_point()):
		#return next_points[randi_range(0, next_points.size() - 1)]

func ascending_weight_sorter(a : point_weight,b : point_weight):
	var ret_val = false
	if (a.weight < b.weight):
		ret_val = true
	return ret_val

class point_weight:
	var point : int = 0
	var weight : int = 0

func is_occupied():
	var mobsters = get_tree().get_nodes_in_group("mobster")
	for mob in mobsters:
		if(position.distance_to(mob.position) < mob.nav_target_reached):
			return true
	return false

func get_num_nearby_mobs() -> int:
	var mobsters = get_tree().get_nodes_in_group("mobster")
	var distance = 500
	var count : int = 0
	for mob in mobsters:
		if(global_position.distance_to(mob.global_position) < distance):
			count = count + 1
	return count

#func _draw():
	#if(Engine.is_editor_hint()):
		#if(has_next_point()):
			#for point in next_points:
				#if(point != null):
					#if(point.has_next_point()):
						#if(point.next_points.find(self) >= 0):
							#draw_line(Vector2(), get_transform().affine_inverse() * point.position, Color(0,1,0,1), -1)
						#else:
							#var other_point = get_transform().affine_inverse() * point.position
							#draw_line(Vector2(), other_point, Color(1,0,0,1), -1)
							#draw_line(other_point, Vector2(other_point.x+16, other_point.y+16),Color(1,0,0,1),-1)
					#else:
						#var other_point = get_transform().affine_inverse() * point.position
						#draw_line(Vector2(), other_point, Color(1,0,0,1), -1)
						#draw_line(other_point, Vector2(other_point.x+16, other_point.y+16),Color(1,0,0,1),-1)
	
