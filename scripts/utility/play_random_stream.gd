extends AudioStreamPlayer2D

@export var stream_paths : Array[String] = []

func _ready() -> void:
	var stream_path = stream_paths[randi_range(0,stream_paths.size() - 1)]
	stream = load(stream_path)
	play()
