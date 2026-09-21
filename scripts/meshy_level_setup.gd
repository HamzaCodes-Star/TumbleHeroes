extends Node3D

func _ready() -> void:
	var mi: MeshInstance3D = get_node_or_null("Mesh0")
	if not mi:
		# Search recursively
		for child in get_children():
			if child is MeshInstance3D:
				mi = child
				break

	if mi and mi.mesh:
		# Clean up any default / unscaled collision
		var old_col = mi.get_node_or_null("Mesh0_col")
		if old_col:
			old_col.queue_free()

		# Build baked collision shape pre-multiplied by local mesh transform (100x FBX unit scale)
		# This ensures Godot's 3D physics engine gets a 100% accurate, un-distorted BVH collision mesh
		var orig_faces = mi.mesh.get_faces()
		var baked_faces = PackedVector3Array()
		baked_faces.resize(orig_faces.size())
		var mi_xform = mi.transform
		for i in range(orig_faces.size()):
			baked_faces[i] = mi_xform * orig_faces[i]

		var concave = ConcavePolygonShape3D.new()
		concave.set_faces(baked_faces)

		var col_shape = CollisionShape3D.new()
		col_shape.name = "CourseCollisionShape"
		col_shape.shape = concave

		var sb = StaticBody3D.new()
		sb.name = "CourseStaticBody"
		sb.collision_layer = 1
		sb.collision_mask = 0
		sb.add_child(col_shape)
		add_child(sb)
		
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
