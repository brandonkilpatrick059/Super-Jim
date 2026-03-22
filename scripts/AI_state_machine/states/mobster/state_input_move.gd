class_name Input_Move
extends State

signal input_move()

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	input_move.emit()
	if(Input.is_action_just_pressed("interact")):
		ai_state_machine.transition_to(mobster_states.input_shooting)

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass
