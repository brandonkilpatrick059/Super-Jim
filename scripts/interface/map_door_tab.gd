extends AnimatedSprite2D

@onready var _map_link = $map_link
@onready var _name_label = $name_label
@onready var _arrow = $arrow
@onready var _glyph = $glyph
@onready var _lock = $lock

func _ready() -> void:
	_arrow.visible = false
	_glyph.visible = false
	_lock.visible = false

func set_tab(tab_name : String, tab_state : String, has_link : bool, lock_state : String = ""):
	_name_label.text = tab_name
	play(tab_state)
	_glyph.get_child(0).get_glyph()
	
	if(lock_state !=  ""):
		_lock.visible = true
		_lock.play(lock_state)
	else:
		_lock.visible = false
	
	if(has_link):
		_arrow.visible = true
		if(tab_state == "selected"):
			_glyph.visible = true
		else:
			_glyph.visible = false
	else:
		_arrow.visible = false
		_glyph.visible = false
