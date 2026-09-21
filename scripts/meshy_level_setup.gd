extends Node3D

func _ready() -> void:
	var mi: MeshInstance3D = get_node_or_null("Mesh0")
	if not mi:
		# Search recursively
		for child in get_children():
			if child is MeshInstance3D:
				mi = child
				break

	if mi:
		# 1. Generate full trimesh physical collision for the entire 3D obstacle level
		mi.create_trimesh_collision()
		
		# 2. Enhance PBR material with roughness & metallic maps if available
		var mat: StandardMaterial3D = mi.mesh.surface_get_material(0)
		if mat:
			var rough_path = "res://assets/meshy_level/Meshy_AI_Level_for_mobile_game_0921081155_texture_roughness.png"
			var norm_path = "res://assets/meshy_level/Meshy_AI_Level_for_mobile_game_0921081155_texture_normal.png"
			if ResourceLoader.exists(rough_path):
				mat.roughness_texture = load(rough_path)
			if ResourceLoader.exists(norm_path):
				mat.normal_enabled = true
				mat.normal_texture = load(norm_path)
			mat.roughness = 0.55
			mat.metallic = 0.15
