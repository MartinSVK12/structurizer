extends HBoxContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if %StructureTree.last_selected_ref != null && %StructureTree.last_selected_ref.get_ref() != null:
		if %StructureTree.last_selected_ref.get_ref().has_origin():
			$AutoAdd.show()
			$Place.show()
			$Save.show()
	else:
		$AutoAdd.hide()
		$Place.hide()
		$Save.hide()


func _on_structures_pressed():
	%Structs.visible = !%Structs.visible


func _on_clear_pressed():
	Main.structures.clear()
	%StructureTree.reload()
	for child in %Structures.get_children():
		child.queue_free()
	Main.pos1 = null
	Main.pos2 = null
	Main.clipboard = []


func _on_refresh_pressed():
	%StructureTree.reload()
	get_tree().current_scene.reload_struct_renders()


func _on_auto_add_toggled(button_pressed):
	Main.auto_add = button_pressed


func _on_show_substitutions_toggled(button_pressed):
	Main.show_subs = button_pressed


func _on_place_pressed():
	if %StructureTree.last_selected_ref != null && %StructureTree.last_selected_ref.get_ref() != null:
		if %StructureTree.last_selected_ref.get_ref().has_origin():
			get_tree().current_scene.place_struct(%StructureTree.last_selected_ref.get_ref())


func _on_ignore_rotation_toggled(button_pressed):
	Main.ignore_rotation = button_pressed


func _on_save_pressed():
	%FileDialog.popup_centered_ratio(0.5)
	%FileDialog.file_mode = FileDialog.FILE_MODE_SAVE_FILE
	pass # Replace with function body.


func _on_load_pressed():
	%FileDialog.popup_centered_ratio(0.5)
	%FileDialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE
	pass # Replace with function body.


func _on_file_dialog_file_selected(path):
	if %FileDialog.file_mode == FileDialog.FILE_MODE_SAVE_FILE:
		if %StructureTree.last_selected_ref != null && %StructureTree.last_selected_ref.get_ref() != null:
			if %StructureTree.last_selected_ref.get_ref().has_origin():
				var struct: Structure = %StructureTree.last_selected_ref.get_ref()
				var struct_tag = CompoundTag.new()
				var origin = CompoundTag.new()
				var blocks = CompoundTag.new()
				var subs = CompoundTag.new()
				var tes = CompoundTag.new()
				origin.name = "Origin"
				blocks.name = "Blocks"
				subs.name = "Substitutions"
				tes.name = "TileEntities"
				origin.add_int("meta",-1 if struct.origin.ignore_rotation else Main.MINECRAFT_SIDES[struct.origin.rotation])
				origin.add_string("id",Main.blockInfo[struct.origin.id]["mod"]+":"+Main.blockInfo[struct.origin.id]["name"])
				origin.add_bool("tile",Main.blockInfo[struct.origin.id]["tile_entity"])
				origin.add_vector_3i("pos",Vector3.ZERO)
				struct_tag.addTag(origin)
				var i = 0
				for block in struct.blocks:
					var tag = CompoundTag.new()
					tag.name = str(i)
					tag.add_int("meta",-1 if block.ignore_rotation else Main.MINECRAFT_SIDES[block.rotation])
					tag.add_string("id",Main.blockInfo[block.id]["mod"]+":"+Main.blockInfo[block.id]["name"])
					tag.add_bool("tile",Main.blockInfo[block.id]["tile_entity"])
					tag.add_vector_3i("pos",block.position)
					blocks.addTag(tag)
					i+=1
				struct_tag.addTag(blocks)
				i = 0
				for block in struct.substitutions:
					var tag = CompoundTag.new()
					tag.name = str(i)
					tag.add_int("meta",-1 if block.ignore_rotation else Main.MINECRAFT_SIDES[block.rotation])
					tag.add_string("id",Main.blockInfo[block.id]["mod"]+":"+Main.blockInfo[block.id]["name"])
					tag.add_bool("tile",Main.blockInfo[block.id]["tile_entity"])
					tag.add_vector_3i("pos",block.position)
					subs.addTag(tag)
					i+=1
				struct_tag.addTag(subs)
				i = 0
				for block in struct.tileEntities:
					var tag = CompoundTag.new()
					tag.name = str(i)
					tag.add_int("meta",-1 if block.ignore_rotation else Main.MINECRAFT_SIDES[block.rotation])
					tag.add_string("id",Main.blockInfo[block.id]["mod"]+":"+Main.blockInfo[block.id]["name"])
					tag.add_bool("tile",Main.blockInfo[block.id]["tile_entity"])
					tag.add_vector_3i("pos",block.position)
					tes.addTag(tag)
					i+=1
				struct_tag.addTag(tes)
				NamedBinaryTag.write(struct_tag,path,false)
	else:
		pass


