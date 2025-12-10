extends Node2D

@onready var _bed_slot = $bed_slot
@onready var _desk_slot = $desk_slot
@onready var _night_stand_slot = $night_stand_slot
@onready var _wardrobe_slot = $wardrobe_slot

func set_bed_slot(bed : Node):
	if(_bed_slot.get_child_count() > 0):
		_bed_slot.get_children()[0].queue_free()
	_bed_slot.add_child(bed)
	bed.position = Vector2(0,0)

func set_desk_slot(desk : Node):
	if(_desk_slot.get_child_count() > 0):
		_desk_slot.get_children()[0].queue_free()
	_desk_slot.add_child(desk)
	desk.position = Vector2(0,0)

func set_night_stand_slot(night_stand : Node):
	if(_night_stand_slot.get_child_count() > 0):
		_night_stand_slot.get_children()[0].queue_free()
	_night_stand_slot.add_child(night_stand)
	night_stand.position = Vector2(0,0)

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
		
	var save_dictionary = {
		"bed_slot" = bed_slot,
		"desk_slot" = desk_slot,
		"night_stand_slot" = night_stand_slot,
		"wardrobe_slot" = wardrobe_slot
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

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
