extends Node
@export var song_deck : Array[String]
@export var skips_fade_in = true

var time_keeper = null
var main_music_player = null
var internal_clock = 0

var active = false

func get_song_deck():
	return song_deck

# Called when the node enters the scene tree for the first time.
func _ready():
	time_keeper = get_tree().get_first_node_in_group("time_keeper")
	main_music_player = get_tree().get_first_node_in_group("main_music_player")

func turn_off():
	main_music_player.change_stream("")
	active = false

func _on_body_entered(body : Node):
	if(body.is_in_group("player") && !active):
		active = true
		var new_stream
		if(song_deck.size() > 1):
			new_stream = get_song_deck()[time_keeper.clock]
		else:
			new_stream = get_song_deck()[0] 
		main_music_player.change_stream(new_stream,skips_fade_in)

func _on_body_exited(body : Node):
	if(body.is_in_group("player") && active):
		turn_off()
