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
@onready var item_square = $item_square
@onready var item_square_texture :TextureRect = $item_square/Sprite2D
@onready var quantity_label : Label = $item_square/Sprite2D/quantity_label
@onready var tutorial_tip = $tutorial_tip

@onready var interact_1 = $interact_pos_1
@onready var interact_2 = $interact_pos_2

var fps_counter_visible = false

var sound_player = AudioStreamPlayer.new()

var hearts : Array[Node] = []
var full_hearts : Array[Node] = []

var makes_noise = false

var money_timer = Timer.new()
var money_step_pause_secs = 0.06
var current_money = 0
var money = 0

var pizza_loss_timer = Timer.new()
var pizza_loss_on_screen_seconds = 2

var interact_text_visible = true

# Called when the node enters the scene tree for the first time.
func _ready():
	visible = true
	money_timer.one_shot = true
	pizza_loss_timer.one_shot = true
	add_child(money_timer)
	add_child(pizza_loss_timer)
	sound_player.bus = "Effects"
	add_child(sound_player)
	full_hearts = [heart_1, heart_2, heart_3, heart_4, heart_5, heart_6]
	for heart in full_hearts:
		heart.visible = false

func turn_on_ui_noises():
	makes_noise = true

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

func get_interact_text():
	if(item_square.visible):
		return interact_2.get_interact_text()
	else:
		return interact_1.get_interact_text()

func set_interact_text(text : String):
	interact_2.activate_interact(text)
	interact_1.activate_interact(text)

func deactivate_interact():
	interact_2.deactivate_interact()
	interact_1.deactivate_interact()

func hide_interact_text():
	interact_1.visible = false
	interact_2.visible = false
	interact_text_visible = false

func show_interact_text():
	interact_1.visible = true
	interact_2.visible = true
	interact_text_visible = true

func hide_item_square():
	item_square.visible = false

func show_item_square():
	item_square.visible = true

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

func hide_location_header():
	location_header.visible = false

func show_location_header():
	location_header.visible = true

func show_money():
	money_label.visible = true

func set_money(num : int, no_scroll : bool = false):
	if(no_scroll): #the money counter is set instantly, rather than ticking up
		money = num
		current_money = num
		set_money_tracker(num)
	else:
		money = num

func set_money_tracker(money : int):
	money_label.text = str("$",money)

func toggle_fps_counter():
	if fps_counter_visible:
		fps_counter_visible = false
	else:
		fps_counter_visible = true

func hide_tip():
	tutorial_tip.hide_tip()

func instant_hide_tip():
	tutorial_tip.instant_hide_tip()

func show_tip(text : String, 
arrow_left : bool = false, 
arrow_right : bool = false,
glyph_acts_1 : Array[String] = [],
glyph_acts_2 : Array[String] = [],
glyph_acts_3 : Array[String] = [],
dismiss_timer : float = 0.0):
	tutorial_tip.show_tip(text,arrow_left,arrow_right,glyph_acts_1,glyph_acts_2,glyph_acts_3,dismiss_timer)

func activate_header(label : String):
	location_header.activate_header(label)

func hide_header():
	location_header.hide_header()

func update_quantity_label_text(str : String):
	quantity_label.text = str

func show_quantity_label():
	quantity_label.visible = true

func hide_quantity_label():
	quantity_label.visible = false

func set_item_square(id : String):
	hide_quantity_label()
	match id:
		"" :
			item_square_texture.texture = load("res://sprites/interface/item_box/item_box.png")
		"pizza" :
			item_square_texture.texture = load("res://sprites/interface/item_box/item_pizza.png")
		"flashlight" :
			item_square_texture.texture = load("res://sprites/interface/item_box/item_flashlight.png")
		"fire_cracker":
			show_quantity_label()
			item_square_texture.texture = load("res://sprites/interface/item_box/item_fire_cracker.png")
		"skateboard" :
			item_square_texture.texture = load("res://sprites/interface/item_box/item_skateboard.png")
		"smoke_bomb":
			show_quantity_label()
			item_square_texture.texture = load("res://sprites/interface/item_box/item_smoke_bomb.png")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if(interact_text_visible):
		if(item_square.visible):
			interact_2.visible = true
			interact_1.visible = false
		else:
			interact_1.visible = true
			interact_2.visible = false
	if(money_timer.is_stopped()):
		if(current_money < money):
			current_money = current_money + 1
			if(makes_noise):
				sound_player.stream = load("res://audio/soundFX/coins.wav")
				sound_player.play()
		if(current_money > money):
			current_money = current_money - 1
			if(makes_noise):
				sound_player.stream = load("res://audio/soundFX/voice/low_sine_voice/1.wav")
				sound_player.play()
		money_timer.start(money_step_pause_secs)
	if(pizza_loss_timer.is_stopped() && pizza_lost.visible):
		pizza_lost.visible = false
	if(fps_counter_visible):
		fps_counter.visible = true
		fps_counter.text = str(Engine.get_frames_per_second())
	else:
		fps_counter.visible = false
	set_money_tracker(current_money)
