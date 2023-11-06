class_name LongArrayTag
extends BaseTag

var value: PackedInt64Array

func getId() -> int:
	return TAGS.LONG_ARRAY

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_32(value.size())
	for i in value:
		file.store_64(i)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> LongArrayTag:
	var length = file.get_32()
	var ints = PackedInt64Array()
	for i in range(length):
		ints.append(file.get_64())
	value = ints
	return self

func _to_string():
	return "<LongArrayTag: '"+name+"' = "+str(value)+">"
