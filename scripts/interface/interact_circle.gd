extends Control

@onready var interact_sprite : AnimatedSprite2D = $interact_sprite
@onready var throw_sprite : AnimatedSprite2D = $throw_sprite

@onready var use_label : Label = $use_label
@onready var talk_label : Label = $talk_label
@onready var pick_up_label : Label = $pick_up_label
@onready var drop_label : Label = $drop_label
@onready var look_label : Label = $look_label
@onready var throw_label : Label = $throw_label

var activating_throw : bool = false
var deactivating_throw : bool = false
var activating : bool = false
var deactivating : bool = false
var interact_string : String = ""
var throw_active : bool = false

func _ready() -> void:
	hide_interact_labels()
	interact_sprite.visible = false
	throw_sprite.visible = false

func hide_interact_labels():
	use_label.visible = false
	talk_label.visible = false
	pick_up_label.visible = false
	drop_label.visible = false
	look_label.visible = false
	throw_label.visible = false

func show_interact_text(text : String):
	hide_interact_labels()
	match text:
		"use":
			use_label.visible = true
		"talk":
			talk_label.visible = true
		"pick up":
			pick_up_label.visible = true
		"drop":
			drop_label.visible = true
		"look":
			throw_label.visible = true
		"":
			use_label.visible = true

func deactivate_interact():
	hide_interact_labels()
	interact_sprite.play("retract")
	deactivating = true
	if(throw_active):
		deactivate_throw()
	interact_string = ""

func get_interact_text() -> String:
	return interact_string

func activate_interact(text: String):
	if(text != interact_string):
		interact_sprite.visible = true
		interact_string = text
		interact_sprite.play("expand")
		activating = true

func activate_throw():
	throw_sprite.visible = true
	throw_sprite.play("expand")
	activating_throw = true
	throw_active = true
	deactivating_throw = false

func deactivate_throw():
	throw_sprite.play("retract")
	deactivating_throw = true
	throw_active = false
	throw_label.visible = false

func _process(delta: float) -> void:
	var interact_count = interact_sprite.sprite_frames.get_frame_count("expand") - 1
	if(activating && interact_sprite.frame == interact_count):
		activating = false
		interact_sprite.play("active")
		show_interact_text(interact_string)
		if(interact_string == "drop"):
			activate_throw()
	if(deactivating && interact_sprite.frame == interact_count):
		deactivating = false
		interact_sprite.play("inactive")
		interact_sprite.visible = false
	
	var throw_count = throw_sprite.sprite_frames.get_frame_count("expand") - 1
	if(activating_throw && throw_sprite.frame == throw_count):
		activating_throw = false
		throw_sprite.play("active")
		throw_label.visible = true
	if(deactivating_throw && throw_sprite.frame == throw_count):
		deactivating_throw = false
		throw_sprite.play("inactive")
		throw_sprite.visible = false
