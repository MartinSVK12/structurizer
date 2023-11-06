class_name StringTag
extends BaseTag

var value: String

func getId() -> int:
	return TAGS.STRING

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_16(value.length())
	file.store_string(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> StringTag:
	var length: int = file.get_16()
	value = file.get_buffer(length).get_string_from_utf8()
	return self

func _to_string():
	return "<StringTag: '"+name+"' = '"+value+"'>"
