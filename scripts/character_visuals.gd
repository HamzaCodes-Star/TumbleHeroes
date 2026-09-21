extends Node3D
class_name CharacterVisuals

enum SkinType {
	FLUFFY_TEDDY,
	GOOFY_PENGUIN,
	CHUBBY_DINO,
	KING_FLUFF,
	BOUNCY_COSMO,
	CANDY_BEAN
}

@export var current_skin: SkinType = SkinType.FLUFFY_TEDDY

# Body hierarchy
var body_root: Node3D
var torso_node: Node3D
var head_node: Node3D
var belly_mesh_node: MeshInstance3D
var tail_node: Node3D
var left_arm: Node3D
var right_arm: Node3D
var left_leg: Node3D
var right_leg: Node3D

# Facial features
var left_ear: Node3D
var right_ear: Node3D
var snout_node: Node3D
var beak_node: Node3D
var blush_left: Node3D
var blush_right: Node3D

# Accessories
var crown: Node3D
var space_visor: Node3D
var dino_spikes: Node3D
var penguin_bowtie: Node3D

# Materials
var fur_mat: StandardMaterial3D
var belly_mat: StandardMaterial3D
var clothes_mat: StandardMaterial3D
var pants_mat: StandardMaterial3D
var shoe_mat: StandardMaterial3D
var eye_white_mat: StandardMaterial3D
var pupil_mat: StandardMaterial3D
var twinkle_mat: StandardMaterial3D
var blush_mat: StandardMaterial3D
var ear_inner_mat: StandardMaterial3D
var beak_mat: StandardMaterial3D
var gold_mat: StandardMaterial3D

var anim_time: float = 0.0
var idle_phase: float = 0.0

func _ready() -> void:
	# Hide any legacy placeholder meshes from old scenes
	if has_node("BodyMesh"):
		get_node("BodyMesh").visible = false
	if has_node("MeshInstance3D"):
		get_node("MeshInstance3D").visible = false

	idle_phase = randf_range(0.0, 10.0)
	_build_fluffy_rig()
	apply_skin(current_skin)

