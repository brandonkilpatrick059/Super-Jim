extends CollisionObject2D

signal make_comment(String)

@export var text : String

#two kinds, one for interacting and one for playing text when the player
#walks into the zone
@export var text_when_zone_entered : bool = false
@export var script_when_zone_entered : bool = false
@export var play_once : bool = false
var has_played = false

@export var save_tag : String = ""

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_save_tag():
	return save_tag

func reset_has_played():
	has_played = false

func interact():
	if(!text_when_zone_entered):
		make_comment.emit(text)

func _on_body_entered(body : Node2D):
	if(body.is_in_group("player")):
		if(text_when_zone_entered || script_when_zone_entered):
			if(play_once && !has_played):
				has_played = true
				if(text_when_zone_entered && text != ""):
					make_comment.emit(text)
				if(script_when_zone_entered && get_children().size() > 0):
					get_children()[0].run_script()
			elif(!play_once):
				if(text_when_zone_entered):
					make_comment.emit(text)
				if(script_when_zone_entered && get_children().size() > 0):
					get_children()[0].run_script()
		

func get_save_dictionary() -> Dictionary:
	var save_dictionary = {
		"type" : "comment",
		"save_tag" : get_save_tag(),
		"has_played" : has_played 
	}
	return save_dictionary

func load_from_dictionary(load_dictionary : Dictionary):
	has_played = load_dictionary.get("has_played")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