func _on_copy_pressed():
	if Main.pos1 != null and Main.pos2 != null:
		var min_vec = Vector3i(min(Main.pos1.x, Main.pos2.x), min(Main.pos1.y, Main.pos2.y), min(Main.pos1.z, Main.pos2.z))
		var max_vec = Vector3i(max(Main.pos1.x, Main.pos2.x), max(Main.pos1.y, Main.pos2.y), max(Main.pos1.z, Main.pos2.z))
	
		Main.clipboard.clear()
		for i in range(min_vec.x, max_vec.x + 1):
			for j in range(min_vec.y, max_vec.y + 1):
				for k in range(min_vec.z, max_vec.z + 1):
					var pos = Vector3i(i, j, k)
					var offset = pos - min_vec
					var v = %Player.voxel_world_tool
					if v.get_voxel(pos) > 1:
						var meta = v.get_voxel_metadata(pos)
						Main.clipboard.append(BlockInstance._new(offset,v.get_voxel(pos),meta["rot"]))
						print(v.get_voxel(pos))
					else:
						Main.clipboard.append(BlockInstance._new(offset,-1,0))


func _on_paste_pressed():
	if %Player.get_pointed_voxel() != null:
		paste(%Player.get_pointed_voxel().previous_position)

func paste(pos: Vector3i):
	if Main.clipboard != null and Main.clipboard.size() > 0:
		for block in Main.clipboard:
			if(pos+Vector3i(block.offset)).y <= 0:
				return
		for block in Main.clipboard:
			if(pos+Vector3i(block.offset)).y > 0:
				var v = %Player.voxel_world_tool
				v.value = block.id
				v.do_point(pos+Vector3i(block.offset))
				v.set_voxel_metadata(pos+Vector3i(block.offset),{"id":block.id,"rot":block.rotation})
				
func move(offset: Vector3i):
	_on_cut_pressed()
	if Main.clipboard != null and Main.clipboard.size() > 0:
		for block in Main.clipboard:
			if(Vector3i(block.position)+offset).y > 0:
				var v = %Player.voxel_world_tool
				v.value = block.id
				v.do_point(Vector3i(block.position)+offset)
				v.set_voxel_metadata(Vector3i(block.position)+offset,{"id":block.id,"rot":block.rotation})
	Main.pos1 += offset
	get_tree().current_scene.reload_struct_renders()
	Main.pos2 += offset
	get_tree().current_scene.reload_struct_renders()

func _on_cut_pressed():
	if Main.pos1 != null and Main.pos2 != null:
		var min_vec = Vector3i(min(Main.pos1.x, Main.pos2.x), min(Main.pos1.y, Main.pos2.y), min(Main.pos1.z, Main.pos2.z))
		var max_vec = Vector3i(max(Main.pos1.x, Main.pos2.x), max(Main.pos1.y, Main.pos2.y), max(Main.pos1.z, Main.pos2.z))
	
		Main.clipboard.clear()
		for i in range(min_vec.x, max_vec.x + 1):
			for j in range(min_vec.y, max_vec.y + 1):
				for k in range(min_vec.z, max_vec.z + 1):
					var pos = Vector3i(i, j, k)
					var offset = pos - min_vec
					var v = %Player.voxel_world_tool
					if v.get_voxel(pos) > 1:
						var meta = v.get_voxel_metadata(pos)
						Main.clipboard.append(BlockInstance._new(pos,v.get_voxel(pos),meta["rot"]).set_offset(offset))
						%Player._place_single_voxel(pos,-1,0)
						print(v.get_voxel(pos))
					else:
						Main.clipboard.append(BlockInstance._new(pos,-1,0).set_offset(offset))
