class_name Baseball_Card
extends Node2D

@onready var _portrait : Sprite2D = $portrait
@onready var _label_hp = $HP
@onready var _label_stamina = $STAMINA
@onready var _label_power = $POWER
@onready var _label_name = $NAME
@onready var _effect_node = $effect_node

@export var card_name : String = "Todd Bonzalez"
@export var hp = 1
@export var stamina = 1
@export var power = 1

func get_card_name():
	return card_name

func get_hp():
	return hp

func get_stamina():
	return stamina

func get_power():
	return power

func set_hp(new_hp : int):
	hp = new_hp

func set_stamina(new_stamina : int):
	stamina = new_stamina

func set_power(new_power : int):
	power = new_power

func get_effect_node():
	return _effect_node
