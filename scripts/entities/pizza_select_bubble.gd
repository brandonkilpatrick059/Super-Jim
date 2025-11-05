extends Node2D

@onready var _label = $Label

func set_label(text : String):
	_label.text = text
