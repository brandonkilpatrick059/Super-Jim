extends Node2D

var main_scene = preload("res://scenes/alpha_game_world.tscn")
var camera_ref : Node
var player_ref

var transition_timer = Timer.new()
var transitioning = false
var prev_scene_freed = false

@export var skip_intro = false

var sound_player : AudioStreamPlayer = AudioStreamPlayer.new()

func _ready():
	camera_ref = get_tree().get_first_node_in_group("camera")
	transition_timer.one_shot = true
	self.add_child(transition_timer)
	add_child(sound_player)

#root manager transitions from current scene (presumably start) to main scene
func _on_transition_to_main_scene_init():
	camera_ref.fade_out()
	transitioning = true
	transition_timer.start(3)
	prev_scene_freed = false

#callback from active_root when the scene is ready
func _on_transition_to_main_Scene_finished():
	player_ref = get_tree().get_first_node_in_group("player")
	if(skip_intro):
		player_ref.set_control_frozen(true)
		camera_ref.reparent(player_ref)
		player_ref.connect_camera()
		player_ref.load_in()
		var team_manager = get_tree().get_first_node_in_group("team_manager")
		team_manager.get_and_unlock_spawns()
	else:
		var anchor_ref = get_tree().get_first_node_in_group("start_camera_anchor")
		player_ref.set_control_frozen(true)
		var player_spawn = get_tree().get_first_node_in_group("player_spawn_start")
		player_ref.global_position = player_spawn.global_position
		camera_ref.connect_anchor(anchor_ref)
		camera_ref.fade_in()
	transitioning = false
	
func _physics_process(delta):
	if(transition_timer.is_stopped() && transitioning && !prev_scene_freed):
		var active_root = get_tree().get_first_node_in_group("active_root")
		active_root.queue_free()
		prev_scene_freed = true
		var main_scene = main_scene.instantiate()
		add_child(main_scene)
		var game_save_manager = get_tree().get_first_node_in_group("game_save_manager")
		if(game_save_manager.save_file_exists()):
			game_save_manager.load_game()
			skip_intro = true
