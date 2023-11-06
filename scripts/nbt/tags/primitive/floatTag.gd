class_name FloatTag
extends BaseTag

var value: float

func getId() -> int:
	return TAGS.FLOAT

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_float(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> FloatTag:
	value = file.get_float()
	return self

func _to_string():
	return "<FloatTag: '"+name+"' = "+str(value)+">"
