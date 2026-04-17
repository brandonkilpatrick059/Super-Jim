extends Sprite2D

@export var action : String = ""
@export var blinking : bool = false
@export var blink_interval_secs : float = 0.0

var timer := Timer.new()

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)

func get_glyph():
	var input_map_manager = get_tree().get_first_node_in_group("input_map_manager")
	var path = input_map_manager.get_glyph_path_for_action(action)
	texture = load(path)

func _physics_process(delta: float) -> void:
	if(blinking && timer.is_stopped()):
		visible = !visible
		timer.start(blink_interval_secs)
