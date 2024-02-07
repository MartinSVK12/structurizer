extends Resource
class_name BlockInstance

var position: Vector3
var offset: Vector3
var id: int
var rotation: int
var ignore_rotation: bool = false

static func _new(_position: Vector3i, _id: int, _rotation: int):
	var b = BlockInstance.new()
	b.position = Vector3(_position)
	b.id = _id
	b.rotation = _rotation
	if Main.ignore_rotation:
		b.set_ignore_rotation()
	return b
	
func set_offset(a_offset: Vector3i) -> BlockInstance:
	offset = a_offset
	return self
	
func _to_string():
	var name = Main.blockInfo[id]["name"]
	if ignore_rotation:
		return name+":any at "+str(position)
	return name+":"+str(rotation)+" at "+str(position)

func set_ignore_rotation():
	ignore_rotation = true
	return self
