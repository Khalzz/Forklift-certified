extends Control
@onready var color_rect = $GradeBg/ColorRect
@onready var bg = $GradeBg
@onready var outline = $GradeOutline
@onready var parent = $".."
var progress = 1.0
var grade = 0
var last_grade_index = -1  # track previous grade

const GRADES = [
	{ "grade": "F",   "min_points": 0,     "decay_rate": 50.0  },
	{ "grade": "D",   "min_points": 200,   "decay_rate": 60.0  },
	{ "grade": "C",   "min_points": 400,   "decay_rate": 70.0  },
	{ "grade": "B",   "min_points": 600,  "decay_rate": 80.0  },
	{ "grade": "A",   "min_points": 800,  "decay_rate": 90.0  },
	{ "grade": "S",   "min_points": 1000,  "decay_rate": 100.0 },
	{ "grade": "SS",  "min_points": 1200,  "decay_rate": 110.0 },
	{ "grade": "SSS", "min_points": 1400, "decay_rate": 120.0 },
]

func set_progress(value: float):
	color_rect.scale.y = value

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.is_pressed() and not event.is_echo():
		if event.keycode == KEY_PLUS:
			parent.points += 100
		if event.keycode == KEY_MINUS:
			parent.points -= 100

func _ready() -> void:
	set_progress(1.0)

var run_active = false

func _process(delta: float) -> void:
	if not parent.is_grinding and parent.can_trick:
		var current_grade = get_grade_data(parent.points)
		parent.points -= current_grade["decay_rate"] * delta
		parent.points = maxf(parent.points, 0.0)
	
	set_grade(parent.points)

	if parent.points > 0:
		run_active = true

	if run_active and parent.points <= 0:
		run_active = false
		_on_run_ended()

func _on_run_ended() -> void:
	parent.reset()

func get_grade_data(p) -> Dictionary:
	var result = GRADES[0]
	for g in GRADES:
		if p >= g["min_points"]:
			result = g
	return result

func set_grade(p) -> void:
	var current_grade = get_grade_data(p)
	var current_index = GRADES.find(current_grade)
	
	# Grade changed — snap points to midpoint of new grade on upgrade
	if current_index != last_grade_index:
		var entered_higher = current_index > last_grade_index
		if entered_higher and last_grade_index != -1:
			var grade_min = current_grade["min_points"]
			var grade_max = grade_min  # fallback
			if current_index < GRADES.size() - 1:
				grade_max = GRADES[current_index + 1]["min_points"]
			# Set points to exactly 50% into this grade's range
			parent.points = grade_min + (grade_max - grade_min) * 0.5
		last_grade_index = current_index
	
	# Calculate normalized progress within current grade's range
	var grade_min = current_grade["min_points"]
	var grade_max = INF
	if current_index < GRADES.size() - 1:
		grade_max = GRADES[current_index + 1]["min_points"]
	
	if grade_max == INF:
		progress = 1.0
	else:
		progress = float(parent.points - grade_min) / float(grade_max - grade_min)
	
	set_progress(progress)
	bg.set_text(current_grade["grade"])
	outline.set_text(current_grade["grade"])	
