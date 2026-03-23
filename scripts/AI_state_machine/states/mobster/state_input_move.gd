class_name Input_Move
extends State

signal input_move()

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func process(_delta: float) -> void:
	pass

func physics_process(_delta: float) -> void:
	input_move.emit()
	if(timer.is_stopped() && Input.is_action_just_pressed("interact")):
		ai_state_machine.transition_to(mobster_states.input_shooting)

func enter(_msg := {}) -> void:
	timer.start(1)

func exit() -> void:
	pass
