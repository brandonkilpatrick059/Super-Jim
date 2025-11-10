class_name Exclaiming_State
extends State

signal stop()
signal exclaim_bubble()
signal stand(dir :String)
signal reduce_health()
signal drop_item()

var pause_time = 2
var timer : Timer = Timer.new()

func physics_process(_delta: float) -> void:
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
	
