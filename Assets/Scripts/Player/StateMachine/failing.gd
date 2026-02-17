extends State

var initial_velocity = null
var rigid_body = null
@export var damping_factor = 1.0  # Value between 0 and 1, closer to 1 is slower damping

@onready var animation_player = $"../../AnimationManager"


func _ready() -> void:
	animation_player.connect("animation_finished", Callable(self, "_on_animation_finished"))

func start():
	animation_player.play("failing")
	$"../../TrickManager".set_trick(-1)
	$"..".danger_state = false
	rigid_body = $"../../RigidBody"
	var velocity = rigid_body.linear_velocity  # Get current velocity vector
	
	if initial_velocity == null:
		initial_velocity = velocity
		
func update(delta: float):
	pass

func fixed_update(delta: float):
	# Apply damping to horizontal movement but let gravity handle Y naturally
	var current_velocity = rigid_body.linear_velocity
	
	# Option 1: Always falling (minimum downward velocity)
	var y_velocity = current_velocity.y
	
	rigid_body.linear_velocity = Vector3(
		initial_velocity.x * damping_factor, 
		y_velocity,  # Let gravity control this
		initial_velocity.z * damping_factor
	)

func _on_animation_finished(anim_name: String) -> void:
	if anim_name == "failing":
		animation_player.play("RESET")  # Replace "reset" with the name of your reset animation
		initial_velocity = null
