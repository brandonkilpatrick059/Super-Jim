extends Node2D

var song_deck : Array[String]
var skips_fade_in : bool = false

var time_keeper = null
var main_music_player = null

var current_stream_path : String = ""

func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	main_music_player = get_tree().get_first_node_in_group("main_music_player")

func set_song_deck(new_deck : Array[String], fade_in : bool):
	song_deck = new_deck
	skips_fade_in = fade_in

func _physics_process(delta: float) -> void:
	if(!get_parent().player_is_colliding()):
		queue_free()
	var stream_pos = main_music_player.get_stream_position()
	var stream_length = main_music_player.get_stream_length()
	var new_stream = song_deck[time_keeper.clock]
	if(abs(stream_length - stream_pos) < 0.25):
		if(current_stream_path != new_stream || new_stream == ""):
			main_music_player.change_stream(new_stream,skips_fade_in)
			current_stream_path = new_stream
