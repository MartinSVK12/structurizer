extends ItemList


# Called when the node enters the scene tree for the first time.
func _ready():
	reload()
	pass # Replace with function body.


func reload():
	clear()
	for block in Main.blockInfo.size():
		var item = add_item(Main.blockInfo[block]["name"],Main.load_texture_external("res://assets/icons/"+str(block)+".png"))
		if(%Player.hotbar.find(block) != -1):
			set_item_text(item,Main.blockInfo[block]["name"]+" ["+str(%Player.hotbar.find(block))+"]")
		set_item_metadata(item,block)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):	
	pass

func _unhandled_key_input(event):
	if visible:
		if event is InputEventKey and event.pressed:
			if event.keycode >= KEY_0 and event.keycode <= KEY_9:
				%Player.hotbar[event.keycode-(KEY_9+1)] = get_item_metadata(get_selected_items()[0])
				set_item_text(get_selected_items()[0],Main.blockInfo[get_item_metadata(get_selected_items()[0])]["name"]+" ["+str(event.as_text_keycode())+"]")

func _on_item_activated(index):
	%Player.selected_block = index
