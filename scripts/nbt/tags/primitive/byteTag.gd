class_name ByteTag
extends BaseTag

var value: int

func getId() -> int:
	return TAGS.BYTE

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_8(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> ByteTag:
	value = wrapi(file.get_8(),-128,128)
	return self

func _to_string():
	return "<ByteTag: '"+name+"' = "+str(value)+">"
