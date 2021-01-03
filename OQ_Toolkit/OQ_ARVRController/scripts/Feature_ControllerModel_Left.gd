tool
extends "res://OQ_Toolkit/OQ_ARVRController/scripts/Feature_ControllerModel.gd"

func _ready() -> void:
	joy_x_axis = vr.AXIS.LEFT_JOYSTICK_X
	joy_y_axis = vr.AXIS.LEFT_JOYSTICK_Y
	grip_axis = vr.AXIS.LEFT_GRIP_TRIGGER
	trigger_axis = vr.AXIS.LEFT_INDEX_TRIGGER
	button_AX_type = vr.BUTTON.X
	button_BY_type = vr.BUTTON.Y
	mirrored = true
