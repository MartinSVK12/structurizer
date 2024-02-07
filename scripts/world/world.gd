extends Node3D

@onready var voxel_world = $VoxelTerrain
var voxel_world_tool: VoxelTool = null

# Called when the node enters the scene tree for the first time.
func _ready():
	reload_struct_renders()
	voxel_world_tool = voxel_world.get_voxel_tool()
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Main.show_subs and $SubstitutionSwapTimer.is_stopped():
		$SubstitutionSwapTimer.start()
	elif not Main.show_subs and not $SubstitutionSwapTimer.is_stopped():
		$SubstitutionSwapTimer.stop()
		for struct in Main.structures:
			if(struct.has_origin()):
				for block in struct.blocks:
					voxel_world_tool.value = 2+(6*block.id)+block.rotation
					voxel_world_tool.do_point(struct.origin.position + block.position)
	pass

func place_struct(struct: Structure):
	if(struct.has_origin()):
		var origin = struct.origin
		voxel_world_tool.value = 2+(6*origin.id)+origin.rotation
		voxel_world_tool.do_point(origin.position)
		for block in struct.blocks:
			voxel_world_tool.value = 2+(6*block.id)+block.rotation
			voxel_world_tool.do_point(struct.origin.position + block.position)

func _on_substitution_swap_timer_timeout():
	for struct in Main.structures:
		if(struct.has_origin()):
			for block in struct.blocks:
				var subs = struct.get_all_substitutions(block.position)
				subs.append(block)
				var current_sub = subs.pick_random()
				var id = voxel_world_tool.get_voxel(struct.origin.position + block.position)
				voxel_world_tool.value = 2+(6*current_sub.id)+current_sub.rotation
				voxel_world_tool.do_point(struct.origin.position + block.position)

func reload_struct_renders():
	for child in %Structures.get_children():
		child.queue_free()
	var sub: BlockInstance = %StructureTree.currect_substitution_target
	if sub != null:
		var area = MeshInstance3D.new()
		area.mesh = BoxMesh.new()
		var material = ShaderMaterial.new()
		material.shader = load("res://outline.gdshader")
		material.set_shader_parameter("color",Color.YELLOW)
		material.set_shader_parameter("width",0.05)
		material.set_shader_parameter("scale",Vector3(1.05,1.05,1.05))
		area.mesh.surface_set_material(0,material)
		area.position = sub.position
		%Structures.add_child(area)
	if Main.pos1 != null:
		var root = MeshInstance3D.new()
		root.name = "Position 1"
		root.mesh = BoxMesh.new()
		var material = ShaderMaterial.new()
		material.shader = load("res://outline.gdshader")
		material.set_shader_parameter("color",Color.BLUE)
		material.set_shader_parameter("width",0.05)
		material.set_shader_parameter("scale",Vector3(1.05,1.05,1.05))
		root.mesh.surface_set_material(0,material)
		%Structures.add_child(root)
		root.global_position = Main.pos1
	if Main.pos2 != null:
		var root = MeshInstance3D.new()
		root.name = "Position 2"
		root.mesh = BoxMesh.new()
		var material = ShaderMaterial.new()
		material.shader = load("res://outline.gdshader")
		material.set_shader_parameter("color",Color.DEEP_PINK)
		material.set_shader_parameter("width",0.05)
		material.set_shader_parameter("scale",Vector3(1.05,1.05,1.05))
		root.mesh.surface_set_material(0,material)
		%Structures.add_child(root)
		root.global_position = Main.pos2
	for struct in Main.structures:
		if struct.has_origin():
			var root = Node3D.new()
			root.name = struct.name
			%Structures.add_child(root)
#			root.global_position = struct.origin.position
			var origin = MeshInstance3D.new()
			origin.mesh = load("res://assets/outline_mesh.tres")
			origin.mesh.surface_get_material(0).set("shader_parameter/color",Color.DARK_BLUE)
			origin.name = "origin"
			root.add_child(origin)
			origin.global_position = struct.origin.position
			var text = Label3D.new()
			text.billboard = BaseMaterial3D.BILLBOARD_ENABLED
			text.text = struct.name
			origin.add_child(text)
			text.position = Vector3.UP
			for block in struct.blocks:
				var area = MeshInstance3D.new()
				area.mesh = BoxMesh.new()
				area.sorting_offset = 10
				var material = ShaderMaterial.new()
				material.shader = load("res://outline.gdshader")
				material.set_shader_parameter("color",Color.WHITE)
				material.set_shader_parameter("width",0.02)
				material.set_shader_parameter("scale",Vector3(1.05,1.05,1.05))
				area.mesh.surface_set_material(0,material)
				area.position = block.position
				origin.add_child(area)

