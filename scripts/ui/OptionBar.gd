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


func _on_refresh_pressed():
	%StructureTree.reload()


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
