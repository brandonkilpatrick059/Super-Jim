extends Node2D

@export var sound_path : String = ""

var sound_player := AudioStreamPlayer2D.new()

var sound_played = false

func _ready() -> void:
	sound_player.max_distance = 500
	sound_player.attenuation = 2
	sound_player.bus = "Effects"
	add_child(sound_player)

func _physics_process(delta: float) -> void:
	if(!sound_played):
		sound_player.stream = load(sound_path)
		sound_player.play()
		sound_played = true
