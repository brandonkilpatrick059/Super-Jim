@tool
class_name Baseball_Card
extends Node2D

@onready var _portrait : Sprite2D = $portrait
@onready var _hp_meter = $HpReadout
@onready var _pow_meter = $PowReadout
@onready var _stam_meter = $StamReadout
@onready var _label_name = $NAME
@onready var _label_description = $DESCRIPTION
@onready var _effect_node = $effect_node
@onready var _team_symbol = $team_symbol

@export var team = ""

@export var card_name : String = "Todd Bonzalez"
@export var portrait_path : String = ""
@export var description : String = ""
@export var strength_rating: int = 0
@export var hp : int = 1
@export var stamina : int = 1
@export var power : int = 1

#TODO: implement
#adds stat to the next card upon death
@export var adds_hp_next : bool = false 
@export var adds_stamina_next : bool = false
@export var adds_dmg_next : bool = false

#TODO: implement
#gets stat from previous card upon death
@export var adds_hp_prev : bool = false 
@export var adds_stamina_prev : bool = false
@export var adds_dmg_prev : bool = false

#adds flat buff to next card
@export var flat_buff_hp_next : int = 0
@export var flat_buff_stamina_next : int = 0
@export var flat_buff_damage_next : int = 0

#TODO: implement
#buffs/debuffs stat to this card each kill
@export var buff_hp_on_kill : int = 0 
@export var buff_stamina_on_kill : int = 0
@export var buff_dmg_on_kill : int = 0

#TODO: implement
#stat is  equal to the number of a certain team in deck
@export var team_number_is_hp : bool = false
@export var team_number_is_stamina : bool = false
@export var team_number_is_dmg : bool = false

var stat_max = 9

func get_flat_buff_hp() -> int:
	return flat_buff_hp_next

func get_flat_buff_damage() -> int:
	return flat_buff_damage_next

func get_flat_buff_stamina() -> int:
	return flat_buff_stamina_next

func get_buff_hp_on_kill() -> int:
	return buff_stamina_on_kill

func get_buff_damage_on_kill() -> int:
	return flat_buff_damage_next

func get_buff_stamina_on_kill() -> int:
	return buff_dmg_on_kill

func _ready() -> void:
	_hp_meter.set_stat(hp)
	_stam_meter.set_stat(stamina)
	_pow_meter.set_stat(power)
	_label_name.text = card_name
	if(team):
		add_to_group(team)
		_team_symbol.play(team)
	if(portrait_path):
		_portrait.texture = load(portrait_path)
	if(description):
		_label_description.text = description

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

func get_team():
	return team

func set_hp(new_hp : int):
	if(new_hp > stat_max):
		new_hp = stat_max
	var diff = new_hp - hp
	hp = new_hp
	_hp_meter.modify_stat(diff)

func set_stamina(new_stamina : int):
	if(new_stamina > stat_max):
		new_stamina = stat_max
	var diff = new_stamina - stamina
	stamina = new_stamina
	_stam_meter.modify_stat(diff)

func set_power(new_power : int):
	if(new_power > stat_max):
		new_power = stat_max
	var diff = new_power - power
	power = new_power
	_pow_meter.modify_stat(diff)

func get_effect_node():
	return _effect_node
