extends Node2D

var active = false

var timer := Timer.new()

var audio_player := AudioStreamPlayer.new()

var camera_ref = null
var bandit_ref = null

func disable():
	active = false
	visible = false
	audio_player.stop()
	reset_camera()

func _ready():
	timer.one_shot = true
	add_child(timer)
	add_child(audio_player)
	audio_player.bus = "effects"
	audio_player.volume_db = -12.0

func reset_camera():
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.show_back_ground(true)
	tv_machine.start_reset_camera()

func find_bandit():
	var bandits = get_tree().get_nodes_in_group("bandit")
	if(bandit_ref != null):
		#do not want to include the current bandit in list for finding a new bandit
		bandits.erase(bandit_ref) 
	if(bandits.size() > 0):
		bandit_ref = bandits[randi_range(0,bandits.size() - 1)]
	else:
		var mobs = get_tree().get_nodes_in_group("mobster")
		bandit_ref = mobs[randi_range(0,mobs.size() - 1)]
	if(camera_ref == null):
		camera_ref = get_tree().get_first_node_in_group("camera")
	camera_ref.connect_anchor(bandit_ref)
	var tree_prune_manager = get_tree().get_first_node_in_group("tree_prune_manager")
	tree_prune_manager.full_pass()
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.show_back_ground(false)
	tv_machine.global_position = camera_ref.get_screen_center_position()

func set_active(set_active : bool):
	if(set_active == true && !active):
		var daylight_layer = get_tree().get_first_node_in_group("daylight_layer")
		daylight_layer.visible = true
		var tv_machine = get_tree().get_first_node_in_group("tv_machine")
		tv_machine.reparent(daylight_layer)
		var dark_layer = get_tree().get_first_node_in_group("dark_layer")
		dark_layer.visible = false
		find_bandit()
		active = true
	elif(set_active == false && active):
		disable()

func process():
	if(active):
		if(bandit_ref.get_state_name() == mobster_states.dead):
			find_bandit()
