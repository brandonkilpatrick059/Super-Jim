@tool
class_name dialog_branch
extends Node2D

@onready var _editor_anim = $AnimatedSprite2D

@export var speaker_text : Array[String]
@export var speaker_portrait : SpriteFrames
@export var speaker_emote : String #animation to run on sprite

@export var speech_options : Array[String]
@export var option_branches: Array[dialog_branch]
@export var voice : String
@export var speaker_name : String

@export var gives_money : int = 0
@export var dialog_script : Node = null

@export var shows_wares : bool = false

@export var plays_cards : bool = false
@export var card_deck : Array[int]
@export var play_sound_path : String = ""

@export var conditional_option_script : Node 

var random = RandomNumberGenerator.new()

func get_sound_path():
	return play_sound_path

func get_gives_money() -> int:
	return gives_money

func get_speaker_portrait():
	return speaker_portrait

func get_speaker_name():
	return speaker_name

func get_speaker_text():
	var index = random.randi_range(0,speaker_text.size()-1)
	return speaker_text[index]

func get_speaker_emote():
	return speaker_emote

func get_speech_options():
	return speech_options

func get_option_branches():
	return option_branches

func get_conditional_option_script():
	return conditional_option_script

func has_conditional_option_script():
	return !(conditional_option_script == null)

func get_voice():
	return voice

func get_option_branch(index : int) -> dialog_branch:
	return option_branches[index]

func get_dialog_script():
	return dialog_script

func get_plays_cards():
	return plays_cards

func get_deck():
	return card_deck

func get_shows_wares() -> bool:
	return shows_wares

func set_speech_options(options : Array[String]):
	speech_options = options

#func _ready():
	#_editor_anim

func _draw():
	if(Engine.is_editor_hint()):
			for branch in option_branches:
				if(branch != null):
					draw_line(Vector2(), get_transform().affine_inverse() * branch.position, Color(1,0,0,1), -1)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _ready():
	if(Engine.is_editor_hint()):
		if(speaker_portrait != null):
			_editor_anim.sprite_frames = speaker_portrait
			if(speaker_emote != ""):
				_editor_anim.play(speaker_emote)
			else:
				_editor_anim.play("default")
		queue_redraw()

#COMMENT THIS OUT WHEN YOU ARE DONE
#func _process(delta: float) -> void:
	#if(Engine.is_editor_hint()):
		#if(speaker_portrait != null):
			#_editor_anim.sprite_frames = speaker_portrait
			#if(speaker_emote != ""):
				#_editor_anim.play(speaker_emote)
			#else:
				#_editor_anim.play("default")
		#queue_redraw()
