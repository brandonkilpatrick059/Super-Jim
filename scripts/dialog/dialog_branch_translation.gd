extends Node
#TODO: CURRENTLY NOT SUPPORTED - code for future consideration.
#this would be a child of a dialog_branch with the node named 
#using a 3-character language code, which can be retrieved from settings
#the equivalent get_speaker_text() and get_speech_options() 
#functions in dialog_branch will call through to this script

@export_multiline var speaker_text : Array[String]
@export_multiline var speech_options : Array[String]

func get_speaker_text():
	var index = randi_range(0,speaker_text.size()-1)
	return speaker_text[index]

func get_speech_options():
	return speech_options
