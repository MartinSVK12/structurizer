class_name BaseTag
extends Resource

enum TAGS {
	END,
	BYTE,
	SHORT,
	INT,
	LONG,
	FLOAT,
	DOUBLE,
	BYTE_ARRAY,
	STRING,
	LIST,
	COMPOUND,
	INT_ARRAY,
	LONG_ARRAY,
	MAX
}

var name: String
	
func getId() -> int:
	return TAGS.END

@warning_ignore("unused_parameter")
func write(file: FileAccess, depth: int):
	pass
	
@warning_ignore("unused_parameter")
func read(file: FileAccess, depth: int):
	pass
	
