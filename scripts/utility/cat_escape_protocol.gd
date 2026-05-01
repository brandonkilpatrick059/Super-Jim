extends Node

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(randf_range(5.0,15.0))

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		var player_ref = get_tree().get_first_node_in_group("player")
		if(!player_ref.control_is_frozen()):
			player_ref.put_down()
			player_ref._on_make_comment("The cat escaped!")
