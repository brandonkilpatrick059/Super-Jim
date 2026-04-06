extends Node2D

@onready var _bed_slot = $bed_slot
@onready var _desk_slot = $desk_slot
@onready var _night_stand_slot = $night_stand_slot
@onready var _wardrobe_slot = $wardrobe_slot
@onready var _tv_slot = $tv_slot
@onready var _lamp_slot = $lamp_slot
@onready var _cd_player_slot = $cd_player_slot

var has_tv : bool = false
var has_cd_player : bool = false

func set_bed_slot(bed : Node):
	if(_bed_slot.get_child_count() > 0):
		_bed_slot.get_children()[0].queue_free()
	_bed_slot.add_child(bed)
	bed.position = Vector2(0,0)

func add_tv():
	has_tv = true
	var TV = load("res://TV/TV.tscn")
	var new_TV = TV.instantiate()
	_tv_slot.add_child(new_TV)
	new_TV.position = Vector2(0,0)
	
func set_desk_slot(desk : Node):
	if(_desk_slot.get_child_count() > 0):
		_desk_slot.get_children()[0].queue_free()
	if(_cd_player_slot.get_child_count() > 0):
		_cd_player_slot.get_children()[0].position = Vector2(0,14)
	_desk_slot.add_child(desk)
	desk.position = Vector2(0,0)

func set_night_stand_slot(night_stand : Node):
	if(_night_stand_slot.get_child_count() > 0):
		_night_stand_slot.get_children()[0].queue_free()
	if(_lamp_slot.get_child_count() > 0):
		_lamp_slot.get_children()[0].position = Vector2(0,14)
	_night_stand_slot.add_child(night_stand)
	night_stand.position = Vector2(0,-16)

func add_cd_player():
	has_cd_player = true
	var cd_player = load("res://entities/props/static props/apartment/cd_player.tscn")
	var new_cd_player = cd_player.instantiate()
	_cd_player_slot.add_child(new_cd_player)
	new_cd_player.position = Vector2(0,0)
	if(_desk_slot.get_child_count() > 0):
		new_cd_player.position = Vector2(0,14)
	else:
		new_cd_player.position = Vector2(0,20)

func set_lamp_slot(lamp : Node):
	if(_lamp_slot.get_child_count() > 0):
		_lamp_slot.get_children()[0].queue_free()
	_lamp_slot.add_child(lamp)
	if(_night_stand_slot.get_child_count() > 0):
		lamp.position = Vector2(0,14)
	else:
		lamp.position = Vector2(0,20)

func set_wardrobe_slot(wardrobe : Node):
	if(_wardrobe_slot.get_child_count() > 0):
		_wardrobe_slot.get_children()[0].queue_free()
	_wardrobe_slot.add_child(wardrobe)
	wardrobe.position = Vector2(0,0)


func get_save_dictionary() -> Dictionary:
	var bed_slot = ""
	if (_bed_slot.get_children().size() > 0):
		bed_slot = _bed_slot.get_child(0).get_path_to_self()
	
	var desk_slot = ""
	if (_desk_slot.get_children().size() > 0):
		desk_slot = _desk_slot.get_child(0).get_path_to_self()
	
	var night_stand_slot = ""
	if (_night_stand_slot.get_children().size() > 0):
		night_stand_slot = _night_stand_slot.get_child(0).get_path_to_self()
	
	var wardrobe_slot = ""
	if (_wardrobe_slot.get_children().size() > 0):
		wardrobe_slot = _wardrobe_slot.get_child(0).get_path_to_self()
	
	var lamp_slot = ""
	if(_lamp_slot.get_children().size() > 0):
		lamp_slot = _lamp_slot.get_child(0).get_path_to_self()
		
	var save_dictionary = {
		"bed_slot" = bed_slot,
		"desk_slot" = desk_slot,
		"night_stand_slot" = night_stand_slot,
		"wardrobe_slot" = wardrobe_slot,
		"has_tv" = has_tv,
		"has_cd_player" = has_cd_player,
		"lamp_slot" = lamp_slot
	}
	
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	if(load_dictionary.get("bed_slot") != ""):
		var load_str = String(load_dictionary.get("bed_slot"))
		var bed : Node = load(load_str).instantiate()
		set_bed_slot(bed)
	if(load_dictionary.get("desk_slot") != ""):
		var load_str = String(load_dictionary.get("desk_slot"))
		var desk : Node = load(load_str).instantiate()
		set_desk_slot(desk)
	if(load_dictionary.get("night_stand_slot") != ""):
		var load_str = String(load_dictionary.get("night_stand_slot"))
		var night_stand : Node = load(load_str).instantiate()
		set_night_stand_slot(night_stand)
	if(load_dictionary.get("wardrobe_slot") != ""):
		var load_str = String(load_dictionary.get("wardrobe_slot"))
		var wardrobe : Node = load(load_str).instantiate()
		set_wardrobe_slot(wardrobe)
	if(load_dictionary.get("has_tv")):
		add_tv()
	if(load_dictionary.get("has_cd_player")):
		add_cd_player()
	if(load_dictionary.get("lamp_slot") != ""):
		var load_str = String(load_dictionary.get("lamp_slot"))
		var lamp : Node = load(load_str).instantiate()
		set_lamp_slot(lamp)
