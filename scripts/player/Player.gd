extends CharacterBody3D
class_name Player


@export var SPEED := 15.0
@export var JUMP_VELOCITY := 4.5
static var g = GridMap.new()

@warning_ignore("unused_private_class_variable")
var _mouse_motion = Vector2()
var paused = true
var fly = true

@onready var head = $Head
@onready var raycast = $Head/RayCast3D
@onready var voxel_world = $"../VoxelTerrain"
@onready var camera = $Camera2D

var ray_position = Vector3.ZERO
var ray_normal = Vector3.ZERO

var placementPreview: bool = true

var hotbar = [0,0,0,0,0,0,0,0,0,0]
var selected_block = 0
var selected_rotation = 0

var voxel_world_tool: VoxelTool = null
@warning_ignore("unused_private_class_variable")
var _cursor = null
@export var cursor_material: Material = null

# Get the gravity from the project settings to be synced with RigidDynamicBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	voxel_world_tool = voxel_world.get_voxel_tool()
	pass

@warning_ignore("unused_parameter")
func _process(delta):
	DD.set_text("Position",str(Vector3i(transform.origin)))
	DD.set_text("Selected Block",selected_block)
	DD.set_text("Selected Rotation",selected_rotation)
	DD.set_text("Flying",fly)
	DD.set_text("Nocliping",!get_collision_mask_value(1))
	if is_instance_valid(%StructureTree.last_selected_ref):
		DD.set_text("Selected Structure",%StructureTree.last_selected_ref.get_ref())
	else:
		DD.set_text("Selected Structure",null)
	var hit = get_pointed_voxel()
	%SelectedBlock.texture = Main.load_texture_external("res://assets/icons/"+str(selected_block)+".png")
	if hit != null and placementPreview and g != null:
		%OutlineMesh.show()
		%BlockPreviewMesh.show()
		var id = 2+(6*selected_block)+selected_rotation
		var b: Basis = g.get_basis_with_orthogonal_index(Main.library.get_model(id).get_mesh_ortho_rotation_index())
		%BlockPreviewMesh.mesh = Main.get_block_mesh(selected_block,-Vector3(0.5,0.5,0.5))
		%BlockPreviewMesh.quaternion = b.get_rotation_quaternion().inverse()
		%BlockPreviewMesh.material_override = Main.atlasMaterial
		%BlockPreviewMesh.transparency = 0.2
		%BlockPreviewMesh.global_position = hit.previous_position
		%OutlineMesh.global_position = hit.position
	else:
		%BlockPreviewMesh.hide()
		%BlockPreviewMesh.mesh = null
		%OutlineMesh.hide()

	var selected = hotbar.find(selected_block)
	for bar in hotbar.size():
		if bar == selected:
			%Hotbar.get_child(bar-1).color = Color.GRAY
		else:
			%Hotbar.get_child(bar-1).color = Color.DIM_GRAY
		%Hotbar.get_child(bar-1).get_node("TextureRect").texture = Main.load_texture_external("res://assets/icons/"+str(%Player.hotbar[bar])+".png")

func interact_with_world(hit):
	var breaking = Input.is_action_just_pressed("destroy")
	var placing = Input.is_action_just_pressed("build")
	@warning_ignore("unused_variable")
	var interacting = Input.is_action_just_pressed("interact")
	# Block interaction when game is paused
	if paused:
		return
#
	if breaking:
		if hit != null:
			var block = voxel_world_tool.get_voxel(hit.position)
			var has_cube = block > 1 
#
			if has_cube:
				var pos = hit.position
				_place_single_voxel(pos, -1,0)
				if Main.auto_add:
					var struct: Structure = %StructureTree.last_selected_ref.get_ref()
					if struct != null:
						struct.remove_block(pos)
				%StructureTree.reload()
	elif placing and selected_block != -1:
		if hit != null:
			var block = voxel_world_tool.get_voxel(hit.position)
			var has_cube = block != 0
#
			if has_cube:
				var pos = hit.previous_position
				_place_single_voxel(pos,selected_block,selected_rotation)
				if Main.auto_add:
					var struct: Structure = %StructureTree.last_selected_ref.get_ref()
					if struct != null:
						struct.add_block(selected_block,pos,selected_rotation)
				%StructureTree.reload()
	
