# class_name JobFactory

extends Node2D

var scenes = {}

func make_scene(resource_path, arguments):
	var scene
	if not(resource_path in scenes):
		scene = load(resource_path)
		scenes[resource_path] = scene
	else:
		scene = scenes[resource_path]

	var job : JobBase = scene.instance()
	# Wants to be called *after* the job is added to the scene tree.
	job.call_deferred('setup', arguments)
	return job
