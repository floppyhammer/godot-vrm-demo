extends Node3D


# Called when the node enters the scene tree for the first time.
func _ready():
	var head_mesh: Mesh = $Furina.get_node("GeneralSkeleton/head").mesh
	var blend_shape_count = head_mesh.get_blend_shape_count()
	
	for i in blend_shape_count:
		print(head_mesh.get_blend_shape_name(i))
	
	
func set_blend_shape(key: String):
	match key:
		"a":
			pass
		"i":
			pass
		"u":
			pass
		"e":
			pass
		"o":
			pass
			


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
