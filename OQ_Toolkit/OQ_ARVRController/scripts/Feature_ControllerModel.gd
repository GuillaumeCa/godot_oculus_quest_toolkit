extends Spatial

enum controllerType {
	QUEST,
	QUEST_2
}

enum buttonType {
	AX,
	BY
}

onready var palm_marker = $PalmMarker;
onready var grab_marker = $GrabMarker;
onready var ui_marker = $UIMarker;

onready var quest_controller_model = $QuestControllerModel
onready var quest2_controller_model = $Quest2ControllerModel
onready var controller_skeleton = _get_controller_skeleton()

# Preview the controller model
export(controllerType) var preview_controller = controllerType.QUEST_2 setget _set_preview_controller_type

var controller_type: int setget _set_controller_type

# Set inputs to the correct axis
var joy_x_axis: int
var joy_y_axis: int
var grip_axis: int
var trigger_axis: int
var button_AX_type: int
var button_BY_type: int

var mirrored: bool = false

# Angle and travel values for controller skeleton
var MAX_TRAVEL_TRIGGER = 20.0
var MAX_TRAVEL_GRIP = 15.0
var MAX_TRAVEL_JOYSTICK = 15.0
var MAX_TRAVEL_BUTTON = 0.2

func _ready() -> void:
	if Engine.editor_hint:
		return
	if vr.is_oculus_quest_1_device():
		controller_type = controllerType.QUEST
	elif vr.is_oculus_quest_2_device():
		controller_type = controllerType.QUEST_2
	else:
		controller_type = controllerType.QUEST_2

func _process(_delta: float) -> void:
	if Engine.editor_hint:
		return
	update_controller_skeleton()


func update_controller_skeleton() -> void:
	var joy_x = vr.get_controller_axis(joy_x_axis)
	var joy_y = vr.get_controller_axis(joy_y_axis)
	var grip = vr.get_controller_axis(grip_axis)
	var trigger = vr.get_controller_axis(trigger_axis)
	
	# set rotation of skeleton with axis values
	move_stick(Vector2(joy_x * MAX_TRAVEL_JOYSTICK, joy_y * MAX_TRAVEL_JOYSTICK))
	if grip:
		grip = (grip + 1.0) / 2.0
		rotate_grip(grip * MAX_TRAVEL_GRIP)
	if trigger:
		trigger = (trigger + 1.0) / 2.0
		rotate_trigger(trigger * MAX_TRAVEL_TRIGGER)
	
	if vr.button_just_pressed(button_AX_type):
		move_button(-MAX_TRAVEL_BUTTON, buttonType.AX)
	if vr.button_just_released(button_AX_type):
		move_button(0, buttonType.AX)
	if vr.button_just_pressed(button_BY_type):
		move_button(-MAX_TRAVEL_BUTTON, buttonType.BY)
	if vr.button_just_released(button_BY_type):
		move_button(0, buttonType.BY)

func _get_controller_skeleton() -> Skeleton:
	if !controller_type:
		return null
	
	match controller_type:
		controllerType.QUEST:
			return null
		controllerType.QUEST_2:
			return $Quest2ControllerModel.get_child(0).get_child(0) as Skeleton
	return null

func _set_preview_controller_type(new_value: int):
	preview_controller = new_value
	_set_controller_type(new_value)
	
func _set_controller_type(new_value: int):
	controller_type = new_value
	if !quest2_controller_model or !quest_controller_model:
		return
	
	quest_controller_model.visible = controller_type == controllerType.QUEST
	quest2_controller_model.visible = controller_type == controllerType.QUEST_2
	controller_skeleton = _get_controller_skeleton()

func rotate_trigger(rotation_degrees: float):
	if controller_skeleton:
		var pose := Transform()
		pose = pose.rotated(Vector3(1, 0, 0), deg2rad(rotation_degrees if not mirrored else -rotation_degrees))
		controller_skeleton.set_bone_pose(1, pose)

func rotate_grip(rotation_degrees: float):
	if controller_skeleton:
		var pose := Transform()
		pose = pose.rotated(Vector3(0, 1, 0), deg2rad(rotation_degrees if not mirrored else -rotation_degrees))
		controller_skeleton.set_bone_pose(2, pose)

func move_stick(angles_degrees: Vector2):
	if controller_skeleton:
		var pose := Transform()
		pose = pose.rotated(Vector3(1, 0, 0), deg2rad(angles_degrees.y if not mirrored else angles_degrees.x))
		pose = pose.rotated(Vector3(0, 0, 1), deg2rad(angles_degrees.x if not mirrored else -angles_degrees.y))
		controller_skeleton.set_bone_pose(5, pose)

func move_button(delta: float, button: int):
	if controller_skeleton:
		var pose := Transform()
		pose.origin.y = delta
		controller_skeleton.set_bone_pose(4 if button == buttonType.AX else 3, pose)