func _build_fluffy_rig() -> void:
	# Clean any previous procedural children
	for c in get_children():
		if c.name != "BodyMesh" and c.name != "MeshInstance3D":
			c.queue_free()

	fur_mat = StandardMaterial3D.new()
	fur_mat.roughness = 0.65

	belly_mat = StandardMaterial3D.new()
	belly_mat.roughness = 0.7

	clothes_mat = StandardMaterial3D.new()
	clothes_mat.roughness = 0.5

	pants_mat = StandardMaterial3D.new()
	pants_mat.roughness = 0.55

	shoe_mat = StandardMaterial3D.new()
	shoe_mat.albedo_color = Color(0.96, 0.96, 0.96)
	shoe_mat.roughness = 0.35

	eye_white_mat = StandardMaterial3D.new()
	eye_white_mat.albedo_color = Color(1.0, 1.0, 1.0)
	eye_white_mat.roughness = 0.1

	pupil_mat = StandardMaterial3D.new()
	pupil_mat.albedo_color = Color(0.04, 0.04, 0.06)
	pupil_mat.roughness = 0.1

	twinkle_mat = StandardMaterial3D.new()
	twinkle_mat.albedo_color = Color(1.0, 1.0, 1.0)
	twinkle_mat.emission_enabled = true
	twinkle_mat.emission = Color(1.0, 1.0, 1.0)
	twinkle_mat.emission_energy_multiplier = 0.5

	blush_mat = StandardMaterial3D.new()
	blush_mat.albedo_color = Color(1.0, 0.5, 0.65, 0.75)
	blush_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA

	ear_inner_mat = StandardMaterial3D.new()
	ear_inner_mat.albedo_color = Color(1.0, 0.75, 0.8)
	ear_inner_mat.roughness = 0.8

	beak_mat = StandardMaterial3D.new()
	beak_mat.albedo_color = Color(1.0, 0.6, 0.0) # Bright yellow-orange
	beak_mat.roughness = 0.3

	gold_mat = StandardMaterial3D.new()
	gold_mat.albedo_color = Color(1.0, 0.84, 0.0)
	gold_mat.metallic = 0.95
	gold_mat.roughness = 0.15

	body_root = Node3D.new()
	body_root.name = "BodyRoot"
	add_child(body_root)

	# --- 1. CHUBBY TORSO ---
	torso_node = Node3D.new()
	torso_node.name = "Torso"
	torso_node.position = Vector3(0, 0.75, 0)
	body_root.add_child(torso_node)

	# Chubby rounded pill body
	var body_sphere := SphereMesh.new()
	body_sphere.radius = 0.42
	body_sphere.height = 0.78
	var torso_mi := MeshInstance3D.new()
	torso_mi.mesh = body_sphere
	torso_mi.material_override = fur_mat
	torso_node.add_child(torso_mi)

	# Soft chubby tummy patch (front belly)
	var belly_mesh := SphereMesh.new()
	belly_mesh.radius = 0.33
	belly_mesh.height = 0.58
	belly_mesh_node = MeshInstance3D.new()
	belly_mesh_node.mesh = belly_mesh
	belly_mesh_node.material_override = belly_mat
	belly_mesh_node.position = Vector3(0, -0.06, -0.16)
	belly_mesh_node.scale = Vector3(1.0, 1.0, 0.65)
	torso_node.add_child(belly_mesh_node)

	# Fluffy round puffball tail
	tail_node = Node3D.new()
	tail_node.name = "Tail"
	tail_node.position = Vector3(0, -0.18, 0.36)
	var tail_mesh := SphereMesh.new()
	tail_mesh.radius = 0.13
	tail_mesh.height = 0.24
	var tail_mi := MeshInstance3D.new()
	tail_mi.mesh = tail_mesh
	tail_mi.material_override = fur_mat
	tail_node.add_child(tail_mi)
	torso_node.add_child(tail_node)

	# --- 2. BIG ADORABLE HEAD ---
	head_node = Node3D.new()
	head_node.name = "Head"
	head_node.position = Vector3(0, 0.46, 0)
	torso_node.add_child(head_node)

	var head_mesh := SphereMesh.new()
	head_mesh.radius = 0.38
	head_mesh.height = 0.68
	var head_mi := MeshInstance3D.new()
	head_mi.mesh = head_mesh
	head_mi.material_override = fur_mat
	head_node.add_child(head_mi)

	# --- Big Goofy Cartoon Eyes with Sparkle Highlights ---
	for side in [-1.0, 1.0]:
		# Eye white
		var eye := MeshInstance3D.new()
		var eye_mesh := SphereMesh.new()
		eye_mesh.radius = 0.11
		eye_mesh.height = 0.18
		eye.mesh = eye_mesh
		eye.material_override = eye_white_mat
		eye.position = Vector3(side * 0.13, 0.07, -0.31)
		head_node.add_child(eye)

		# Pupil
		var pupil := MeshInstance3D.new()
		var pupil_mesh := SphereMesh.new()
		pupil_mesh.radius = 0.055
		pupil_mesh.height = 0.09
		pupil.mesh = pupil_mesh
		pupil.material_override = pupil_mat
		pupil.position = Vector3(side * 0.13, 0.07, -0.385)
		head_node.add_child(pupil)

		# Sparkle twinkle gloss dot
		var twinkle := MeshInstance3D.new()
		var twinkle_mesh := SphereMesh.new()
		twinkle_mesh.radius = 0.024
		twinkle_mesh.height = 0.035
		twinkle.mesh = twinkle_mesh
		twinkle.material_override = twinkle_mat
		twinkle.position = Vector3(side * 0.11 + 0.015, 0.095, -0.42)
		head_node.add_child(twinkle)

	# --- Rosy Chubby Cheeks ---
	blush_left = _create_blush_cheek(Vector3(-0.24, -0.06, -0.28))
	blush_right = _create_blush_cheek(Vector3(0.24, -0.06, -0.28))
	head_node.add_child(blush_left)
	head_node.add_child(blush_right)

	# --- Cute Round Fluffy Bear / Animal Ears ---
	left_ear = _create_ear(-1.0)
	right_ear = _create_ear(1.0)
	head_node.add_child(left_ear)
	head_node.add_child(right_ear)

	# --- Snout (for Teddy / Dino) ---
	snout_node = Node3D.new()
	snout_node.position = Vector3(0, -0.05, -0.36)
	var snout_mesh := SphereMesh.new()
	snout_mesh.radius = 0.11
	snout_mesh.height = 0.14
	var snout_mi := MeshInstance3D.new()
	snout_mi.mesh = snout_mesh
	snout_mi.material_override = belly_mat
	snout_node.add_child(snout_mi)

	# Little black nose button on snout
	var nose_mi := MeshInstance3D.new()
	var nose_mesh := SphereMesh.new()
	nose_mesh.radius = 0.04
	nose_mesh.height = 0.05
	nose_mi.mesh = nose_mesh
	nose_mi.material_override = pupil_mat
	nose_mi.position = Vector3(0, 0.03, -0.09)
	snout_node.add_child(nose_mi)
	head_node.add_child(snout_node)

	# --- Funny Beak (for Penguin / Duck) ---
	beak_node = Node3D.new()
	beak_node.position = Vector3(0, -0.03, -0.36)
	var beak_mesh := PrismMesh.new()
	beak_mesh.size = Vector3(0.18, 0.14, 0.22)
	var beak_mi := MeshInstance3D.new()
	beak_mi.mesh = beak_mesh
	beak_mi.material_override = beak_mat
	beak_mi.rotation.x = deg_to_rad(-90)
	beak_node.add_child(beak_mi)
	head_node.add_child(beak_node)
	beak_node.visible = false

	# --- 3. CHUBBY ARMS & PAWS ---
	left_arm = _create_arm(-1.0)
	right_arm = _create_arm(1.0)
	torso_node.add_child(left_arm)
	torso_node.add_child(right_arm)

	# --- 4. CHUBBY LEGS & ROUND SNEAKERS ---
	left_leg = _create_leg(-1.0)
	right_leg = _create_leg(1.0)
	torso_node.add_child(left_leg)
	torso_node.add_child(right_leg)

	# --- 5. HILARIOUS ACCESSORIES ---
	_build_accessories()

