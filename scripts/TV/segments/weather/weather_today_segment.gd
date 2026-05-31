extends Node2D

@onready var day_1_sym : AnimatedSprite2D = $day_1
@onready var day_2_sym : AnimatedSprite2D = $day_2
@onready var day_3_sym : AnimatedSprite2D = $day_3
@onready var night_1_sym : AnimatedSprite2D = $night_1
@onready var night_2_sym : AnimatedSprite2D = $night_2
@onready var night_3_sym : AnimatedSprite2D = $night_3
@onready var temp_day_1 : Label = $temp_day_1
@onready var temp_day_2 : Label = $temp_day_2
@onready var temp_day_3 : Label = $temp_day_3
@onready var temp_night_1 : Label = $temp_night_1
@onready var temp_night_2 : Label = $temp_night_2
@onready var temp_night_3 : Label = $temp_night_3

var active = false


var step_secs = 0.006
var timer := Timer.new()

var sprite_index = 0

var nature_pics : Array[Node] = []

var audio_player := AudioStreamPlayer.new()

func _ready():
	timer.one_shot = true
	add_child(timer)
	add_child(audio_player)
	audio_player.bus = "effects"
	audio_player.volume_db = -12.0
	init_weather()

func init_weather():
	#TODO: hook this up to weather manager
	temp_day_1.text = str(randi_range(68,80))
	temp_day_2.text = str(randi_range(68,80))
	temp_day_3.text = str(randi_range(68,80))
	temp_night_1.text = str(randi_range(58,80))
	temp_night_2.text = str(randi_range(58,68))
	temp_night_3.text = str(randi_range(58,68))

func disable():
	active = false
	visible = false
	audio_player.stop()

func set_active(set_active : bool):
	if(set_active == true && !active):
		active = true
		visible = true
		audio_player.stream = load("res://audio/music/visitor_center.wav")
		audio_player.play()
		timer.start(step_secs)
	elif(set_active == false && active):
		disable()

func update_weather():
	var time_keeper = get_tree().get_first_node_in_group("time_keeper")
	
	#TODO: hook this up to weather manager
	day_1_sym.play("sunny")
	day_2_sym.play("sunny")
	day_3_sym.play("sunny")
	
	var moon_phase_today = time_keeper.get_moon_phase()
	var moon_phase_tomorrow = time_keeper.get_moon_phase(1)
	var moon_phase_day_after = time_keeper.get_moon_phase(2)
	night_1_sym.play(moon_phase_today)
	night_2_sym.play(moon_phase_tomorrow)
	night_3_sym.play(moon_phase_day_after)

func process():
	if(active):
		update_weather()
