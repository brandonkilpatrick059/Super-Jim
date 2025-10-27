extends Node

var sound_player : AudioStreamPlayer = AudioStreamPlayer.new()
var regen_sound = preload("res://audio/soundFX/dash_regen.wav")

func _ready() -> void:
	sound_player.bus = "Effects"
	add_child(sound_player)

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.regen_dash_secs(10)
	sound_player.stream = regen_sound
	sound_player.play()
