class_name IntTag
extends BaseTag

var value: int

func getId() -> int:
	return TAGS.INT

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_32(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> IntTag:
	value = wrapi(file.get_32(),-2147483647,2147483647)
	return self

func _to_string():
	return "<IntTag: '"+name+"' = "+str(value)+">"
