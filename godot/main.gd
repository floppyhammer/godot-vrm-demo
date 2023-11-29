extends Node3D

@onready var lip_sync = $LipSync

# Called when the node enters the scene tree for the first time.
func _ready():
	var audio_data: Array[float] = []
	for i in 1024:
		audio_data.append(randf())
	
	lip_sync.update(audio_data)


func _process(delta):
	lip_sync.poll()


func _on_lip_sync_panicked(error: String):
	print(error)


func _on_lip_sync_updated(output: Dictionary):
	print(output)
