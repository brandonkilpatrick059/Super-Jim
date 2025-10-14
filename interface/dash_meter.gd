@tool
extends Control

var fraction_filled = 1.0
var full_bar_pixels = 103.0
var current_bar_pixels = 0.0

func _draw():
	var white_bar_width : float = current_bar_pixels
	var blue_bar_width : float = current_bar_pixels * fraction_filled
	draw_rect(Rect2(4.0, 2.0, white_bar_width, 6.0), Color.SLATE_GRAY)
	draw_rect(Rect2(4.0, 2.0, blue_bar_width, 6.0), Color.AQUA)
	#draw_rect(Rect2(4.0, 2.0, 103.0, 6.0), Color.SLATE_GRAY)
	#draw_rect(Rect2(4.0, 2.0, 103.0 * 0.5, 6.0), Color.AQUA)

#where 0 <= n <= 1
func set_fraction_filled(fraction: float):
	fraction_filled = fraction
	queue_redraw()

#where 0 <= n <= 1
func set_fraction_of_full_bar(fraction : float):
	current_bar_pixels = full_bar_pixels * fraction
	queue_redraw()

func _process(delta):
	if(Engine.is_editor_hint()):
		queue_redraw()
