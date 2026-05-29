extends Area3D

var character: Node3D = null

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	if character != null:
		$"..".global_position = character.crate_position.global_position
		$"..".global_rotation = character.crate_position.global_rotation
		$"..".sleeping = true
		$"../CollisionShape3D".disabled = true
			
func _on_body_entered(body: Node3D):
	if body.is_in_group("player"):  # Optional extra safety check
		character = body
