class_name NamedBinaryTag
extends Resource

static func read(path: String, compressed: bool = true) -> CompoundTag:
	var file: FileAccess
	if compressed:
		file = FileAccess.open_compressed(path,FileAccess.READ,FileAccess.COMPRESSION_GZIP)
	else:
		file = FileAccess.open(path,FileAccess.READ)
	if file == null: return CompoundTag.new()
	file.big_endian = true
	if(is_instance_valid(file)):
		if(file.get_8() != BaseTag.TAGS.COMPOUND):
			push_error("Root tag in NBT structure must be a compound tag.")
			return null
		var r = CompoundTag.new()
		var length: int = file.get_16()
		r.name = file.get_buffer(length).get_string_from_utf8()
		r.read(file,0)
		return r
	return null
	
static func read_native(path: String, compressed: bool = true) -> Dictionary:
	var tag: CompoundTag = read(path,compressed)
	return tag.read_native(0)
	
static func write(tag: CompoundTag, path: String, compressed: bool = true):
	var file: FileAccess
	if compressed:
		file = FileAccess.open_compressed(path,FileAccess.WRITE,FileAccess.COMPRESSION_GZIP)
	else:
		file = FileAccess.open(path,FileAccess.WRITE)
	file.big_endian = true
	if(is_instance_valid(tag) && is_instance_valid(file)):
		file.store_8(BaseTag.TAGS.COMPOUND)
		if(tag.name == null):
			file.store_16("".length())
			file.store_string("")
		else:
			file.store_16(tag.name.length())
			file.store_string(tag.name)
		tag.write(file,0)
	else:
		push_error("Tag is null!")
