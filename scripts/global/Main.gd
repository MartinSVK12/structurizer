extends Node

const VERSION = "0.1.0"

const TEXTURE_SHEET_WIDTH = 256
const TEXTURE_TILE_SIZE = 1.0 / TEXTURE_SHEET_WIDTH

var atlas = load("res://assets/atlas.png")
var atlasMaterial = load("res://assets/atlas_material.tres")
var library: VoxelBlockyLibrary = load("res://assets/block_library.tres")

var uvMap = {"uvMap_SIZE":0}
var uvMapInverted = {}
var lastScene: String = ""

var blockInfo: Array[Dictionary]

var imageCache = {}
var textureCache = {}

var structures: Array[Structure]

var player: Player = null

var auto_add: bool = false
var show_subs: bool = false
var ignore_rotation: bool = false

#RELEVANT ORTHO INDEXES
#0 N,16 E,10 S,22 W,12 T,4 B
#MINECRAFT SIDES
#2 N,3 S,4 W,5 E,1 T,0 B
const ORTHO_INDEXES = [0,16,10,22,12,4]
const MINECRAFT_SIDES = [2,5,3,4,1,0]


# Called when the node enters the scene tree for the first time.
func _ready():
	var dict = NamedBinaryTag.read_native("user://blockInfo.nbt",false)
	var load = SaveSystem.load_data("structs")
	if load != null:
		structures = load
	get_tree().current_scene.get_node("Loading").show()
	lastScene = get_tree().current_scene.scene_file_path
	if dict.is_empty(): 
		lastScene = "res://scenes/Error.tscn"
		printerr("couldn't load block info data, make sure the file at user://blockInfo.nbt and the folder at user://blocks is valid and exists")
	for value in dict.values():
		blockInfo.append(value)
	var explorer = load("res://scenes/NodeExplorer.tscn").instantiate()
	add_child(explorer)
	if get_tree().current_scene.has_node("Player"):
		player = get_tree().current_scene.get_node("Player")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
@warning_ignore("unused_parameter")
func _process(delta):
	DD.set_text("Version",VERSION)
	DD.set_text("FPS",Engine.get_frames_per_second())
	pass

func get_block_mesh(block_id,origin=Vector3.ZERO):
	var surface_tool = SurfaceTool.new()
	surface_tool.begin(Mesh.PRIMITIVE_TRIANGLES)
	_draw_block_mesh(surface_tool, origin, block_id)
	surface_tool.generate_normals()
	surface_tool.generate_tangents()
	surface_tool.index()
	var array_mesh = surface_tool.commit()
	array_mesh.surface_set_material(0,Main.atlas)
	return array_mesh

