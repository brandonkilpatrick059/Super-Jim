extends Node2D

var sound_player := AudioStreamPlayer.new()

@onready var label : Label = $Label
@onready var covers = $covers

var timer := Timer.new()

var done = false
var settling = false

var y_max : float = -92.0
var y_settle : float = -82.0

func _ready() -> void:
	sound_player.bus = "Effects"
	timer.one_shot = true
	add_child(sound_player)

func close():
	queue_free()

func play(key : String):
	var player_ref = get_tree().get_first_node_in_group("player")
	player_ref.set_control_frozen(true)
	sound_player.stream = load("res://audio/soundFX/crystal_get.wav")
	sound_player.play()
	covers.set_cover(key)

func _physics_process(delta: float) -> void:
	if(!done && timer.is_stopped()):
		if(!settling):
			if(label.position.y > y_max):
				label.position = label.position - Vector2(0,2)
			else:
				settling = true
		else:
			if(label.position.y < y_settle):
				label.position = label.position + Vector2(0,1)
			else:
				done = true
		timer.start(0.006)
	elif(done && Input.is_action_just_pressed("interact")):
		var player_ref = get_tree().get_first_node_in_group("player")
		player_ref.set_control_frozen(false)
		close()
