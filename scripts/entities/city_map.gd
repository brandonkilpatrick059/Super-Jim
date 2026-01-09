extends Node2D

var ui = preload("res://interface/city_map.tscn")

var ui_ref = null

var ui_active = false

var player_ref = null

var interact_timer : Timer = Timer.new()

func _ready() -> void:
	interact_timer.one_shot = true
	add_child(interact_timer)

func interact():
	if(interact_timer.is_stopped()):
		var fx_player = get_tree().get_first_node_in_group("main_fx_player")
		fx_player.stream = load("res://audio/soundFX/maracca.ogg")
		fx_player.play()
		player_ref = get_tree().get_first_node_in_group("player")
		ui_ref = ui.instantiate()
		player_ref.set_control_frozen(true)
		player_ref.add_scene_to_ui_tree(ui_ref)
		ui_active = true

func exit_ui():
	ui_active = false
	ui_ref.queue_free()
	player_ref.set_control_frozen(false)
	var fx_player = get_tree().get_first_node_in_group("main_fx_player")
	fx_player.stream = load("res://audio/soundFX/maracca.ogg")
	fx_player.play()

func _physics_process(delta: float) -> void:
	if(ui_active):
		if Input.is_action_just_pressed("interact"):
			exit_ui()
			interact_timer.start(1)
