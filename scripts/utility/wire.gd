#@tool
extends Node2D

@export var point_a : Node2D
@export var point_b : Node2D
@export var sample_count : int = 1
@export var droop : float = 0
@export var droop_center : float = 0.5
@export var thickness : float = 1.0
@export var color : Color = Color.BLACK
@export var precision : int = 8
@export var width : float = 1.0

var line : Line2D

func _ready():
	var a_pos = point_a.position
	var b_pos = point_b.position
	line = Line2D.new()
	line.add_point(a_pos)
	var mid_pos = Vector2((a_pos.x + b_pos.x)/2,(a_pos.y + b_pos.y)/2)
	mid_pos.y = mid_pos.y - droop
	line.add_point(mid_pos)
	line.add_point(b_pos)
	line.set_joint_mode(Line2D.LINE_JOINT_ROUND)
	

func _draw() -> void:
	draw_polyline(line.points,color,width)
	#var index = 0
	#while(index < line.points.count()):
		#if(index + 1 < line.points.count())
			#draw_line(line.points.)
		

func _process(delta: float) -> void:

	if(Engine.is_editor_hint()):
		queue_redraw()