func _create_ear(side: float) -> Node3D:
	var ear_root := Node3D.new()
	ear_root.position = Vector3(side * 0.28, 0.32, 0.02)

	# Outer fluffy ear
	var outer_mesh := SphereMesh.new()
	outer_mesh.radius = 0.12
	outer_mesh.height = 0.18
	var outer_mi := MeshInstance3D.new()
	outer_mi.mesh = outer_mesh
	outer_mi.material_override = fur_mat
	outer_mi.scale = Vector3(1.0, 1.0, 0.6)
	ear_root.add_child(outer_mi)

	# Inner ear color
	var inner_mesh := SphereMesh.new()
	inner_mesh.radius = 0.075
	inner_mesh.height = 0.11
	var inner_mi := MeshInstance3D.new()
	inner_mi.mesh = inner_mesh
	inner_mi.material_override = ear_inner_mat
	inner_mi.position = Vector3(0, 0, -0.045)
	inner_mi.scale = Vector3(1.0, 1.0, 0.5)
	ear_root.add_child(inner_mi)

	return ear_root

func _create_blush_cheek(pos: Vector3) -> Node3D:
	var cheek := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = 0.065
	mesh.height = 0.06
	cheek.mesh = mesh
	cheek.material_override = blush_mat
	cheek.position = pos
	cheek.scale = Vector3(1.0, 0.7, 0.4)
	return cheek

