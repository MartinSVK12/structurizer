class_name Structure
extends Resource

var name: String
var origin: BlockInstance
var blocks: Array[BlockInstance]
var substitutions: Array[BlockInstance]
var tileEntities: Array[BlockInstance]

static func _new(_name: String):
	var s = Structure.new()
	s.name = _name
	return s
	
func set_origin(_origin: BlockInstance):
	origin = _origin
	
func has_origin() -> bool:
	return is_instance_valid(origin)
	
func distance_from_origin(pos: Vector3i) -> Vector3i:
	if not is_instance_valid(origin):
		push_error("No origin defined!")
		return Vector3i.ZERO
	return -Vector3i((origin.position - Vector3(pos)))

func add_block(id: int, pos: Vector3i, rotation: int):
	if not is_instance_valid(origin):
		push_error("No origin defined!")
		return
	var offset = distance_from_origin(pos)
	var instance = BlockInstance._new(offset,id,rotation)
	blocks.append(instance)
	if Main.blockInfo[id]["tile_entity"]:
		tileEntities.append(instance)

func remove_block(pos: Vector3i):
	if not is_instance_valid(origin):
		push_error("No origin defined!")
		return
	var offset = distance_from_origin(pos)
	var b = blocks.filter(func(B): if Vector3i(B.position) == offset: return false else: return true)
	blocks = b

func get_all_substitutions(pos: Vector3i) -> Array[BlockInstance]:
	return substitutions.filter(func(B): if Vector3i(B.position) == pos: return true else: return false)

func add_substitution(id: int,  pos: Vector3i, rotation: int):
	if not is_instance_valid(origin):
		push_error("No origin defined!")
		return
	var offset = distance_from_origin(pos)
	var instance = BlockInstance._new(offset,id,rotation)
	substitutions.append(instance)
