@tool
class_name Baseball_Card
extends Node2D

@onready var _portrait : Sprite2D = $portrait
@onready var _hp_meter = $HpReadout
@onready var _pow_meter = $PowReadout
@onready var _stam_meter = $StamReadout
@onready var _label_name = $NAME
@onready var _effect_node = $effect_node

@export var card_name : String = "Todd Bonzalez"
@export var hp = 1
@export var stamina = 1
@export var power = 1

func _ready() -> void:
	_hp_meter.set_stat(hp)
	_stam_meter.set_stat(stamina)
	_pow_meter.set_stat(power)

func get_card_name():
	return card_name

func get_hp():
	return hp

func get_stamina():
	return stamina

func get_power():
	return power

func power_glow():
	_pow_meter.glow()

func set_hp(new_hp : int):
	var diff = new_hp - hp
	hp = new_hp
	_hp_meter.modify_stat(diff)

func set_stamina(new_stamina : int):
	var diff = new_stamina - stamina
	stamina = new_stamina
	_stam_meter.modify_stat(diff)

func set_power(new_power : int):
	var diff = new_power - power
	power = new_power
	_pow_meter.modify_stat(diff)

func get_effect_node():
	return _effect_node