func _place_single_voxel(pos: Vector3, id: int, rot: int):
	if id == -1:
		voxel_world_tool.value = 0
		voxel_world_tool.do_point(pos)
		return
	var internal_id = 2+(6*selected_block)+selected_rotation
	voxel_world_tool.value = internal_id
	voxel_world_tool.do_point(pos)
	voxel_world_tool.set_voxel_metadata(pos,{"id":id,"rot":rot})
#
func _input(event):
	if event is InputEventKey and event.pressed:
		if event.keycode >= 48 and event.keycode <=57:
			selected_block = hotbar[event.keycode-(KEY_9+1)]

@warning_ignore("unused_parameter")
func _unhandled_key_input(event):
	if Input.is_action_just_pressed("pause"):
		pause()
	if Input.is_action_just_pressed("showPlacementPreview"):
		placementPreview = !placementPreview
	if Input.is_action_just_pressed("rotate"):
		selected_rotation = wrapi(selected_rotation + 1,0,6)
	if Input.is_action_just_pressed("fly"):
		fly = !fly
	if Input.is_action_just_pressed("noclip"):
		set_collision_mask_value(1,!get_collision_mask_value(1))
	if Input.is_action_just_pressed("reset_pos"):
		position = Vector3(0,30,0)
	if Input.is_action_just_pressed("inventory"):
		get_tree().call_group("Inventory","show")
		if paused:
			get_tree().call_group("Inventory","hide")
		pause(false)
	if Input.is_action_just_pressed("perspective"):
		if get_node("Camera2D").position == Vector3(0,0,0.15):
			get_node("Camera2D").position = Vector3(0,0.5,2.65)
			get_node("Camera2D").set_cull_mask_value(2,true)
			get_node("HoldingBlock").set_scale(Vector3(0.4,0.4,0.4))
		else:
			get_node("Camera2D").position = Vector3(0,0,0.15)
			get_node("Camera2D").set_cull_mask_value(2,false)
			get_node("HoldingBlock").set_scale(Vector3(0.5,0.5,0.5))

func pause(screen=true):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		get_tree().call_group("PauseUI","show")
		paused = true
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		paused = false
		get_tree().call_group("PauseUI","hide")
		%BlockList.release_focus()

func get_pointed_voxel():
	var origin = camera.global_position
	var forward = -camera.get_transform().basis.z.normalized()
	var hit = voxel_world_tool.raycast(origin, forward, 10)
	return hit

func _physics_process(delta):
	if voxel_world_tool == null:
		return
	
	var hit = get_pointed_voxel()
	interact_with_world(hit)
	if hit != null:
#		_cursor.show()
#		_cursor.set_position(hit.position)
		DD.set_text("Pointed voxel", str(hit.position)+" | "+str(voxel_world_tool.get_voxel(hit.position)))
	else:
#		_cursor.hide()
		DD.set_text("Pointed voxel", "---")
	
	# Add the gravity.
	if not is_on_floor() and not fly:
		velocity.y -= gravity * delta

	if not paused:
		if Input.get_vector("shift_left","shift_right","shift_forward","shift_backward").is_zero_approx() and is_zero_approx(Input.get_axis("shift_up","shift_down")):
			# Handle Jump.
			if Input.is_action_just_pressed("ui_accept") and is_on_floor():
				velocity.y = JUMP_VELOCITY
			if Input.is_action_just_pressed("ui_accept") and fly:
				velocity.y = JUMP_VELOCITY*2
			if Input.is_action_just_pressed("fly_down") and fly:
				velocity.y = -JUMP_VELOCITY*2
			if (Input.is_action_just_released("ui_accept") or Input.is_action_just_released("fly_down")) and fly:
				velocity.y = 0
			# Get the input direction and handle the movement/deceleration.
			# As good practice, you should replace UI actions with custom gameplay actions.
			var input_dir = Input.get_vector("left", "right", "up", "down")
			var direction = (camera.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
			if direction:
				velocity.x = direction.x * SPEED
				velocity.z = direction.z * SPEED
			else:
				velocity.x = move_toward(velocity.x, 0, SPEED)
				velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	
func save():
	pass