func _create_arm(side: float) -> Node3D:
	var arm_root := Node3D.new()
	arm_root.position = Vector3(side * 0.42, 0.12, 0.0)

	var arm_mesh := CapsuleMesh.new()
	arm_mesh.radius = 0.10
	arm_mesh.height = 0.38
	var arm_mi := MeshInstance3D.new()
	arm_mi.mesh = arm_mesh
	arm_mi.material_override = fur_mat
	arm_mi.position = Vector3(0, -0.16, 0)
	arm_root.add_child(arm_mi)

	# Little round mitten / paw hand
	var paw_mesh := SphereMesh.new()
	paw_mesh.radius = 0.095
	paw_mesh.height = 0.15
	var paw_mi := MeshInstance3D.new()
	paw_mi.mesh = paw_mesh
	paw_mi.material_override = belly_mat
	paw_mi.position = Vector3(0, -0.32, 0)
	arm_root.add_child(paw_mi)

	return arm_root

func _create_leg(side: float) -> Node3D:
	var leg_root := Node3D.new()
	leg_root.position = Vector3(side * 0.20, -0.32, 0.0)

	var leg_mesh := CapsuleMesh.new()
	leg_mesh.radius = 0.12
	leg_mesh.height = 0.34
	var leg_mi := MeshInstance3D.new()
	leg_mi.mesh = leg_mesh
	leg_mi.material_override = pants_mat
	leg_mi.position = Vector3(0, -0.12, 0)
	leg_root.add_child(leg_mi)

	# Round chubby sneaker
	var shoe_mesh := BoxMesh.new()
	shoe_mesh.size = Vector3(0.24, 0.15, 0.32)
	var shoe_mi := MeshInstance3D.new()
	shoe_mi.mesh = shoe_mesh
	shoe_mi.material_override = shoe_mat
	shoe_mi.position = Vector3(0, -0.28, -0.06)
	leg_root.add_child(shoe_mi)

	return leg_root

