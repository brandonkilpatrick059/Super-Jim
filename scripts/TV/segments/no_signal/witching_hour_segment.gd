extends Node2D

@onready var noise = $noise
@onready var alien_eye = $alien_eye

var active = false

var noise_player := AudioStreamPlayer.new()
var music_player := AudioStreamPlayer.new()

var noise_max_vol : float = -24.0
var zero_volume : float = -60.0

var noise_strength = 1.0
var noise_set_point = 0.0
var noise_var_point
var noise_variance = 0.0
var noise_step = 0.01

var camera_ref : Node2D

var timer := Timer.new()
var timer_step : float = 0.006

var switch_timer := Timer.new()

const green_glow : String = "green_glow"
const all_noise : String = "all_noise"
const eye_open : String = "eye_open"
const space_ship : String = "space_ship"
const end_door : String = "end_door"
const dream_door : String = "dream_door" 

var exiting : bool = false
var entering : bool = true

#var sequence : Array[String] = [
	#all_noise,
	#green_glow,
	#all_noise,
	#space_ship,
	#all_noise,
	#end_door,
	#all_noise,
	#dream_door,
	#all_noise,
	#eye_open,
	#all_noise]

var sequence : Array[String] = [
	all_noise,
	green_glow,
	all_noise,
	space_ship,
	all_noise,
	eye_open,
	all_noise]

var sequence_index = 0

func reset_camera():
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.show_back_ground(true)
	tv_machine.start_reset_camera()

func _ready():
	add_child(noise_player)
	add_child(music_player)
	music_player.volume_db = zero_volume
	music_player.bus = "diagetic_music"
	noise_player.bus = "effects"
	noise_player.volume_db = -24.0
	camera_ref = get_tree().get_first_node_in_group("camera")
	timer.one_shot = true
	switch_timer.one_shot = true
	add_child(timer)
	add_child(switch_timer)

func set_noise_point(str : float, variance : float):
	noise_set_point = str
	noise_variance = variance
	noise_var_point = get_noise_variance_point()

func get_noise_variance_point() -> float:
	return noise_set_point + randf_range(-noise_variance,noise_variance)

#where str is a float 0.0 -> 1.0
func set_noise_strength(str : float):
	var vol_diff = abs(zero_volume ) - abs(noise_max_vol)
	var music_vol_ratio = str * vol_diff
	var noise_vol_ratio = (1.0 - str) * vol_diff
	noise_player.volume_db = noise_max_vol - noise_vol_ratio
	music_player.volume_db = -music_vol_ratio
	noise.modulate = Color(1.0,1.0,1.0, str)
	noise_strength = str

func camera_to_spaceship():
	var daylight_layer = get_tree().get_first_node_in_group("daylight_layer")
	daylight_layer.visible = true
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.reparent(daylight_layer)
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	dark_layer.visible = false
	var spaceship_anchor = get_tree().get_first_node_in_group("alien_spaceship_anchor")
	var add_skybox = get_tree().get_first_node_in_group("lonesome_mountain_skybox_add")
	add_skybox.run_script()
	camera_ref.connect_anchor(spaceship_anchor)
	tv_machine.show_back_ground(false)
	tv_machine.global_position = camera_ref.get_screen_center_position()

func clean_up_spaceship_skybox():
	var remove_skybox = get_tree().get_first_node_in_group("lonesome_mountain_skybox_remove")
	remove_skybox.run_script()
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.show_back_ground(true)

func camera_to_end_door():
	var flat_light_layer = get_tree().get_first_node_in_group("flat_light_layer")
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.reparent(flat_light_layer)
	var dark_layer = get_tree().get_first_node_in_group("dark_layer")
	dark_layer.visible = false
	var end_door_anchor = get_tree().get_first_node_in_group("end_door_anchor")
	var add_skybox = get_tree().get_first_node_in_group("add_end_skybox")
	add_skybox.run_script()
	camera_ref.connect_anchor(end_door_anchor)
	tv_machine.show_back_ground(false)
	tv_machine.global_position = camera_ref.get_screen_center_position()

func clean_up_end_door_skybox():
	var remove_skybox = get_tree().get_first_node_in_group("lonesome_mountain_skybox_remove")
	remove_skybox.run_script()
	var tv_machine = get_tree().get_first_node_in_group("tv_machine")
	tv_machine.show_back_ground(false)

func clean_up_all_skyboxes():
	clean_up_spaceship_skybox()
	clean_up_end_door_skybox()

func disable():
	active = false
	visible = false
	noise_player.stop()
	music_player.stop()
	reset_camera()

func handle_noise_strength():
	if(noise_strength - noise_step > noise_var_point &&
	noise_strength + noise_step < noise_var_point):
		get_noise_variance_point()
	elif(noise_strength < noise_var_point):
		set_noise_strength(noise_strength + noise_step)
	elif(noise_strength > noise_var_point):
		set_noise_strength(noise_strength - noise_step)

func set_active(set_active : bool):
	if(set_active == true && !active):
		sequence_index = 0
		active = true
		visible = true
		noise_player.volume_db = -24.0
		noise_player.stream = load("res://audio/soundFX/pink_noise.wav")
		noise_player.play()
		music_player.stream = load("res://audio/music/vocal_drone.wav")
		music_player.play()
	elif(set_active == false && active):
		disable()
		clean_up_all_skyboxes()

func all_noise_process():
	if(entering):
		entering = false
		set_noise_point(1.0,0.0)
		switch_timer.start(2.0)
	if(exiting):
		enter_next_sequence()

func green_glow_process():
	if(entering):
		entering = false
		set_noise_point(0.1,0.05)
		switch_timer.start(4.0)
		alien_eye.visible = true
		alien_eye.play("default")
	if(exiting):
		enter_next_sequence()

func eye_open_process():
	if(entering):
		entering = false
		set_noise_point(0.1,0.0)
		switch_timer.start(4.0)
		alien_eye.visible = true
		alien_eye.play("open")
	if(exiting):
		enter_next_sequence()
	if(alien_eye.animation == "open" &&
	alien_eye.frame == alien_eye.sprite_frames.get_frame_count("open") - 1):
		alien_eye.play("opened")

func space_ship_process():
	if(entering):
		entering = false
		alien_eye.visible = false
		set_noise_point(0.1,0.05)
		switch_timer.start(5.0)
		camera_to_spaceship()
	if(exiting):
		clean_up_spaceship_skybox()
		enter_next_sequence()

func enter_next_sequence():
	if(exiting && sequence_index + 1 < sequence.size()):
		exiting = false
		entering = true
		sequence_index = sequence_index + 1

func process():
	if(active):
		if(timer.is_stopped()):
			var current_sequence = sequence[sequence_index]
			match current_sequence:
				all_noise:
					all_noise_process()
				green_glow:
					green_glow_process()
				space_ship:
					space_ship_process()
				eye_open:
					eye_open_process()
			handle_noise_strength()
			timer.start(timer_step)
		if(!entering && !exiting && switch_timer.is_stopped()):
			exiting = true
