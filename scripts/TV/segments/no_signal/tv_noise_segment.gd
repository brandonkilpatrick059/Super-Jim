extends Node2D

@onready var noise = $noise

var active = false

var audio_player := AudioStreamPlayer.new()

func _ready():
	add_child(audio_player)
	audio_player.bus = "effects"
	audio_player.volume_db = -24.0

func disable():
	active = false
	visible = false
	audio_player.stop()

func set_active(set_active : bool):
	if(set_active == true && !active):
		active = true
		visible = true
		audio_player.stream = load("res://audio/soundFX/pink_noise.wav")
		audio_player.play()
	elif(set_active == false && active):
		disable()

func process():
	pass