func _build_accessories() -> void:
	# 1. Wobbly Royal Crown
	crown = Node3D.new()
	crown.position = Vector3(0.04, 0.42, 0.02)
	crown.rotation.z = deg_to_rad(12) # Comically tilted!

	var crown_mesh := CylinderMesh.new()
	crown_mesh.top_radius = 0.28
	crown_mesh.bottom_radius = 0.22
	crown_mesh.height = 0.22
	var crown_mi := MeshInstance3D.new()
	crown_mi.mesh = crown_mesh
	crown_mi.material_override = gold_mat
	crown.add_child(crown_mi)

	# Crown jewels (Ruby, Emerald, Sapphire dots)
	var jewel_colors = [Color(1.0, 0.1, 0.2), Color(0.1, 0.9, 0.3), Color(0.1, 0.6, 1.0)]
	for i in range(3):
		var j_mat := StandardMaterial3D.new()
		j_mat.albedo_color = jewel_colors[i]
		j_mat.emission_enabled = true
		j_mat.emission = jewel_colors[i]
		j_mat.emission_energy_multiplier = 0.8
		var j_mesh := SphereMesh.new()
		j_mesh.radius = 0.04
		j_mesh.height = 0.06
		var j_mi := MeshInstance3D.new()
		j_mi.mesh = j_mesh
		j_mi.material_override = j_mat
		var angle = (i * 2.0 * PI / 3.0)
		j_mi.position = Vector3(cos(angle) * 0.25, 0.08, sin(angle) * 0.25)
		crown.add_child(j_mi)

	head_node.add_child(crown)
	crown.visible = false

	# 2. Bubble Astronaut Visor
	space_visor = Node3D.new()
	var visor_mesh := SphereMesh.new()
	visor_mesh.radius = 0.44
	visor_mesh.height = 0.50
	var visor_mat := StandardMaterial3D.new()
	visor_mat.albedo_color = Color(0.9, 0.95, 1.0, 0.6)
	visor_mat.roughness = 0.05
	visor_mat.metallic = 0.8
	visor_mat.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	var v_mi := MeshInstance3D.new()
	v_mi.mesh = visor_mesh
	v_mi.material_override = visor_mat
	v_mi.position = Vector3(0, 0.04, -0.06)
	space_visor.add_child(v_mi)
	head_node.add_child(space_visor)
	space_visor.visible = false

	# 3. Chubby Dino Spikes
	dino_spikes = Node3D.new()
	for i in range(4):
		var spike_mesh := PrismMesh.new()
		spike_mesh.size = Vector3(0.14, 0.20, 0.20)
		var spike_mat := StandardMaterial3D.new()
		spike_mat.albedo_color = Color(0.95, 0.85, 0.2) # Yellow dino crest
		var s_mi := MeshInstance3D.new()
		s_mi.mesh = spike_mesh
		s_mi.material_override = spike_mat
		s_mi.position = Vector3(0, 0.26 - (i * 0.20), 0.36)
		s_mi.rotation.x = deg_to_rad(-45)
		dino_spikes.add_child(s_mi)
	torso_node.add_child(dino_spikes)
	dino_spikes.visible = false

	# 4. Penguin Bowtie
	penguin_bowtie = Node3D.new()
	penguin_bowtie.position = Vector3(0, 0.32, -0.28)
	var bow_mesh := BoxMesh.new()
	bow_mesh.size = Vector3(0.18, 0.09, 0.08)
	var bow_mat := StandardMaterial3D.new()
	bow_mat.albedo_color = Color(1.0, 0.2, 0.3)
	var b_mi := MeshInstance3D.new()
	b_mi.mesh = bow_mesh
	b_mi.material_override = bow_mat
	penguin_bowtie.add_child(b_mi)
	torso_node.add_child(penguin_bowtie)
	penguin_bowtie.visible = false

