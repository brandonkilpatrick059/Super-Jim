@tool
extends Node

@export var picture_path : String = ""
@export var log_name : String = ""

func get_state_text(state : int) -> String:
	return get_child(state).get_text()

func get_log_name() -> String:
	return log_name

func get_picture_path() -> String:
	return picture_path
