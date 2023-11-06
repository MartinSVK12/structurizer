class_name CompoundTag
extends BaseTag

var value: Dictionary
	
func getId() -> int:
	return TAGS.COMPOUND

func addTag(tag: BaseTag):
	value[tag.name] = tag
	
func add_string(name: String, value: String):
	var tag = StringTag.new()
	tag.name = name
	tag.value = value
	addTag(tag)
	
func add_bool(name: String, value: bool):
	var tag = ByteTag.new()
	tag.name = name
	tag.value = value
	addTag(tag)
	
func add_int(name: String, value: int):
	var tag = IntTag.new()
	tag.name = name
	tag.value = value
	addTag(tag)

func add_vector_3i(name: String, value: Vector3i):
	var tag = CompoundTag.new()
	tag.add_int("x",value.x)
	tag.add_int("y",value.y)
	tag.add_int("z",value.z)
	tag.name = name
	addTag(tag)

func getTag(tagName: String) -> BaseTag:
	return value[tagName]

func write(file: FileAccess, depth: int):
	if(depth > 512):
		push_error("Too complex! (depth > 512)")
		return
	for tag in value.values():
		if tag is BaseTag:
			file.store_8(tag.getId())
			file.store_16(tag.name.length())
			file.store_string(tag.name)
			tag.write(file,depth+1)
	file.store_8(0)
	
func read(file: FileAccess, depth: int) -> CompoundTag:
	if(depth > 512):
		push_error("Too complex! (depth > 512)")
		return null
	var tags: Dictionary = {}
	var next: int = file.get_8()
	while next != 0:
		var tag: BaseTag
		match next:
			BaseTag.TAGS.BYTE:
				tag = ByteTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.STRING:
				tag = StringTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.FLOAT:
				tag = FloatTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.DOUBLE:
				tag = DoubleTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.LONG:
				tag = LongTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.INT:
				tag = IntTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.SHORT:
				tag = ShortTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.COMPOUND:
				tag = CompoundTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.BYTE_ARRAY:
				tag = ByteArrayTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.INT_ARRAY:
				tag = IntArrayTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			BaseTag.TAGS.LONG_ARRAY:
				tag = LongArrayTag.new()
				tags[tag.name] = load_tag(tag,file,depth)
			_:
				push_error("Invalid tag id: "+str(next)+"!")
				return null
		next = file.get_8()
	value = tags
	return self
	
func read_native(depth: int) -> Dictionary:
	if(depth > 512):
		push_error("Too complex! (depth > 512)")
		return {}
	var dict: Dictionary = {}
	for content in value.values():
		var tag: BaseTag = content as BaseTag
		var tagId = (tag as BaseTag).getId()
		match tagId:
			BaseTag.TAGS.BYTE:
				dict[tag.name] = (tag as ByteTag).value
			BaseTag.TAGS.STRING:
				dict[tag.name] = (tag as StringTag).value
			BaseTag.TAGS.FLOAT:
				dict[tag.name] = (tag as FloatTag).value
			BaseTag.TAGS.DOUBLE:
				dict[tag.name] = (tag as DoubleTag).value
			BaseTag.TAGS.LONG:
				dict[tag.name] = (tag as LongTag).value
			BaseTag.TAGS.INT:
				dict[tag.name] = (tag as IntTag).value
			BaseTag.TAGS.SHORT:
				dict[tag.name] = (tag as ShortTag).value
			BaseTag.TAGS.COMPOUND:
				dict[tag.name] = (tag as CompoundTag).read_native(depth+1)
			BaseTag.TAGS.BYTE_ARRAY:
				dict[tag.name] = (tag as ByteArrayTag).value
			BaseTag.TAGS.INT_ARRAY:
				dict[tag.name] = (tag as IntArrayTag).value
			BaseTag.TAGS.LONG_ARRAY:
				dict[tag.name] = (tag as LongArrayTag).value
			_:
				push_error("Invalid tag id: "+str(tagId)+"!")
	return dict

func load_tag(tag: BaseTag, file: FileAccess, depth: int) -> BaseTag:
	var length: int = file.get_16()
	tag.name = file.get_buffer(length).get_string_from_utf8()
	tag.read(file,depth+1)
	return tag
	

func _to_string():
	var s = "<CompoundTag: '"+name+"' = "
	for tag in value.values():
		if tag is BaseTag:
			s += tag.to_string()+" "
	s +=">"
	return s
