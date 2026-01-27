extends Node

@onready var spark = preload("res://effects/fire_cracker_spark.tscn")

var timer := Timer.new()
var fuse_secs = 3.0

func _ready() -> void:
	timer.one_shot = true
	add_child(timer)
	timer.start(fuse_secs)

func _physics_process(delta: float) -> void:
	if(timer.is_stopped()):
		var commotion_spark = spark.instantiate()
		commotion_spark.global_position = get_parent().global_position
		get_parent().get_parent().add_child(commotion_spark)
		get_parent().queue_free()
