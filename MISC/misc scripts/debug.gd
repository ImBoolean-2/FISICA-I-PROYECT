extends Control

var changed_graph_size = Vector2(0,0)
@export var car :NodePath = NodePath("../car")

func _ready():
	if not car.is_empty():
		$vgs.clear()  # Limpia la lista de ruedas
		var car_node = get_node(car)  # Obtiene el nodo del coche
		# Agrega las ruedas que tienen configuraciones de neumáticos
		for d in car_node.get_children():
			if "TyreSettings" in d:  # Verifica si el nodo tiene TyreSettings
				$vgs.append_wheel(d.position, d.TyreSettings, d)
				# Lista de propiedades a omitir
				var properties_to_skip = ["peakhp", "tr", "hp", "skip", "scale"]
				# Obtiene la lista de propiedades del script de power_graph
				var property_list = $power_graph.get_script().get_script_property_list()
				# Establece las propiedades en power_graph, omitiendo las que están en properties_to_skip
				for property in property_list:
					if property["name"] not in properties_to_skip and property["name"] in car_node:
						$power_graph.set(property["name"], car_node.get(property["name"]))


func _process(delta):
	VitaVehicleSimulation.misc_smoke = misc_graphics_settings.smoke
	if delta>0:
		get_node("container/fps").text = "Fotogramas por segundo: "+str(1.0/delta)
		if has_node(car):
			$sw.rotation_degrees = get_node(car).steer*380.0
			$sw_desired.rotation_degrees = get_node(car).steer2*380.0
			if get_node(car).Debug_Mode:
				get_node("container/weight_dist").text = "Distribución del peso: F%d/R%d" % [
					round(get_node(car).weight_dist[0] * 100), 
					round(get_node(car).weight_dist[1] * 100)
				]
			else:
				get_node("container/weight_dist").text = "[ Usa F para entrar en el debug_mode\ny ver la distribucion del peso ]"

	if not changed_graph_size == $power_graph.size:
		changed_graph_size = $power_graph.size
		$power_graph._ready()
		
	if not str(car) == "":
		var car_node = get_node(car)  # Referencia al nodo del coche
		var rpm = car_node.rpm
		var linear_velocity = car_node.linear_velocity.length()
		var generation_range = $power_graph.Generation_Range
		var power_graph_size_x = $power_graph.size.x

		# Mostrar "fix engine" si las RPM están por debajo del límite
		$"fix engine".visible = rpm < car_node.DeadRPM

		# Actualizar indicadores de pedales
		var pedal_bars = {
			$throttle: car_node.gaspedal,
			$brake: car_node.brakepedal,
			$handbrake: car_node.handbrakepull,
			$clutch: car_node.clutchpedalreal
		}
		for bar in pedal_bars.keys():
			bar.bar_scale = pedal_bars[bar]
		# Actualizar velocidad en texto
		var kmph = int(linear_velocity * 1.10130592)
		var mph = int(kmph / 1.609)
		$tacho/speedk.text = "KM/PH: " + str(kmph)
		$tacho/speedm.text = "MPH: " + str(mph)

		# Determinar unidad de potencia y torque
		var power_units = ["hp", "bhp", "ps", "kW"]
		var torque_units = ["ft⋅lb", "nm", "kg/m"]
		var hpunit = power_units[$power_graph.Power_Unit]
		var tqunit = torque_units[$power_graph.Torque_Unit]

		# Actualizar potencia y torque
		$hp.text = "Power: %.1f%s @ %.1f RPM" % [$power_graph.peakhp[0], hpunit, $power_graph.peakhp[1]]
		$tq.text = "Torque: %.1f%s @ %.1f RPM" % [$power_graph.peaktq[0], tqunit, $power_graph.peaktq[1]]

		# Actualizar posición de RPM y redline en el gráfico de potencia
		$power_graph/rpm.position.x = (rpm / generation_range) * power_graph_size_x - 1.0
		$power_graph/redline.position.x = (car_node.RPMLimit / generation_range) * power_graph_size_x - 1.0

		# Mostrar fuerza G en ejes
		var gforce = car_node.gforce
		$g.text = "Gs:\nx%.2f,\ny%.2f,\nz%.2f" % [gforce.x, gforce.y, gforce.z]

		# Actualizar turbo y RPM
		$tacho.currentpsi = car_node.turbopsi * car_node.TurboAmount
		$tacho.currentrpm = rpm
		$tacho/rpm.text = str(int(rpm))
		$tacho/rpm.self_modulate = Color(1, 0, 0) if rpm < 0 else Color(1, 1, 1)
		# Actualizar marcha
		match car_node.gear:
			0: $tacho/gear.text = "N"
			-1: $tacho/gear.text = "R"
			_:
				if car_node.TransmissionType in [1, 2]:
					$tacho/gear.text = "D"
				else:
					$tacho/gear.text = str(car_node.gear)

@warning_ignore("unused_parameter")
func _physics_process(delta):
	if car:
		var car_node = get_node(car)  # Guardamos la referencia al nodo del coche
		var gforce_x = car_node.gforce.x
		var gforce_z = car_node.gforce.z
		# Suavizar el cambio de g-force
		$vgs.gforce -= ($vgs.gforce - Vector2(gforce_x, gforce_z)) * 0.5
		# Mostrar indicadores si las condiciones se cumplen
		$tacho/abs.visible = car_node.abspump > 0 and car_node.brakepedal > 0.1
		$tacho/tcs.visible = car_node.tcsflash
		$tacho/esp.visible = car_node.espflash
		
func engine_restart():
	if has_node(car):
		get_node(car).rpm = get_node(car).IdleRPM
		
func toggle_forces():
	Input.action_press("toggle_debug_mode")
