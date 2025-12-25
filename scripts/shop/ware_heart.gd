extends Node

var sound_player : AudioStreamPlayer = AudioStreamPlayer.new()
var heart_sound = preload("res://audio/soundFX/crystal_get.wav")

func _ready() -> void:
	sound_player.bus = "Effects"
	add_child(sound_player)

func run_script():
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.increment_max_hp()
	sound_player.stream = heart_sound
	sound_player.play()
