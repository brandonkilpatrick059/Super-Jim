extends RigidBody2D

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(5.0)

func _on_body_entered(body: Node) -> void:
	if(body.is_in_group("mobster")):
		if(body != null && 
		body.is_not_dead() &&
		 body.get_state_name() != "investigate"):
			body.transition_ai_state_machine("investigate")

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		queue_free()