func apply_skin(skin: int) -> void:
	current_skin = skin as SkinType

	# Reset accessory visibility
	if crown: crown.visible = false
	if space_visor: space_visor.visible = false
	if dino_spikes: dino_spikes.visible = false
	if penguin_bowtie: penguin_bowtie.visible = false
	if beak_node: beak_node.visible = false
	if snout_node: snout_node.visible = true
	if left_ear: left_ear.visible = true
	if right_ear: right_ear.visible = true

	match current_skin:
		SkinType.FLUFFY_TEDDY:
			fur_mat.albedo_color = Color(0.76, 0.52, 0.34) # Soft caramel teddy
			belly_mat.albedo_color = Color(0.96, 0.88, 0.74) # Cream tummy
			pants_mat.albedo_color = Color(0.24, 0.48, 0.82) # Blue jeans
			shoe_mat.albedo_color = Color(0.95, 0.95, 0.95)
			ear_inner_mat.albedo_color = Color(0.92, 0.72, 0.75)

		SkinType.GOOFY_PENGUIN:
			fur_mat.albedo_color = Color(0.14, 0.16, 0.22) # Tuxedo black
			belly_mat.albedo_color = Color(0.98, 0.98, 1.0) # White belly
			pants_mat.albedo_color = Color(0.14, 0.16, 0.22)
			shoe_mat.albedo_color = Color(1.0, 0.55, 0.0) # Orange flipper feet
			if beak_node: beak_node.visible = true
			if snout_node: snout_node.visible = false
			if left_ear: left_ear.visible = false
			if right_ear: right_ear.visible = false
			if penguin_bowtie: penguin_bowtie.visible = true

		SkinType.CHUBBY_DINO:
			fur_mat.albedo_color = Color(0.38, 0.82, 0.38) # Cute lime dino
			belly_mat.albedo_color = Color(0.85, 0.95, 0.55) # Pastel lime belly
			pants_mat.albedo_color = Color(0.28, 0.70, 0.30)
			shoe_mat.albedo_color = Color(0.22, 0.55, 0.24)
			ear_inner_mat.albedo_color = Color(0.85, 0.95, 0.55)
			if dino_spikes: dino_spikes.visible = true

		SkinType.KING_FLUFF:
			fur_mat.albedo_color = Color(0.62, 0.24, 0.86) # Royal velvet purple
			belly_mat.albedo_color = Color(1.0, 0.92, 0.75) # Ermine gold
			pants_mat.albedo_color = Color(0.88, 0.74, 0.16) # Gold trousers
			shoe_mat.albedo_color = Color(0.95, 0.2, 0.3)
			ear_inner_mat.albedo_color = Color(1.0, 0.78, 0.82)
			if crown: crown.visible = true

		SkinType.BOUNCY_COSMO:
			fur_mat.albedo_color = Color(0.95, 0.95, 0.98) # Bubble astronaut suit
			belly_mat.albedo_color = Color(0.3, 0.75, 0.95) # Cyan display badge
			pants_mat.albedo_color = Color(0.9, 0.9, 0.95)
			shoe_mat.albedo_color = Color(0.2, 0.7, 0.9)
			ear_inner_mat.albedo_color = Color(0.2, 0.7, 0.9)
			if space_visor: space_visor.visible = true

		SkinType.CANDY_BEAN:
			fur_mat.albedo_color = Color(1.0, 0.42, 0.58) # Strawberry bubblegum
			belly_mat.albedo_color = Color(1.0, 0.85, 0.9)
			pants_mat.albedo_color = Color(0.25, 0.85, 0.8) # Mint turquoise
			shoe_mat.albedo_color = Color(1.0, 0.95, 0.4) # Lemon sneakers
			ear_inner_mat.albedo_color = Color(1.0, 0.8, 0.85)