func _draw_block_mesh(surface_tool, block_sub_position, block_id):
	@warning_ignore("static_called_on_instance")
	var verts = calculate_block_verts(block_sub_position,Main.blockInfo[block_id]["draw_type"])
	@warning_ignore("static_called_on_instance")
	var uvs = calculate_block_uvs(block_id)
	var top_uvs = uvs
	var bottom_uvs = uvs
	var left_uvs = uvs
	var right_uvs = uvs
	var front_uvs = uvs
	var back_uvs = uvs

	if Main.blockInfo[block_id].has("draw_type"):
		if Main.blockInfo[block_id]["draw_type"] == "cross":
			_draw_block_face(surface_tool, [verts[2], verts[0], verts[7], verts[5]], uvs)
			_draw_block_face(surface_tool, [verts[7], verts[5], verts[2], verts[0]], uvs)
			_draw_block_face(surface_tool, [verts[3], verts[1], verts[6], verts[4]], uvs)
			_draw_block_face(surface_tool, [verts[6], verts[4], verts[3], verts[1]], uvs)
			return
		#Fire
		elif Main.blockInfo[block_id]["draw_type"] == "sides_only":
			_draw_block_face(surface_tool, [verts[2], verts[0], verts[3], verts[1]], uvs)
			_draw_block_face(surface_tool, [verts[7], verts[5], verts[6], verts[4]], uvs)
			_draw_block_face(surface_tool, [verts[6], verts[4], verts[2], verts[0]], uvs)
			_draw_block_face(surface_tool, [verts[3], verts[1], verts[7], verts[5]], uvs)
			
			_draw_block_face(surface_tool, [verts[3], verts[1], verts[2], verts[0]], uvs)
			_draw_block_face(surface_tool, [verts[6], verts[4], verts[7], verts[5]], uvs)
			_draw_block_face(surface_tool, [verts[2], verts[0], verts[6], verts[4]], uvs)
			_draw_block_face(surface_tool, [verts[7], verts[5], verts[3], verts[1]], uvs)
			return

	#Allow blocks to have all six sides different.
	if Main.blockInfo[block_id].has("uv"):
		if typeof(Main.blockInfo[block_id]["uv"]) == TYPE_DICTIONARY:
			if Main.blockInfo[block_id]["uv"].has("SOUTH"):
				@warning_ignore("static_called_on_instance")
				back_uvs = calculate_block_uvs(Main.blockInfo[block_id]["uv"]["SOUTH"])
			if Main.blockInfo[block_id]["uv"].has("NORTH"):
				@warning_ignore("static_called_on_instance")
				front_uvs = calculate_block_uvs(Main.blockInfo[block_id]["uv"]["NORTH"])
			if Main.blockInfo[block_id]["uv"].has("WEST"):
				@warning_ignore("static_called_on_instance")
				left_uvs = calculate_block_uvs(Main.blockInfo[block_id]["uv"]["WEST"])
			if Main.blockInfo[block_id]["uv"].has("EAST"):
				@warning_ignore("static_called_on_instance")
				right_uvs = calculate_block_uvs(Main.blockInfo[block_id]["uv"]["EAST"])
			if Main.blockInfo[block_id]["uv"].has("BOTTOM"):
				@warning_ignore("static_called_on_instance")
				bottom_uvs = calculate_block_uvs(Main.blockInfo[block_id]["uv"]["BOTTOM"])
			if Main.blockInfo[block_id]["uv"].has("TOP"):
				@warning_ignore("static_called_on_instance")
				top_uvs = calculate_block_uvs(Main.blockInfo[block_id]["uv"]["TOP"])
	
	# Main rendering code for normal blocks.
	_draw_block_face(surface_tool, [verts[2], verts[0], verts[3], verts[1]], back_uvs) #back
	_draw_block_face(surface_tool, [verts[7], verts[5], verts[6], verts[4]], left_uvs) #left
	_draw_block_face(surface_tool, [verts[6], verts[4], verts[2], verts[0]], front_uvs) #front
	_draw_block_face(surface_tool, [verts[3], verts[1], verts[7], verts[5]], right_uvs) #right
	_draw_block_face(surface_tool, [verts[4], verts[5], verts[0], verts[1]], bottom_uvs) #bottom
	_draw_block_face(surface_tool, [verts[2], verts[3], verts[6], verts[7]], top_uvs) #top


func _draw_block_face(surface_tool, verts, uvs):
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[3]); surface_tool.add_vertex(verts[3])

	surface_tool.set_uv(uvs[2]); surface_tool.add_vertex(verts[2])
	surface_tool.set_uv(uvs[1]); surface_tool.add_vertex(verts[1])
	surface_tool.set_uv(uvs[0]); surface_tool.add_vertex(verts[0])

static func calculate_block_uvs(block_id,auto=false):
	# This method only supports square texture sheets.
	var row = 0
	var col = 0
	if typeof(block_id) == TYPE_INT:
		if auto:
			row = block_id / TEXTURE_SHEET_WIDTH
			col = block_id % TEXTURE_SHEET_WIDTH
		else:
			if Main.uvMap.has(Main.blockInfo[block_id]["main_uv"]):
				row = int(Main.uvMap[Main.blockInfo[block_id]["main_uv"]].y)
				col = int(Main.uvMap[Main.blockInfo[block_id]["main_uv"]].x)
			else:
#				print("Skipping unmapped UV: "+str(block_id))
				pass
	elif typeof(block_id) == TYPE_STRING:
		if Main.uvMap.has(block_id):
			row = int(Main.uvMap[block_id].y)
			col = int(Main.uvMap[block_id].x)
		else:
#			print("Skipping unmapped UV: "+str(block_id))
			pass
	elif typeof(block_id) == TYPE_VECTOR2:
		row = block_id.y
		col = block_id.x
	
