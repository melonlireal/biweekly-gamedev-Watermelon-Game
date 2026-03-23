class_name  Fruit
extends RigidBody2D

var locked = false
@export var curr_stats:FruitStats
# Called when the node enters the scene tree for the first time.

@onready var collision: CollisionShape2D = $CollisionShape2D
@onready var sprite: Sprite2D = $Sprite2D
@onready var merge_sf: AudioStreamPlayer = $merge_sf
@onready var drop_sf: AudioStreamPlayer = $drop_sf
@onready var remove_sf: AudioStreamPlayer = $remove_sf


@export var resource_map: Dictionary[GlobalResource.FruitType, Resource]
signal merged

func _ready() -> void:
	sprite.texture = curr_stats.texture
	sprite.scale = curr_stats.scale
	collision.scale = curr_stats.scale
	contact_monitor = true
	max_contacts_reported = 20
	



func _physics_process(_delta: float) -> void:
	if curr_stats.fruit_type == GlobalResource.FruitType.values().back():
		return
	var other_fruits = get_colliding_bodies()
	for fruit in other_fruits:
		if fruit is Fruit:
			var other_fruit:Fruit = fruit
			if other_fruit.curr_stats.fruit_type == self.curr_stats.fruit_type:
				if try_merge_with(other_fruit):
					fruit.remove()
					merge()
					break

func try_merge_with(other: Fruit) -> bool:
	# only one fruit handles merge
	if get_instance_id() > other.get_instance_id():
		return false
	if locked or other.locked:
		return false
	locked = true
	other.locked = true
	return true

func merge():
	merged.emit(curr_stats.score)
	var val_fruit_type = GlobalResource.FruitType.values()
	var next_idx = val_fruit_type.find(curr_stats.fruit_type) + 1
	var next_fruit = val_fruit_type[next_idx]
	curr_stats = resource_map[next_fruit]
	sprite.texture = curr_stats.texture
	sprite.scale = curr_stats.scale
	collision.scale = curr_stats.scale
	merge_sf.stream = curr_stats.merge_music
	merge_sf.play()
	locked = false
		
	
func dropped():
	freeze = false
	collision.disabled = false
	locked = false
	drop_sf.stream = curr_stats.drop_music
	drop_sf.play()
	
	
func remove():
	self.hide()
	collision.disabled = true
	if merge_sf.playing:
		merge_sf.reparent(get_tree().current_scene)
		merge_sf.finished.connect(merge_sf.queue_free)
	if drop_sf.playing:
		drop_sf.reparent(get_tree().current_scene)
		drop_sf.finished.connect(drop_sf.queue_free)
	remove_sf.stream = curr_stats.remove_music
	remove_sf.reparent(get_tree().current_scene)
	remove_sf.finished.connect(remove_sf.queue_free)
	remove_sf.play()
	call_deferred("queue_free")
	
