extends Node2D

@onready var _animated_sprite = $AnimatedSprite2D

var speech_bubble = preload("res://dialog/speech_bubble.tscn")
var mystery_song = preload("res://audio/music/mystery_motif.wav")

var main_music_player : AudioStreamPlayer 

var prophesizing = false
var proclaiming = false

var prophecy_timer : Timer = Timer.new()

var cost = 1
var prophecy_time_secs = 3.0

var speech_instance = null

var random : RandomNumberGenerator = RandomNumberGenerator.new()
var temp_stream : AudioStream

var phrases : Array[String] = [
"IT IS CERTAIN", 
"MAYBE SOMEDAY", 
"ASK AGAIN LATER",
"ANOTHER DOLLAR MAY HELP",
"IT IS DECIDEDLY SO",
"OUTLOOK NOT SO GOOD",
"I WOULD NOT COUNT ON IT",
"CONCENTRATE AND ASK AGAIN",
"ASK ME ABOUT LOOM"]

func _ready():
	prophecy_timer.one_shot = true
	add_child(prophecy_timer)

func interact():
	var player = get_tree().get_first_node_in_group("player")
	if(player.get_money() > 0):
		if(!prophesizing):
			var camera = get_tree().get_first_node_in_group("camera")
			camera.zoom_to(1.5)
			camera
			player._on_add_money(-1)
			player.set_control_frozen(true)
			main_music_player = get_tree().get_first_node_in_group("main_music_player")
			temp_stream = main_music_player.stream
			main_music_player.stop()
			main_music_player.stream = mystery_song
			main_music_player.play()
			_animated_sprite.play("active")
			prophecy_timer.start(3.0)
			prophesizing = true

func _physics_process(delta: float) -> void:
	if(prophecy_timer.is_stopped() && prophesizing && !proclaiming):
		prophesizing = false
		proclaiming = true
		speech_instance = speech_bubble.instantiate()
		add_child(speech_instance)
		var text = phrases[random.randi_range(0, phrases.size()-1)]
		speech_instance.play_passive_text(text, "alien_voice")
	if(proclaiming && speech_instance.ready_to_disappear):
		var player = get_tree().get_first_node_in_group("player")
		_animated_sprite.play("inactive")
		main_music_player.stream = temp_stream
		main_music_player.play()
		player.set_control_frozen(false)
		proclaiming = false
		speech_instance.queue_free()
		var camera = get_tree().get_first_node_in_group("camera")
		camera.zoom_to(1.0)
