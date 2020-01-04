extends Spatial

export var text = "I am a Label\nWith a new line"
export var margin = 16;
export var billboard = false;

enum ResizeModes {AUTO_RESIZE, FIXED}
export (ResizeModes) var resize_mode := ResizeModes.AUTO_RESIZE

export var font_size_multiplier = 1.0
export (Color) var font_color
export (Color) var background_color
#export var line_to_parent = false;

onready var ui_label : Label = $Viewport/ColorRect/CenterContainer/Label
onready var ui_container : CenterContainer = $Viewport/ColorRect/CenterContainer
onready var ui_color_rect : CenterContainer = $Viewport/ColorRect
onready var ui_viewport : Viewport = $Viewport
onready var mesh_instance : MeshInstance = $MeshInstance
var ui_mesh : PlaneMesh = null;

func _ready():
	ui_mesh = mesh_instance.mesh;
	set_label_text(text)
	
	match resize_mode:
		ResizeModes.AUTO_RESIZE:
			resize_auto()
		ResizeModes.FIXED:
			resize_fixed()
	
	if (billboard):
		mesh_instance.mesh.surface_get_material(0).set_billboard_mode(SpatialMaterial.BILLBOARD_FIXED_Y);
	
	ui_label.add_color_override("font_color", font_color)
	ui_color_rect.color = background_color
	
	mesh_instance.mesh.surface_get_material(0).set_feature(SpatialMaterial.FEATURE_TRANSPARENT, true)
	
	#if (line_to_parent):
		#var p = get_parent();
		#$LineMesh.visible = true;
		#var center = (global_transform.origin + p.global_transform.origin) * 0.5;
		#$LineMesh.global_transform.origin = center;
		#$LineMesh.look_at_from_position()


func resize_auto():
	# make sure parent is at uniform scale
	scale = Vector3(1, 1, 1)
	
	var size = ui_label.get_minimum_size()
	var res = Vector2(size.x + margin * 2, size.y + margin * 2)
	
	ui_container.set_size(res)
	ui_viewport.set_size(res)
	ui_color_rect.set_size(res)

	var aspect = res.x / res.y

	ui_mesh.size.x = font_size_multiplier * res.x * vr.UI_PIXELS_TO_METER
	ui_mesh.size.y = font_size_multiplier * res.y * vr.UI_PIXELS_TO_METER


func resize_fixed():
	# resize container and viewport while parent and mesh stay fixed

	var parent_width = scale.x
	var parent_height = scale.y
	
	var new_size = Vector2(parent_width * 1024 / font_size_multiplier, parent_height * 1024 / font_size_multiplier)
	
	ui_viewport.set_size(new_size)
	ui_color_rect.set_size(new_size)
	ui_container.set_size(new_size)

	if new_size.x < ui_container.get_size().x or new_size.y < ui_container.get_size().y:
		print("Your labels text is too large and therefore might look weird. Consider decreasing the font_size_multiplier.")
	

func set_label_text(t: String):
	ui_label.set_text(t)
	if ResizeModes.AUTO_RESIZE:
		resize_auto()
