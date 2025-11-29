class_name Exclaiming_State
extends State

signal stop()
signal exclaim_bubble()
signal stand(dir :String)
signal reduce_health()
signal drop_item()
signal stop_motion()

var pause_time = 2
var timer : Timer = Timer.new()

func handle_knockout() -> bool:
	stop_motion.emit()
	#knockout when player throws object
	for node in ai_state_machine.get_perceptions().colliding_nodes:
			if(node != null &&
				!ai_state_machine.get_perceptions().invincible &&
				node.is_in_group("spark") &&
				!node.is_in_group("red") &&
				!node.is_in_group("blu")):
				ai_state_machine.transition_to(mobster_states.falling)
				return true
	return false

func physics_process(_delta: float) -> void:
	
	if(handle_knockout()):
		return
	else:
		if(timer.is_stopped()):
			ai_state_machine.transition_to(mobster_states.shooting)

func _ready():
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	timer.start(pause_time)
	stop.emit()
	stand.emit("")
	exclaim_bubble.emit()

func exit() -> void:
	pass
	
