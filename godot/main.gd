extends Node3D

var lip_sync

# Called when the node enters the scene tree for the first time.
func _ready():
	lip_sync = LipSync.new()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
