class_name IntArrayTag
extends BaseTag

var value: PackedInt32Array

func getId() -> int:
	return TAGS.INT_ARRAY

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_32(value.size())
	for i in value:
		file.store_32(i)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> IntArrayTag:
	var length = file.get_32()
	var ints = PackedInt32Array()
	for i in range(length):
		ints.append(file.get_32())
	value = ints
	return self

func _to_string():
	return "<IntArrayTag: '"+name+"' = "+str(value)+">"
