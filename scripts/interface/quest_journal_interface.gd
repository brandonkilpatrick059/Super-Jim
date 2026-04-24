@tool
extends Node2D

@export var test_key : String
@export var test_state : int

@onready var photo: Sprite2D = $photo
@onready var topic_name: RichTextLabel = $topic_name
@onready var quest_status: RichTextLabel = $quest_status
@onready var quest_logs : Node = $quest_logs
@onready var right_arrow : Sprite2D = $right_arrow
@onready var left_arrow : Sprite2D = $left_arrow

var quest_log_keys : Array[String] = []
var quest_log_values : Array[int] = []

var index = 0

var audio_player := AudioStreamPlayer.new()

func close():
	queue_free()

func _ready():
	left_arrow.visible = false
	right_arrow.visible = false
	if(Engine.is_editor_hint()):
		get_log(test_key,test_state)
	else:
		var player_ref = get_tree().get_first_node_in_group("player")
		quest_log_keys = player_ref.get_quest_log_keys()
		quest_log_values = player_ref.get_quest_log_values()
		get_log(quest_log_keys[index],quest_log_values[index])
		add_child(audio_player)
		audio_player.bus = "Effects"
		audio_player.stream = load("res://audio/soundFX/maracca.ogg")

func get_log(name : String, state: int):
	var log = quest_logs.find_child(name)
	var log_name : String = log.get_log_name()
	topic_name.parse_bbcode(log_name)
	var log_text = log.get_state_text(state)
	quest_status.parse_bbcode(log_text)
	var log_picture_path = log.get_picture_path()
	photo.texture = load(log_picture_path)

func _process(delta: float) -> void:
	if(!Engine.is_editor_hint()):
		if(index < quest_log_keys.size() - 1):
			right_arrow.visible = true
		else:
			right_arrow.visible = false
		
		if(index > 0):
			left_arrow.visible = true
		else:
			left_arrow.visible = false
			
		if(Input.is_action_just_pressed("menu_right")):
			if(index < quest_log_keys.size() - 1):
				index = index + 1
				get_log(quest_log_keys[index],quest_log_values[index])
				audio_player.play()
		if(Input.is_action_just_pressed("menu_left")):
			if(index != 0):
				index = index - 1
				get_log(quest_log_keys[index],quest_log_values[index])
				audio_player.play()
