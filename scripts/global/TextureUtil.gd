extends Node

const P = "[Texture Util]"
var stage = "ready"
var remake_icons = true
var atlas_preload = Image.new()


func _ready():
	atlas_preload = load("res://assets/atlas_blank.png").get_image()
	if atlas_preload.is_compressed():
		atlas_preload.decompress()
	stitch_block_atlas()
	await get_tree().create_timer(1).timeout
	construct_block_icons()
		
func construct_block_icons():
	stage = "constructing_block_icons"
	print(P + " Constructing block icons.")
	get_tree().change_scene_to_file("res://scenes/BlockIconConstructor.tscn")
#
func stitch_block_atlas():
	stage = "stitching_block_atlas"
	print(P + " Stitching the block atlas.")
	await get_tree().create_timer(1).timeout
	if Main.uvMap == {} or Main.uvMapInverted == {} or Main.get_files_in_dir("user://blocks","png").size() < Main.uvMap["uvMap_SIZE"]:
		recreate_default_textures()
	
	apply_texture_pack_from_data(atlas_preload,"Default")
#
func recreate_default_textures():
	Main.uvMap = {}
	Main.uvMapInverted = {}
	atlas_preload.fill(Color.TRANSPARENT)
	stitch_atlas("user://blocks","res://assets/atlas.png")
	if atlas_preload != null and not atlas_preload.is_empty():
		atlas_preload.save_png("res://assets/atlas.png")
	Main.uvMap["uvMap_SIZE"] = Main.get_files_in_dir("user://blocks","png").size()
	SaveSystem.save_data(Main.uvMap,"uvMap")
	SaveSystem.save_data(Main.uvMapInverted,"uvMapInverted")
#
func finalize():
	stage = "finalizing"
	print(P + " Finalizing.")
	print(P + " All done!")
	stage = "done"
	get_tree().change_scene_to_file(Main.lastScene)
	await get_tree().create_timer(1).timeout
	get_tree().current_scene.get_node("Loading").hide()


#actually works now
func stitch_atlas(dirPath,atlasPath):
	var files = Main.get_files_in_dir(dirPath,"png")
	if files != null:
		for texture in files:
			add_texture_to_atlas(dirPath.path_join(texture),atlasPath,true)
	else:
		print_stack()
		push_error("ERR: Dir contains no files.")
		
func separate_images_from_atlas(atlasPath,dirPath,cell_size=Vector2(16,16)):
	var atlas: Image = load(atlasPath).get_data()
	if atlas.is_compressed():
		atlas.decompress()
	var size = atlas.get_size()
	for y in range(size.y/cell_size.x):
		for x in range(size.x/cell_size.y):
			var cellRect = Rect2i(Vector2(x*16,y*16),Vector2(16,16))
			var atlasCell = atlas.get_region(cellRect)
			if !atlasCell.is_invisible():
				atlasCell.save_png(dirPath+"/texture_"+str(x)+","+str(y)+".png")

func get_images_from_atlas(atlasPath,cell_size=Vector2(16,16)):
	var atlas: Image = load(atlasPath).get_data()
	if atlas.is_compressed():
		atlas.decompress()
	var images = {}
	var size = atlas.get_size()
	for y in range(size.y/cell_size.x):
		for x in range(size.x/cell_size.y):
			var cellRect = Rect2i(Vector2(x*16,y*16),Vector2(16,16))
			var atlasCell = atlas.get_region(cellRect)
			if !atlasCell.is_invisible():
				images[Vector2(x,y)] = atlasCell
	return images

func get_image_from_atlas(uv_name):
	var atlas: Image = Main.atlas.get_image() if Main.atlas is CompressedTexture2D else Main.atlas
	if atlas.is_compressed():
		atlas.decompress()
#	print("UV: ",uv_name," XY: ",Main.uvMap[uv_name])
	var cellRect = Rect2i(Main.uvMap[uv_name]*64,Vector2(16,16))
	var atlasCell = atlas.get_region(cellRect)
	return atlasCell

func add_texture_to_atlas(imagePath,atlasPath,map_textures=false,imageName=""):
	print(P + " Adding image from "+imagePath+" to "+atlasPath)
	var image: Image = Main.load_image_external(imagePath)
	var atlas: Image = Image.new()
	atlas = atlas_preload
	if atlas.is_compressed():
		atlas.decompress()
	if image.is_compressed():
		image.decompress()
	var size = atlas.get_size()
	@warning_ignore("unused_variable")
	var cell = Rect2i(Vector2(0,0),Vector2(16,16))
	var copied = false
	for y in range(size.y/16):
		for x in range(size.x/16):
#			print("Attemping to add image at x:"+str(x*64)+" y:"+str(y*64))
			var cellRect = Rect2i(Vector2(x*16,y*16),Vector2(16,16))
			var atlasCell = atlas.get_region(cellRect)
			if atlasCell.is_invisible():
				atlas.blit_rect(image,Rect2i(Vector2(0,0),Vector2(16,16)),Vector2(x*16,y*16))
				copied = true
				if map_textures and imageName == "":
					var tex_name = imagePath.replace("user://blocks/","")
					Main.uvMap[tex_name] = Vector2(x,y)
					Main.uvMapInverted[Vector2(x,y)] = tex_name
				elif map_textures and imageName != "":
					Main.uvMap[imageName] = Vector2(x,y)
					Main.uvMapInverted[Vector2(x,y)] = imageName
				break
			else:
				continue
		if copied:
			break
	assert(copied,P + " No more empty space on atlas!")
	atlas_preload = atlas

func apply_texture_pack(path):
	print(P + " Applying texture pack from: "+path)
	Main.atlas = Main.load_texture_external(path)
	Main.atlasMaterial.albedo_texture = Main.atlas
#	construct_block_icons()

func apply_texture_pack_from_data(data,pack_name):
	print(P + " Applying texture pack from data: "+pack_name)
	Main.atlas = data
	var itex = ImageTexture.create_from_image(Main.atlas)
	Main.atlasMaterial.albedo_texture = itex
	if remake_icons:
		construct_block_icons()
	else:
		finalize()
