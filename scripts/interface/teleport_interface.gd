extends Node2D

@onready var left_teleport_label = $left_teleport
@onready var right_teleport_label = $right_teleport

var timer := Timer.new()

var selected_label = null
var has_alien_teleport : bool = false

var check_waiting : bool = false

var audio_player := AudioStreamPlayer.new()

func close():
	queue_free()

func _ready() -> void:
	left_teleport_label.visible = false
	right_teleport_label.visible = false
	selected_label = left_teleport_label
	timer.one_shot = true
	add_child(timer)
	audio_player.bus = "Effects"
	add_child(audio_player)

func _physics_process(delta: float) -> void:
	left_teleport_label.visible = false
	right_teleport_label.visible = false
	selected_label.visible = true
	selected_label.get_child(0).get_glyph()
	if(timer.is_stopped() && check_waiting):
		selected_label.text = "TELEPORT"
		check_waiting = false
	if(Input.is_action_just_pressed("menu_select")):
		if(!check_waiting):
			check_waiting = true
			selected_label.text = "Are you sure?"
			audio_player.stream = load("res://audio/soundFX/maracca.ogg")
			audio_player.play()
			timer.start(3.0)
		elif(check_waiting):
			if(selected_label == left_teleport_label):
				var player = get_tree().get_first_node_in_group("player")
				player.teleport("JEFF")
				audio_player.stream = load("res://audio/soundFX/shaker.ogg")
				audio_player.play()
				get_parent().close()
