extends Node2D

@export var rand_gen_fruit: Dictionary[GlobalResource.FruitType, Resource]
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop"):
		var melon = preload("res://gamePlay/fruit/fruit.tscn")
		var fruit_ready: Fruit = melon.instantiate()
		var fruit_type = rand_gen_fruit.keys().pick_random()
		fruit_ready.curr_stats = rand_gen_fruit[fruit_type]
		fruit_ready.global_position = get_global_mouse_position()
		self.add_child(fruit_ready)
		pass
