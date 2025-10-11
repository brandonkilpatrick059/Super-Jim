@tool
extends Node2D

@export var next_points : Array[Node] = []
@export var has_prev_point = false

var random = RandomNumberGenerator.new()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func has_next_point():
	return next_points.size() > 0

func get_next_point():
	if(has_next_point()):
		return next_points[randi_range(0, next_points.size() - 1)]

func is_occupied():
	var mobsters = get_tree().get_nodes_in_group("mobster")
	for mob in mobsters:
		if(position.distance_to(mob.position) < mob.nav_target_reached):
			return true
	return false

func _draw():
	if(Engine.is_editor_hint()):
		if(has_next_point()):
			for point in next_points:
				if(point != null):
					if(point.has_next_point()):
						if(point.next_points.find(self) >= 0):
							draw_line(Vector2(), get_transform().affine_inverse() * point.position, Color(0,1,0,1), -1)
						else:
							var other_point = get_transform().affine_inverse() * point.position
							draw_line(Vector2(), other_point, Color(1,0,0,1), -1)
							draw_line(other_point, Vector2(other_point.x+16, other_point.y+16),Color(1,0,0,1),-1)
					else:
						var other_point = get_transform().affine_inverse() * point.position
						draw_line(Vector2(), other_point, Color(1,0,0,1), -1)
						draw_line(other_point, Vector2(other_point.x+16, other_point.y+16),Color(1,0,0,1),-1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(Engine.is_editor_hint()):
		queue_redraw()
