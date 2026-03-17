@tool
extends Node2D

@export_group("Nodes")
## 起始方块 (TextureButton 或其它 Control)
@export var start_box: Control:
	set(val): start_box = val; queue_redraw()
## 目标方块 (TextureButton 或其它 Control)
@export var end_box: Control:
	set(val): end_box = val; queue_redraw()

## how curve the segment is
var segments: int = 100
## the distance where arrow leave and enter node vertically
var vertical_offset: float = 60.0
## distance between tip of arrow and node it points to
var gap: float = 2.0

@onready var line: Line2D = $Line2D
@onready var head: Sprite2D = $Sprite2D

func _process(_delta):
	# update once assigned start and end
	if start_box and end_box:
		update_arrow()

func update_arrow():
	var arrowhead_half_height = (head.texture.get_size().y * head.scale.y) / 2
	# start point: midpoint at bottom of start node
	var p0 = start_box.global_position + Vector2(start_box.size.x / 2, start_box.size.y)
	
	# end point: midpoint at top of end node - radius of arrow
	var p3 = end_box.global_position + Vector2(end_box.size.x / 2, -arrowhead_half_height - gap)
	
	# P1, P2:control point
	var p1 = p0 + Vector2(0, vertical_offset)
	var p2 = p3 + Vector2(0, -vertical_offset)
	
	# generate bell curve
	var points = PackedVector2Array()
	for i in range(segments + 1):
		var t = i / float(segments)
		# 三次贝塞尔公式插值
		var q0 = p0.lerp(p1, t)
		var q1 = p1.lerp(p2, t)
		var q2 = p2.lerp(p3, t)
		var r0 = q0.lerp(q1, t)
		var r1 = q1.lerp(q2, t)
		var pos = r0.lerp(r1, t)
		points.append(to_local(pos))
	line.points = points
	# place the arrow at last point
	head.position = points[-1]
