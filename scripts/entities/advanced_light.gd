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
var switched_on = false

var random : RandomNumberGenerator = RandomNumberGenerator.new()

func turn_light_on():
	light_running = true

func turn_light_off():
	light_running = false

func toggle_light():
	light_running = !light_running

func set_light_running(running : bool):
	light_running = running

func _physics_process(delta: float) -> void:
	if(!switched_on && light_running):
		if(light_point_lo && SettingsVariables.lighting_index == 0):
			light_point.enabled = true
			light_sprite.visible = false
		else:
			light_point.enabled = false
			light_sprite.visible = true
		if(light_point_med && SettingsVariables.lighting_index == 1):
			light_point.enabled = true
			light_sprite.visible = false
		else:
			light_point.enabled = false
			light_sprite.visible = true
		if(light_point_hi && SettingsVariables.lighting_index == 2):
			light_point.enabled = true
			light_sprite.visible = false
		else:
			light_point.enabled = false
			light_sprite.visible = true
		switched_on = true
	elif(switched_on && !light_running):
		light_point.enabled = false
		light_sprite.visible = false
		switched_on = false
