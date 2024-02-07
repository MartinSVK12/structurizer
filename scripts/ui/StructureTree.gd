extends Tree

var root: TreeItem = null
var last_selected_ref: WeakRef = null
var currect_substitution_target: BlockInstance = null

# Called when the node enters the scene tree for the first time.
func _ready():
	hide_root = true
	reload()
	pass # Replace with function body.


func reload():
	get_tree().current_scene.reload_struct_renders()
	clear()
	root = create_item()
	for struct in Main.structures:
		var item = create_item(root)
		item.set_text(0,struct.name)
		item.set_metadata(0,struct)
		if not struct.has_origin():
			var warning = create_item(item)
			warning.set_custom_bg_color(0,Color.DARK_RED)
			warning.set_text(0,"No origin defined!")
			warning.set_selectable(0,false)
			continue
		else:
			var origin = create_item(item)
			origin.set_custom_bg_color(0,Color.DARK_BLUE)
			origin.set_text(0,"Origin: "+str(struct.origin))
			origin.set_metadata(0,struct.origin)
			origin.set_selectable(0,false)
		var b = create_item(item)
		b.set_text(0,"Blocks")
		b.set_selectable(0,false)
		if struct.blocks.is_empty():
			var bl = create_item(b)
			bl.set_text(0,"No blocks.")
			bl.set_selectable(0,false)
		else:
			for block in struct.blocks:
				var bl = create_item(b)
				bl.set_text(0,str(block))
				bl.set_metadata(0,block)
		var s = create_item(item)
		s.set_text(0,"Substitutions")
		s.set_selectable(0,false)
		if struct.substitutions.is_empty():
			var bl = create_item(s)
			bl.set_text(0,"No substitutions.")
			bl.set_selectable(0,false)
		else:
			for block in struct.substitutions:
				var bl = create_item(s)
				bl.set_text(0,str(block))
				bl.set_metadata(0,block)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	$"../Options/AddSub".text = "Create Substitution" if currect_substitution_target == null else "Add Substitution"
	if get_selected() == null:
		$"../Options/DeleteStruct".disabled = true
		$"../Options/SetOrigin".disabled = true
		$"../Options/SetOrigin".visible = false
		$"../Options/AddBlock".disabled = true
		$"../Options/AddBlock".visible = false
		$"../Options/AddSub".disabled = true
		$"../Options/AddSub".visible = false
	else:
		$"../Options/DeleteStruct".disabled = false
		$"../Options/SetOrigin".disabled = false
		$"../Options/SetOrigin".visible = true
		$"../Options/AddBlock".disabled = false
		$"../Options/AddBlock".visible = true
		$"../Options/AddSub".disabled = false
		$"../Options/AddSub".visible = true
	pass


func _on_add_struct_pressed():
	var structName: String = $"../Options/NewStruct/StructName".text
	if structName != "":
		var struct = Structure._new(structName)
		Main.structures.append(struct)
		reload()
		
func is_struct_selected():
	return is_instance_valid(get_selected()) and get_selected().get_metadata(0) is Structure


func _on_delete_struct_pressed():
	if is_instance_valid(get_selected()):
		var obj = get_selected().get_metadata(0)
		if obj is Structure:
			Main.structures.erase(obj)
		elif obj is BlockInstance:
			var struct: Structure = get_selected().get_parent().get_parent().get_metadata(0)
			if get_selected().get_parent().get_text(0) == "Blocks":
				struct.blocks.erase(obj)
			elif get_selected().get_parent().get_text(0) == "Substitutions":
				struct.substitutions.erase(obj)
		reload()


func _on_set_origin_pressed():
	if is_struct_selected():
		var struct: Structure = get_selected().get_metadata(0)
		var hit = %Player.get_pointed_voxel()
		var v = %Player.voxel_world_tool
		var meta = v.get_voxel_metadata(hit.position)
		struct.set_origin(BlockInstance._new(hit.position,meta["id"],meta["rot"]))
		reload()


func _on_add_block_pressed():
	if is_struct_selected():
		var struct: Structure = get_selected().get_metadata(0)
		var hit = %Player.get_pointed_voxel()
		var v = %Player.voxel_world_tool
		var meta = v.get_voxel_metadata(hit.position)
		struct.add_block(meta["id"],hit.position,meta["rot"])
		reload()


func _on_item_selected():
	if is_struct_selected():
		last_selected_ref = weakref(get_selected().get_metadata(0))


func _on_add_sub_pressed():
	if is_struct_selected():
		var struct: Structure = get_selected().get_metadata(0)
		var hit = %Player.get_pointed_voxel()
		var v = %Player.voxel_world_tool
		var meta = v.get_voxel_metadata(hit.position)
		if currect_substitution_target == null:
			currect_substitution_target = BlockInstance._new(hit.position,meta["id"],meta["rot"])
		else:
			struct.add_substitution(meta["id"],currect_substitution_target.position,meta["rot"])
			currect_substitution_target = null
		reload()


func _on_pos_1_pressed():
	get_tree().current_scene.reload_struct_renders()
	var hit = %Player.get_pointed_voxel()
	if hit.position == Main.pos1:
		Main.pos1 = null
	else:
		Main.pos1 = hit.position
	get_tree().current_scene.reload_struct_renders()


func _on_pos_2_pressed():
	get_tree().current_scene.reload_struct_renders()
	var hit = %Player.get_pointed_voxel()
	if hit.position == Main.pos2:
		Main.pos2 = null
	else:
		Main.pos2 = hit.position
	get_tree().current_scene.reload_struct_renders()
