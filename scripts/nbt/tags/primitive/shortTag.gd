class_name ShortTag
extends BaseTag

var value: int

func getId() -> int:
	return TAGS.SHORT

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_16(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> ShortTag:
	value = wrapi(file.get_16(),-32768,32767)
	return self

func _to_string():
	return "<ShortTag: '"+name+"' = "+str(value)+">"
