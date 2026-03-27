extends State

class_name NPC_Troll_State

var path_1 : stage_mark
var path_2 : stage_mark
var path_3 : stage_mark
var path_4 : stage_mark
var path_5 : stage_mark
var path_point_index = 0
var path_points : Array[stage_mark]

signal set_nav_target(pos : Vector2)
signal advance_navigation(speed : int)
signal interact(bypass : bool)
signal stop()

var nav_target_reached = false
var host_position
var current_stage_mark : Node = null

var timer : Timer
var grace_period_secs = 120

var stuck_timer := Timer.new()
var check_pos : Vector2 
var stuck : bool = false

const distance_to_break_current_point = 128


func _ready() -> void:
	stuck_timer.one_shot = true
	add_child(stuck_timer)
	
func get_host_position():
	return ai_state_machine.get_perceptions().position

func get_host_nav_target_reached():
	return ai_state_machine.get_perceptions().nav_target_reached

func process(_delta: float) -> void:
	pass

#func get_stage_mark():
	#current_stage_mark = ai_state_machine.get_perceptions().current_stage_mark
	#if(current_stage_mark != null):
		#set_nav_target.emit(current_stage_mark.position)

func physics_process(_delta: float) -> void:
	#reset the troll if he guts stuck for some reason
	if(stuck_timer.is_stopped()):
		if(check_pos.distance_to(ai_state_machine.get_perceptions().global_position) <= 4):
			stuck = true
		check_pos = ai_state_machine.get_perceptions().global_position
		stuck_timer.start(2)
	if(current_stage_mark != null):
		nav_target_reached = get_host_nav_target_reached()
		var player_ref = get_tree().get_first_node_in_group("player")
		var player_pos : Vector2 = player_ref.global_position
		var troll_pos : Vector2 = ai_state_machine.get_perceptions().global_position
		if(!ai_state_machine.get_perceptions().in_dialog):
			if(player_pos.distance_to(troll_pos) < 64 &&
			timer.is_stopped()):
				var point_light = get_tree().get_first_node_in_group("troll").get_child(0)
				point_light.enabled = true
				interact.emit(true)
				stop.emit()
				timer.start(grace_period_secs)
			else:
				var point_light = get_tree().get_first_node_in_group("troll").get_child(0)
				point_light.enabled = false
				if(!stuck && !ai_state_machine.get_perceptions().nav_target_reached):
					advance_navigation.emit(250000)
				else:
					stuck = false
					if(randf_range(0.0,1.0) > 0.50):
						path_point_index = path_point_index + 1
						if(path_point_index >= path_points.size()):
							path_point_index = 0
					else:
						path_point_index = path_point_index - 1
						if(path_point_index < 0):
							path_point_index = path_points.size() - 1
					current_stage_mark = path_points[path_point_index]
					set_nav_target.emit(current_stage_mark.global_position)

func enter(_msg := {}) -> void:
	timer = Timer.new()
	timer.one_shot = true
	add_child(timer)
	path_1 = get_tree().get_first_node_in_group("troll_path_1")
	path_2 = get_tree().get_first_node_in_group("troll_path_2")
	path_3 = get_tree().get_first_node_in_group("troll_path_3")
	path_4 = get_tree().get_first_node_in_group("troll_path_4")
	path_5 = get_tree().get_first_node_in_group("troll_path_5")
	path_points = [path_1,path_2,path_3,path_4,path_5]
	current_stage_mark = path_points[0]
	if(current_stage_mark != null):
		set_nav_target.emit(current_stage_mark.global_position)

func exit() -> void:
	timer.queue_free()
	
