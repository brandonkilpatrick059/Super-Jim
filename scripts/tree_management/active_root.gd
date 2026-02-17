extends Node

var root_manager
var main_camera

var transition_done = false

@export var main_scene = false
@export var start_scene = false

@onready var version_label = $version_label

# Called when the node enters the scene tree for the first time.
func _ready():
	root_manager = get_tree().get_first_node_in_group("root_manager")
	main_camera = get_tree().get_first_node_in_group("camera")
	if(version_label != null):
		version_label.text = ProjectSettings.get_setting("application/config/version")

func _process(_delta):
	if(main_camera.is_faded_out() && !transition_done):
		transition_done = true
		if(main_scene && root_manager.is_to_main_scene()):
			#if everything is ready and the scene is running, complete transition on the manager end
			root_manager._on_transition_to_main_scene_finished()
		#if(start_scene && root_manager.is_to_start_scene()):
			#root_manager._on_transition_to_start_scene_finished()
