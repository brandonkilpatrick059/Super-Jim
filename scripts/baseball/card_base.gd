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
@onready var _base_border = $base_border

@export var team = ""

@export var card_name : String = "Todd Bonzalez"
@export var portrait_path : String = ""
@export_multiline var description : String = ""
@export var strength_rating: int = 0
@export var hp : int = 1
@export var shield : int = 1
@export var power : int = 1

#adds stat to the next card upon death
@export var adds_shield_next : bool = false
@export var adds_dmg_next : bool = false

#adds flat buff to next card
@export var flat_buff_hp_next : int = 0
@export var flat_buff_shield_next : int = 0
@export var flat_buff_damage_next : int = 0

#buffs/debuffs stat to this card each kill
@export var buff_hp_on_kill : int = 0 
@export var buff_shield_on_kill : int = 0
@export var buff_dmg_on_kill : int = 0

@export var throws_hp : int = 0
@export var throws_shield : int = 0
@export var throws_power: int = 0

@export var throws_hp_on_kill : int = 0
@export var throws_shield_on_kill : int = 0
@export var throws_power_on_kill: int = 0

@export var throws_remaining_shield : int = 0
@export var throws_remaining_power: int = 0

#buffs damage against team
@export var buff_dmg_against_team : int = 0
@export var buff_dmg_target_team : String = ""

#debuffs damage from team
@export var debuff_dmg_from_team : int = 0
@export var debuff_dmg_target_team : String = ""

@export var damage_transfers_to_power : bool = false
@export var damage_transfers_to_shield : bool = false

@export var catches_opponent_stats : bool = false

#stat is buffed by the number of a certain team in deck
@export var team_number_buff_hp : bool = false
@export var team_number_buff_shield : bool = false
@export var team_number_buff_dmg : bool = false

@export var bypasses_shield : bool = false

var stat_max = 9

var meters_stowed : bool = false

var ready_stow = true

func unstow():
	ready_stow = false
	add_meters()

func stow_meters():
	if(not meters_stowed):
		remove_child(_hp_meter)
		remove_child(_stam_meter)
		remove_child(_pow_meter)
		meters_stowed = true

func add_meters():
	if(meters_stowed):
		add_child(_hp_meter)
		add_child(_stam_meter)
		add_child(_pow_meter)
		meters_stowed = false

func get_debuff_dmg_from_team() -> int :
	return debuff_dmg_from_team

func get_debuff_dmg_target_team() -> String:
	return debuff_dmg_target_team

func get_buff_dmg_against_team() -> int :
	return buff_dmg_against_team

func get_buff_dmg_target_team() -> String:
	return buff_dmg_target_team

func get_strength_rating() -> int:
	return strength_rating

func get_flat_buff_hp() -> int:
	return flat_buff_hp_next

func get_flat_buff_damage() -> int:
	return flat_buff_damage_next

func get_flat_buff_shield() -> int:
	return flat_buff_shield_next

func get_buff_hp_on_kill() -> int:
	return buff_hp_on_kill

func get_buff_damage_on_kill() -> int:
	return buff_dmg_on_kill

func get_buff_shield_on_kill() -> int:
	return buff_shield_on_kill

func get_throws_hp_on_kill() -> int:
	return throws_hp_on_kill

func get_throws_damage_on_kill() -> int:
	return throws_power_on_kill

func get_throws_shield_on_kill() -> int:
	return throws_shield_on_kill

func get_team_number_buff_hp() -> int:
	return team_number_buff_hp

func get_team_number_buff_damage() -> int:
	return team_number_buff_dmg

func get_team_number_buff_shield() -> int:
	return team_number_buff_shield

func get_throws_hp() -> int:
	return throws_hp

func get_throws_power() -> int:
	return throws_power

func get_throws_shield() -> int:
	return throws_shield

func get_catches_opponent_stats() -> bool:
	return catches_opponent_stats

func get_damage_transfers_to_shield() -> bool:
	return damage_transfers_to_shield

func get_damage_transfers_to_power() -> bool:
	return damage_transfers_to_power

func get_bypasses_shield() -> bool:
	return bypasses_shield

func _ready() -> void:
	_hp_meter.set_stat(hp)
	_stam_meter.set_stat(shield)
	_pow_meter.set_stat(power)
	_label_name.text = card_name
	if(team):
		add_to_group(team)
		_team_symbol.play(team)
	if(portrait_path):
		_portrait.texture = load(portrait_path)
	if(description):
		var text = str(description)
		_label_description.parse_bbcode(text)
	
	if(team == "green"):
		_base_border.modulate = Color(0.7,1.0,0.7)
	elif(team == "yellow"):
		_base_border.modulate = Color(1.0,1.0,0.7)
	elif(team == "gray"):
		_base_border.modulate = Color(0.65,0.65,0.65)
	if(not ready_stow):
		#remove meters from the tree in the card_roster where we don't need
		#them running _physics_process every frame 
		stow_meters()

func get_card_team():
	return team

func get_card_name():
	return card_name

func get_hp():
	return hp

func get_shield():
	return shield

func get_power():
	return power

func power_glow():
	_pow_meter.glow()

func get_team():
	return team

func set_hp(new_hp : int):
	if(meters_stowed):
		add_meters()
	if(new_hp > stat_max):
		new_hp = stat_max
	var diff = new_hp - hp
	hp = new_hp
	_hp_meter.modify_stat(diff)

func set_shield(new_shield : int):
	if(meters_stowed):
		add_meters()
	if(new_shield > stat_max):
		new_shield = stat_max
	var diff = new_shield - shield
	shield = new_shield
	_stam_meter.modify_stat(diff)

func set_power(new_power : int):
	if(meters_stowed):
		add_meters()
	if(new_power > stat_max):
		new_power = stat_max
	var diff = new_power - power
	power = new_power
	_pow_meter.modify_stat(diff)

func get_effect_node():
	return _effect_node
