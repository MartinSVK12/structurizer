class_name ByteArrayTag
extends BaseTag

var value: PackedByteArray

func getId() -> int:
	return TAGS.BYTE_ARRAY

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_32(value.size())
	file.store_buffer(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> ByteArrayTag:
	value = file.get_buffer(file.get_32())
	return self

func _to_string():
	return "<ByteArrayTag: '"+name+"' = "+str(value)+">"
