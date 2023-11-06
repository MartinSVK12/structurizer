class_name DoubleTag
extends BaseTag

var value: float

func getId() -> int:
	return TAGS.DOUBLE

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	file.store_double(value)
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int) -> DoubleTag:
	value = file.get_double()
	return self

func _to_string():
	return "<DoubleTag: '"+name+"' = "+str(value)+">"
