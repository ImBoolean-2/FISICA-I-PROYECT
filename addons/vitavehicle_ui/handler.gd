@tool
extends Control
var engine_enabled = false

var ed = EditorPlugin.new()

var undo_redo = UndoRedo.new()

var eds = ed.get_editor_interface().get_selection()

func entered_engine():
	for i in $Engine_Tuner/tune/container.get_children():
		if i.get_class() == "CheckBox":
			i.button_pressed = $Engine_Tuner/power_graph.get(str(i.var_name))
		elif i.get_class() == "SpinBox":
			i.value = $Engine_Tuner/power_graph.get(i.var_name)
		if i.get_node("varname").text == "":
			i.get_node("varname").text = i.var_name
	refresh()

func refresh():
	$Engine_Tuner/power_graph.Draw_RPM = $Engine_Tuner/power_graph.IdleRPM
	$Engine_Tuner/power_graph.Generation_Range = $Engine_Tuner/power_graph.RPMLimit
	$Engine_Tuner/power_graph.draw_()
	var peak = max($Engine_Tuner/power_graph.peaktq[0],$Engine_Tuner/power_graph.peakhp[0])
	if peak>0:
		$Engine_Tuner/power_graph.graph_scale = 1.0/peak
	$Engine_Tuner/power_graph.draw_()

	var hpunit = "hp"
	if $Engine_Tuner/power_graph.Power_Unit == 1:
		hpunit = "bhp"
	elif $Engine_Tuner/power_graph.Power_Unit == 2:
		hpunit = "ps"
	elif $Engine_Tuner/power_graph.Power_Unit == 3:
		hpunit = "kW"
	$Engine_Tuner/hp.text = "Power: %s%s @ %s RPM" % [str( int($Engine_Tuner/power_graph.peakhp[0]*10.0)/10.0 ), hpunit ,str( int($Engine_Tuner/power_graph.peakhp[1]*10.0)/10.0 )]

	var tqunit = "ft⋅lb"
	if $Engine_Tuner/power_graph.Torque_Unit == 1:
		tqunit = "nm"
	elif $Engine_Tuner/power_graph.Torque_Unit == 2:
		tqunit = "kg/m"
	$Engine_Tuner/tq.text = "Torque: %s%s @ %s RPM" % [str( int($Engine_Tuner/power_graph.peaktq[0]*10.0)/10.0 ), tqunit ,str( int($Engine_Tuner/power_graph.peaktq[1]*10.0)/10.0 )]

var changed_graph_size = Vector2(0.0,0.0)

func _process(delta):
	if not changed_graph_size == $Engine_Tuner/power_graph.size and engine_enabled:
		changed_graph_size = $Engine_Tuner/power_graph.size
		$Engine_Tuner/power_graph.draw_()
	
	if engine_enabled:
		for i in $Engine_Tuner/tune/container.get_children():
			if i.get_class() == "SpinBox":
				if not $Engine_Tuner/power_graph.get(i.var_name) == float(i.value):
					$Engine_Tuner/power_graph.set(i.var_name, float(i.value))
					refresh()
			elif i.get_class() == "CheckBox":
#				print(i)
#				print(i.var_name)
				if not $Engine_Tuner/power_graph.get(str(i.var_name)) == i.button_pressed:
					$Engine_Tuner/power_graph.set(i.var_name, i.button_pressed)
					refresh()

var nods_buffer = []

func press(state):
	if state == "engine":
		$menu.visible = false
		$Engine_Tuner.visible = true
		entered_engine()
		engine_enabled = true
	elif state == "weight_dist":
		$menu.visible = false
		$Collision.visible = true
	elif state == "back":
		$menu.visible = true
		$Engine_Tuner.visible = false
		$Collision.visible = false
		engine_enabled = false
	elif state == "engine_apply":
		var nods = eds.get_selected_nodes()
		if len(nods) == 0:
			$Engine_Tuner/alert.dialog_text = "Nothing is selected."
			$Engine_Tuner/alert.popup()
		else:
			var missing = []
			$Engine_Tuner/alert.dialog_text = "This node is missing these variables: \n"
			for i in $Engine_Tuner/tune/container.get_children():
				if not i.var_name in nods[0]:
					$Engine_Tuner/alert.dialog_text += str("-") + str(i.var_name) + "\n"
					missing.append(i.var_name)

			if len(missing) == 0:
				$Engine_Tuner/confirm.dialog_text = "This configuration will be applied to the following nodes: \n"
				for node in nods:
					$Engine_Tuner/confirm.dialog_text += str("-") + str(node.name) + "\n"
				$Engine_Tuner/confirm.popup()
			else:
				$Engine_Tuner/alert.popup()
	elif state == "collide_apply":
		var nods = eds.get_selected_nodes()
		if len(nods) == 0:
			$Collision/nothing.popup()
		else:
			$Collision/alert.popup()
			for i in nods:
				var arrays = i.shape.points
				for g in arrays:
					arrays.set(
						arrays.find(g),
						g * Vector3(
							$Collision/axis_x2.value,
							$Collision/axis_y2.value,
							$Collision/axis_z2.value
						) + Vector3(
							$Collision/axis_x.value,
							$Collision/axis_y.value,
							$Collision/axis_z.value
						)
					)
				i.shape.set_points(arrays)
			$Collision/alert.visible = false
			$Collision/applied.popup()

func confirm(state):
	if state == "engine_apply":
		for i in $Engine_Tuner/tune/container.get_children():
			for n in nods_buffer:
				if i.get_class() == "SpinBox":
					n.set(i.var_name,float(i.value))
				elif i.get_class() == "CheckBox":
					n.set(i.var_name,i.button_pressed)
	elif state == "engine_append":
		for i in $Engine_Tuner/tune/container.get_children():
			for n in nods_buffer:
				if i.get_class() == "SpinBox":
					i.value = float(n.get(i.var_name))
				elif i.get_class() == "CheckBox":
					i.button_pressed = n.get(i.var_name)


func _on_tune_engine_pressed() -> void:
	pass # Replace with function body.
