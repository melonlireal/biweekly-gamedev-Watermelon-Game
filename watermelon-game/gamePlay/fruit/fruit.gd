class_name  Fruit
extends RigidBody2D

var locked = false
@export var curr_stats:FruitStats
# Called when the node enters the scene tree for the first time.

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var merge_sf: AudioStreamPlayer = $merge_sf
@onready var drop_sf: AudioStreamPlayer = $drop_sf

@export var resource_map: Dictionary[GlobalResource.FruitType, Resource]

func _ready() -> void:
	sprite.texture = curr_stats.texure
	sprite.scale = curr_stats.scale
	collision.scale = curr_stats.scale
	contact_monitor = true
	max_contacts_reported = 20
	



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# if largest fruit reached, do nothing
	if curr_stats.fruit_type == GlobalResource.FruitType.values().back():
		return
	var other_fruits = get_colliding_bodies()
	for fruit in other_fruits:
		if fruit.has_method("lock"):
			var other_fruit:Fruit = fruit
			if other_fruit.curr_stats.fruit_type == self.curr_stats.fruit_type:
				if other_fruit.lock():
					fruit.remove()
					merge()
					break
		

func merge():
	var val_fruit_type = GlobalResource.FruitType.values()
	var next_idx = val_fruit_type.find(curr_stats.fruit_type) + 1
	var next_fruit = val_fruit_type[next_idx]
	curr_stats = resource_map[next_fruit]
	sprite.texture = curr_stats.texure
	sprite.scale = curr_stats.scale
	collision.scale = curr_stats.scale
	merge_sf.stream = curr_stats.merge_music
	merge_sf.play()
		
	
func dropped():
	drop_sf.stream = curr_stats.drop_music
	drop_sf.play()
	
	
func remove():
	self.hide()
	collision.disabled = true
	if merge_sf.playing:
		await merge_sf.finished
	if drop_sf.playing:
		await drop_sf.finished
	queue_free()
	
	
func lock():
	if not locked:
		locked = true
		return true
	return false
