extends Node

var current_scene = null
var next_path = ""

func _ready():
	var root = get_tree().get_root()
	current_scene = get_children()[get_child_count() -1]
	add_to_group("GameState")

func goto_scene(path):
	# This function will usually be called from a signal callback,
	# or some other function in the current scene.
	# Deleting the current scene at this point is
	# a bad idea, because it may still be executing code.
	# This will result in a crash or unexpected behavior.

	# The solution is to defer the load to a later time, when
	# we can be sure that no code from the current scene is running:
	next_path = path
	$Transition.transition()
	yield($Transition, "transitioned")
	call_deferred("_deferred_goto_scene", next_path)
	

func _deferred_goto_scene(path):
	# It is now safe to remove the current scene
	current_scene.queue_free()

	# Load the new scene.
	var new_scene = ResourceLoader.load(path)

	# Instance the new scene.
	current_scene = new_scene.instance()

	# Add it to the active scene, as child of root.
	add_child(current_scene)

	# Optionally, to make it compatible with the SceneTree.change_scene() API.
	get_tree().set_current_scene(current_scene)
	
	$Transition.transition()