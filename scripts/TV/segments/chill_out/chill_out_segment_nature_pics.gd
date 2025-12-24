extends Node2D

@onready var pics = $pics

var active = false

var index = 0

var pic_fade_step = 0.005
var step_secs = 0.006
var timer := Timer.new()

var fading_in_sprite : Sprite2D
var fading_in_mod = 0.0
var fading_out_sprite : Sprite2D
var fading_out_mod = 0.0

var sprite_index = 0

var nature_pics : Array[Node] = []

var audio_player := AudioStreamPlayer.new()

func _ready():
	timer.one_shot = true
	add_child(timer)
	add_child(audio_player)
	audio_player.bus = "effects"
	audio_player.volume_db = -12.0

func set_active(set_active : bool):
	if(set_active == true && !active):
		active = true
		visible = true
		audio_player.stream = load("res://audio/music/chill_out_theme.wav")
		audio_player.play()
		timer.start(step_secs)
	elif(set_active == false && active):
		active = false
		visible = false
		audio_player.stop()

func update_fade_alpha():
	if(fading_in_sprite.modulate.a < 1.0):
		var new_a = fading_in_sprite.modulate + Color(0,0,0,pic_fade_step)
		fading_in_sprite.modulate = new_a
	if(fading_out_sprite.modulate.a > 0.0):
		var new_a = fading_out_sprite.modulate - Color(0,0,0,pic_fade_step)
		fading_out_sprite.modulate = new_a
	else:
		sprite_index = sprite_index + 1
		if(sprite_index == nature_pics.size()):
			sprite_index = 0
		fading_out_sprite = fading_in_sprite
		fading_in_sprite = nature_pics[sprite_index]
		var player_ref = get_tree().get_first_node_in_group("player")
		if(player_ref != null):
			player_ref.give_dash_seconds(1)

func process():
	if(active):
		if(nature_pics == []):
			nature_pics = pics.get_children()
			sprite_index = randi_range(0,nature_pics.size()-1)
			fading_in_sprite = nature_pics[sprite_index]
			var fading_out_index = sprite_index - 1
			if(fading_out_index < 0):
				fading_out_index = nature_pics.size() - 1
			fading_out_sprite = nature_pics[fading_out_index]
			fading_out_sprite.modulate = Color(1,1,1,1)
		if(timer.is_stopped()):
			update_fade_alpha()
			timer.start(step_secs)
