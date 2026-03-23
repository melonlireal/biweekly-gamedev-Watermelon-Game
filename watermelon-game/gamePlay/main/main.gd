extends Node2D

@export var rand_gen_fruit: Dictionary[GlobalResource.FruitType, Resource]
@onready var fruits: Node2D = $fruits
@onready var score_board: RichTextLabel = $score_board




var curr_gen_fruit: Fruit
const SPAWNPOS = 300
const LEFTBOUND = 630
const RIGHTBOUND = 1160
var score:int = 0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	gen_rand_fruit()
	pass # Replace with function body.
	
func _process(_delta: float) -> void:
	if curr_gen_fruit:
		curr_gen_fruit.global_position.x = clampf(get_global_mouse_position().x, LEFTBOUND, RIGHTBOUND)

func gen_rand_fruit():
		var fruit = preload("res://gamePlay/fruit/fruit.tscn")
		var fruit_ready: Fruit = fruit.instantiate()
		var fruit_type = rand_gen_fruit.keys().pick_random()
		fruit_ready.curr_stats = rand_gen_fruit[fruit_type]
		fruit_ready.global_position.x = clampf(get_global_mouse_position().x, LEFTBOUND, RIGHTBOUND)
		fruit_ready.global_position.y = SPAWNPOS
		fruit_ready.freeze = true
		fruit_ready.locked = true
		curr_gen_fruit = fruit_ready
		fruits.add_child(fruit_ready)
		fruit_ready.merged.connect(add_score)
		fruit_ready.collision.disabled = true
		pass

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("drop") and curr_gen_fruit:
		curr_gen_fruit.dropped()
		gen_rand_fruit()
		pass

func add_score(val):
	score += val
	score_board.text = "score: " + str(score)
	

func _on_bottom_body_entered(body: Node2D) -> void:
	print("game over!")
	body.queue_free()
	score = 0
	score_board.text = "score: " + str(score)
	for fruit:Fruit in fruits.get_children():
		fruit.remove()
	call_deferred("gen_rand_fruit")