func update_animation(delta: float, is_moving: bool, is_on_floor: bool, is_diving: bool, is_stumbled: bool) -> void:
	if not torso_node or not left_leg or not right_leg or not left_arm or not right_arm:
		return

	# --- 1. SUPERMAN BELLY-FLOP DIVE ---
	if is_diving:
		anim_time += delta * 18.0
		torso_node.rotation.x = deg_to_rad(-85)
		torso_node.rotation.z = 0.0
		torso_node.position.y = 0.32
		
		# Arms reaching straight forward
		left_arm.rotation.x = deg_to_rad(-165)
		right_arm.rotation.x = deg_to_rad(-165)
		left_arm.rotation.z = deg_to_rad(-12)
		right_arm.rotation.z = deg_to_rad(12)

		# Feet fluttering back
		left_leg.rotation.x = deg_to_rad(20) + sin(anim_time) * 0.3
		right_leg.rotation.x = deg_to_rad(20) - sin(anim_time) * 0.3
		
		# Belly squish
		torso_node.scale = Vector3(1.15, 0.85, 1.1)
		return

	# --- 2. HILARIOUS GOOFY STUMBLE RAGDOLL ---
	if is_stumbled:
		anim_time += delta * 24.0
		torso_node.rotation.x = deg_to_rad(-85)
		torso_node.rotation.y += delta * 12.0
		torso_node.position.y = 0.28
		
		# Windmilling limbs
		left_arm.rotation.x = sin(anim_time) * 2.2
		right_arm.rotation.x = -sin(anim_time) * 2.2
		left_leg.rotation.x = cos(anim_time) * 1.5
		right_leg.rotation.x = -cos(anim_time) * 1.5
		
		if crown and crown.visible:
			crown.rotation.x = sin(anim_time * 1.5) * 0.8
		return

	# Reset torso pose
	torso_node.rotation.x = 0.0
	torso_node.rotation.y = 0.0
	torso_node.position.y = 0.75

	# --- 3. IN-AIR / JUMPING FLAP PANIC ---
	if not is_on_floor:
		anim_time += delta * 26.0
		# Arms flap wildly like funny frantic wings!
		var flap := sin(anim_time) * 1.25
		left_arm.rotation.x = deg_to_rad(-60)
		right_arm.rotation.x = deg_to_rad(-60)
		left_arm.rotation.z = deg_to_rad(-45) + flap * 0.6
		right_arm.rotation.z = deg_to_rad(45) - flap * 0.6

		# Pedaling legs
		left_leg.rotation.x = sin(anim_time * 0.8) * 0.5
		right_leg.rotation.x = -sin(anim_time * 0.8) * 0.5
		torso_node.scale = Vector3(0.92, 1.12, 0.92) # Stretched vertically
		return

	# --- 4. HILARIOUS WADDLING RUN ---
	if is_moving:
		anim_time += delta * 15.0
		var swing := sin(anim_time) * 0.9
		
		# Exaggerated side-to-side penguin waddle
		torso_node.rotation.z = sin(anim_time) * 0.18
		
		# Belly bouncy squash & stretch
		var bounce: float = absf(sin(anim_time * 2.0))
		torso_node.scale = Vector3(1.0 + bounce * 0.08, 1.0 - bounce * 0.08, 1.0 + bounce * 0.08)
		torso_node.position.y = 0.75 + bounce * 0.06

		# Leg stomps
		left_leg.rotation.x = swing
		right_leg.rotation.x = -swing
		left_leg.rotation.z = 0.0
		right_leg.rotation.z = 0.0

		# Arm paddles & flaps
		left_arm.rotation.x = -swing * 0.95
		right_arm.rotation.x = swing * 0.95
		left_arm.rotation.z = deg_to_rad(-20) - absf(sin(anim_time)) * 0.3
		right_arm.rotation.z = deg_to_rad(20) + absf(sin(anim_time)) * 0.3

		# Head bobbing
		head_node.position.y = 0.46 + bounce * 0.04
		head_node.rotation.z = -torso_node.rotation.z * 0.6

		# Floppy ear wiggle
		if left_ear and right_ear:
			left_ear.rotation.z = sin(anim_time * 2.0) * 0.2
			right_ear.rotation.z = -sin(anim_time * 2.0) * 0.2
			
		# Crown jiggle
		if crown and crown.visible:
			crown.rotation.z = deg_to_rad(12) + sin(anim_time * 2.5) * 0.25

	# --- 5. CUTE SQUISHY IDLE BREATHING ---
	else:
		anim_time += delta * 3.2
		var breath := sin(anim_time + idle_phase)
		
		# Gentle tummy breathing
		torso_node.scale = Vector3(1.0 + breath * 0.035, 1.0 - breath * 0.035, 1.0 + breath * 0.035)
		torso_node.position.y = 0.75 + breath * 0.015
		torso_node.rotation.z = lerp_angle(torso_node.rotation.z, 0.0, 8.0 * delta)

		# Limbs settle
		left_leg.rotation.x = lerp_angle(left_leg.rotation.x, 0.0, 8.0 * delta)
		right_leg.rotation.x = lerp_angle(right_leg.rotation.x, 0.0, 8.0 * delta)
		left_arm.rotation.x = lerp_angle(left_arm.rotation.x, 0.0, 8.0 * delta)
		right_arm.rotation.x = lerp_angle(right_arm.rotation.x, 0.0, 8.0 * delta)
		left_arm.rotation.z = lerp_angle(left_arm.rotation.z, deg_to_rad(-14), 8.0 * delta)
		right_arm.rotation.z = lerp_angle(right_arm.rotation.z, deg_to_rad(14), 8.0 * delta)

		# Curious head tilt
		head_node.rotation.z = sin(anim_time * 0.5) * 0.08
		head_node.position.y = 0.46 + breath * 0.01
