class_name Knockedout_State
extends State

signal animate(animation : String)
signal reduce_health()
signal adjust_offset(adjustment : Vector2)
var timer := Timer.new() 
var knocked_out_time_secs = 10
var sprite_offset_amt = 16

func physics_process(_delta: float) -> void:
	if(timer.is_stopped()):
		adjust_offset.emit(Vector2(0,-sprite_offset_amt))
		ai_state_machine.transition_to(mobster_states.recovering)

func _ready():
	timer.one_shot = true
	add_child(timer)

func enter(_msg := {}) -> void:
	animate.emit(str("fallen_",ai_state_machine.perceptions.facing_dir))
	adjust_offset.emit(Vector2(0,sprite_offset_amt))
	timer.start(knocked_out_time_secs)

func exit() -> void:
	pass
