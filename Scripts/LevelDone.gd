extends Area2D

export(String, FILE, "*.tscn") var world_scene

func _physics_process(delta):
	#checking if bodies are crossing
	var bodies = get_overlapping_bodies()
	for body in bodies:
		if body.name == "Player":
			get_tree().change_scene(world_scene)