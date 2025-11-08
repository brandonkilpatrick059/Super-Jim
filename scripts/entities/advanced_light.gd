#this class wraps two lights, a dynamic point light and cheap sprite light
#and allows for graphics configuration options & simple interface for
#parent nodes
class_name AdvancedLight
extends Node2D

@onready var light_point : PointLight2D = $Light2D_point
@onready var light_sprite : Sprite2D = $Light2D_sprite

@export var light_point_lo = false
@export var light_point_med = false
@export var light_point_hi = false

var light_running = false
var update = true
#var switched_on = true

var random : RandomNumberGenerator = RandomNumberGenerator.new()

func _ready():
	light_point.visible = false
	light_sprite.visible = false

func turn_light_on():
	light_running = true
	update = true

func turn_light_off():
	light_running = false
	update = true

func toggle_light():
	light_running = !light_running
	update = true

func set_light_running(running : bool):
	light_running = running
	update = true

func _process(delta: float) -> void:
	if(update):
		if(light_running):
			if(light_point_lo && SettingsVariables.lighting_index == 0):
				light_point.enabled = true
				light_point.visible = true
				light_sprite.visible = false
			else:
				light_point.enabled = false
				light_point.visible = false
				light_sprite.visible = true
			if(light_point_med && SettingsVariables.lighting_index == 1):
				light_point.enabled = true
				light_point.visible = true
				light_sprite.visible = false
			else:
				light_point.enabled = false
				light_point.visible = false
				light_sprite.visible = true
			if(light_point_hi && SettingsVariables.lighting_index == 2):
				light_point.enabled = true
				light_point.visible = true
				light_sprite.visible = false
			else:
				light_point.enabled = false
				light_point.visible = false
				light_sprite.visible = true
			#switched_on = true
		elif(!light_running):
			light_point.enabled = false
			light_sprite.visible = false
			#switched_on = false
		update = false
