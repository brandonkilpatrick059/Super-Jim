extends Control

@onready var health_meter = $health_meter
@onready var heart_1 : AnimatedSprite2D = $health_meter/heart_1
@onready var heart_2 : AnimatedSprite2D = $health_meter/heart_2
@onready var heart_3 : AnimatedSprite2D = $health_meter/heart_3
@onready var heart_4 : AnimatedSprite2D = $health_meter/heart_4
@onready var heart_5 : AnimatedSprite2D = $health_meter/heart_5
@onready var heart_6 : AnimatedSprite2D = $health_meter/heart_6
@onready var location_header = $location_header
@onready var money_label = $money_tracker/money_label
@onready var pizza_lost = $pizza_lost
@onready var fps_counter = $fps_counter/fps
@onready var dash_meter = $dash_meter

@export var fps_counter_visible = false

var sound_player = AudioStreamPlayer.new()

var hearts : Array[Node] = []
var full_hearts : Array[Node] = []



var money_timer = Timer.new()
var money_step_pause_secs = 0.06
var current_money = 0
var money = 0

var pizza_loss_timer = Timer.new()
var pizza_loss_on_screen_seconds = 2

# Called when the node enters the scene tree for the first time.
func _ready():
	money_timer.one_shot = true
	pizza_loss_timer.one_shot = true
	add_child(money_timer)
	add_child(pizza_loss_timer)
	sound_player.bus = "Effects"
	add_child(sound_player)
	full_hearts = [heart_1, heart_2, heart_3, heart_4, heart_5, heart_6]
	for heart in full_hearts:
		heart.visible = false

func set_max_hearts(num):
	hearts = []
	var iter = 0
	while(iter < num):
		var heart = full_hearts[iter]
		heart.visible = true
		hearts.append(heart)
		iter = iter + 1

func update_hearts(points : int):
	var iterator = 0
	while(iterator < hearts.size()):
		if(iterator < points):
			hearts[iterator].play("active")
		else:
			hearts[iterator].play("inactive")
		iterator+=1

func hide_dash():
	dash_meter.visible = false

func show_dash():
	dash_meter.visible = true

func dash_blink():
	dash_meter.start_blinking()

func dash_stop_blink():
	dash_meter.stop_blinking()

func set_max_dash_fraction(fraction: float):
	dash_meter.set_fraction_of_full_bar(fraction)

func set_dash_fraction(fraction: float):
	dash_meter.set_fraction_filled(fraction)

func _on_pizza_lost():
	pizza_lost.visible = true
	pizza_loss_timer.start(pizza_loss_on_screen_seconds)
	sound_player.stream = load("res://audio/soundFX/pizza_lost.wav")
	sound_player.play()

func hide_hearts():
	health_meter.visible = false

func show_hearts():
	health_meter.visible = true

func hide_money():
	money_label.visible = false

func show_money():
	money_label.visible = true

func set_money(num : int):
	money = num

func set_money_tracker(money : int):
	money_label.text = str("$",money)
	

func activate_header(label : String):
	location_header.activate_header(label)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(money_timer.is_stopped()):
		if(current_money < money):
			current_money = current_money + 1
			sound_player.stream = load("res://audio/soundFX/coins.wav")
			sound_player.play()
		if(current_money > money):
			current_money = current_money - 1
			sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
			sound_player.play()
		money_timer.start(money_step_pause_secs)
	if(pizza_loss_timer.is_stopped() && pizza_lost.visible):
		pizza_lost.visible = false
	if(fps_counter_visible):
		fps_counter.visible = true
		fps_counter.text = str(Engine.get_frames_per_second())
	set_money_tracker(current_money)
