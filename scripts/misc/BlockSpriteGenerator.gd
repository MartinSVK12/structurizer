extends Node

@onready var _viewport : Viewport = $SubViewport
@onready var _mesh_instance : MeshInstance3D = $SubViewport/MeshInstance3D

var _current_block_id := -1

var activate = true

var terrain = Main.atlasMaterial

var library: VoxelBlockyLibrary = load("res://assets/library_base.tres")



func _ready():
	pass

func _process(_delta):
	if activate:
		$Loading/VBoxContainer/Progress.max_value = Main.blockInfo.size()
		$Loading/VBoxContainer/Progress.value = _current_block_id
		$Loading/VBoxContainer/Sublabel.set_text("Creating block icons: "+str(_current_block_id)+"/"+str(Main.blockInfo.size()))
		if _current_block_id != -1 and Main.blockInfo.size() >= _current_block_id:
			var viewport_texture := _viewport.get_texture()
			var im: Image = viewport_texture.get_image()
			im.convert(Image.FORMAT_RGBA8)
			if Main.blockInfo[_current_block_id].has("draw_type"):
				if Main.blockInfo[_current_block_id]["draw_type"] == "item":
					im = TextureUtil.get_image_from_atlas(Main.blockInfo[_current_block_id]["main_uv"])#Main.load_image_external("res://Textures/blocks/"+Main.blockInfo[_current_block_id]["uv"]+".png")
					im.convert(Image.FORMAT_RGBA8)
			var fpath := "res://assets/icons/"+str(_current_block_id)+".png"
			var err = im.save_png(fpath)
			if err != OK:
				push_error(str("Could not save ", fpath, ", error ", error_string(err)))
			else:
				pass
				#print("Saved ", fpath)

		_current_block_id += 1

		if _current_block_id < Main.blockInfo.size():
			# Setup next block for rendering
			var mesh = Main.get_block_mesh(_current_block_id)
			# Create all the rotated forms
			for i in Main.ORTHO_INDEXES:
				var model: VoxelBlockyModelMesh = VoxelBlockyModelMesh.new()
				model.mesh = mesh
				model.set_material_override(0,terrain)
				model.mesh_ortho_rotation_index = i
				var voxel = library.add_model(model)
			$SubViewport/MeshInstance3D.mesh = mesh
			$SubViewport/MeshInstance3D.material_override = terrain
			if _current_block_id == 0:
				ResourceSaver.save($SubViewport/MeshInstance3D.mesh,"res://assets/block_mesh.tres")
		else:
			ResourceSaver.save(library,"res://assets/block_library.tres")
			TextureUtil.finalize()
			print("Done!")
			set_process(false)