#	print("UV's for "+str(block_id)+": ("+str(row)+","+str(col)+")")
	
	return [
		TEXTURE_TILE_SIZE * Vector2(col, row),
		TEXTURE_TILE_SIZE * Vector2(col, row + 1),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row),
		TEXTURE_TILE_SIZE * Vector2(col + 1, row + 1),
	]

static func calculate_block_verts(block_position,draw_type="normal"):
	match draw_type:
		"normal":
			return [
				Vector3(block_position.x, block_position.y, block_position.z),
				Vector3(block_position.x, block_position.y, block_position.z + 1),
				Vector3(block_position.x, block_position.y + 1, block_position.z),
				Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
				Vector3(block_position.x + 1, block_position.y, block_position.z),
				Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
				Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
				Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
			]
		"slab":
			return [
				Vector3(block_position.x, block_position.y, block_position.z),
				Vector3(block_position.x, block_position.y, block_position.z + 1),
				Vector3(block_position.x, block_position.y + 0.5, block_position.z),
				Vector3(block_position.x, block_position.y + 0.5, block_position.z + 1),
				Vector3(block_position.x + 1, block_position.y, block_position.z),
				Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
				Vector3(block_position.x + 1, block_position.y + 0.5, block_position.z),
				Vector3(block_position.x + 1, block_position.y + 0.5, block_position.z + 1),
			]
		_:
			return [
				Vector3(block_position.x, block_position.y, block_position.z),
				Vector3(block_position.x, block_position.y, block_position.z + 1),
				Vector3(block_position.x, block_position.y + 1, block_position.z),
				Vector3(block_position.x, block_position.y + 1, block_position.z + 1),
				Vector3(block_position.x + 1, block_position.y, block_position.z),
				Vector3(block_position.x + 1, block_position.y, block_position.z + 1),
				Vector3(block_position.x + 1, block_position.y + 1, block_position.z),
				Vector3(block_position.x + 1, block_position.y + 1, block_position.z + 1),
			]

static func is_block_transparent(block_id):
	#print(str(block_id) + " " + str(Main.blockInfo[block_id].has("transparent")))
	return Main.blockInfo[block_id]["transparent"]#block_id == 0 or (block_id > 25 and block_id < 31)
	#

func get_files_in_dir(dirPath, extension=""):
	return Array(DirAccess.get_files_at(dirPath)).filter(func(ext): return ext.get_extension() == extension)

func get_dirs_in_dir(dirPath):
	return DirAccess.get_directories_at(dirPath)
	
func load_image_external(imagePath,cache=true) -> Image:
#	print("Loading external image: "+imagePath)
	if imageCache.has(imagePath) and cache:
		return imageCache[imagePath]
	var f = FileAccess.open(imagePath, FileAccess.READ)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		printerr("External image load failed for file at "+imagePath+". "+error_string(r))
		return Image.new()
	var bytes = f.get_buffer(f.get_length())
	var img = Image.new()
	r = img.load_png_from_buffer(bytes)
	if r != OK:
		printerr("Failed to load image from bytes from file at "+imagePath+". "+error_string(r))
		return Image.new()
	img.convert(Image.FORMAT_RGBA8)
	imageCache[imagePath] = img
	return img

func load_texture_external(imagePath,cache=true) -> ImageTexture:
	if textureCache.has(imagePath) and cache:
		return textureCache[imagePath]
	var f = FileAccess.open(imagePath, FileAccess.READ)
	var r = f.get_error() if is_instance_valid(f) else ERR_DOES_NOT_EXIST if is_instance_valid(f) else ERR_DOES_NOT_EXIST
	if r != OK:
		printerr("External texture load failed for file at "+imagePath+"."+error_string(r))
		return ImageTexture.new()
	var bytes = f.get_buffer(f.get_length())
	var img = Image.new()
	r = img.load_png_from_buffer(bytes)
	if r != OK:
		printerr("Failed to load image from bytes from file at "+imagePath+". "+error_string(r))
		return ImageTexture.new()
	var itex = ImageTexture.create_from_image(img)
	textureCache[imagePath] = itex
	return itex
	
func _notification(what):
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveSystem.save_data(structures,"structs")
		get_tree().quit()
