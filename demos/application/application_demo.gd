extends Node

func _ready() -> void:
	var test_dict: Dictionary = {
		"bingus": "Bongus",
		"pingus": {
			"tingus": "Lingus"
			}
		}
	print(test_dict)
