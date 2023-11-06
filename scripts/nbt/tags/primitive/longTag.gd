class_name LongTag
extends BaseTag

var value: int

func getId() -> int:
	return TAGS.LONG

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_64(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> LongTag:
	value = file.get_64()
	return self

func _to_string():
	return "<LongTag: '"+name+"' = "+str(value)+">"
