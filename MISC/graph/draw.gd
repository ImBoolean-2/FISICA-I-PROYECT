extends Control

@export_enum("ft⋅lb", "nm", "kg/m") var Torque_Unit = 1
@export_enum("hp", "bhp", "ps", "kW") var Power_Unit = 0

# Configuraciones del motor
@export var RevSpeed = 2.0
@export var EngineFriction = 18000.0
@export var EngineDrag = 0.006
@export var ThrottleResponse = 0.5

# Configuración de la ECU
@export var IdleRPM = 800.0
@export var RPMLimit = 7000.0
@export var VVTRPM = 4500.0

# Torque y estado normal
@export var BuildUpTorque = 0.0035
@export var TorqueRise = 30.0
@export var RiseRPM = 1000.0
@export var OffsetTorque = 110
@export var FloatRate = 0.1
@export var DeclineRate = 1.5
@export var DeclineRPM = 3500.0
@export var DeclineSharpness = 1.0

# Torque con VVT
@export var VVT_BuildUpTorque = 0.0
@export var VVT_TorqueRise = 60.0
@export var VVT_RiseRPM = 1000.0
@export var VVT_OffsetTorque = 70
@export var VVT_FloatRate = 0.1
@export var VVT_DeclineRate = 2.0
@export var VVT_DeclineRPM = 5000.0
@export var VVT_DeclineSharpness = 1.0

# Configuraciones del turbo y supercargador
@export var TurboEnabled = false
@export var MaxPSI = 8.0
@export var TurboAmount = 1
@export var EngineCompressionRatio = 8.0
@export var SuperchargerEnabled = false
@export var SCRPMInfluence = 1.0
@export var BlowRate = 35.0
@export var SCThreshold = 6.0

@export var draw_scale = 0.005
@export var Generation_Range = 7000.0
@export var Draw_RPM = 800.0

var peakhp = [0.0, 0.0]
var peaktq = [0.0, 0.0]

func _ready():
	peakhp = [0.0, 0.0]
	peaktq = [0.0, 0.0]
	$torque.clear_points()
	$power.clear_points()
	
	var skip = 0
	for i in range(Generation_Range):
		if i > Draw_RPM:
			var results = calculate_torque_and_hp(i)
			var tr = results["torque"]
			var hp = results["hp"]
			
			var tr_p = Vector2((i / Generation_Range) * size.x, size.y - (tr * size.y) * draw_scale)
			var hp_p = Vector2((i / Generation_Range) * size.x, size.y - (hp * size.y) * draw_scale)
			
			update_peak_values(hp, tr, i, hp_p, tr_p)
			
			skip -= 1
			if skip <= 0:
				$torque.add_point(tr_p)
				$power.add_point(hp_p)
				skip = 100  # Controla la frecuencia de actualización de los puntos

# Función para calcular el torque y la potencia
func calculate_torque_and_hp(i: int) -> Dictionary:
	var tr = VitaVehicleSimulation.multivariate(
		RiseRPM, TorqueRise, BuildUpTorque, EngineFriction, EngineDrag, OffsetTorque, i, 
		DeclineRPM, DeclineRate, FloatRate, MaxPSI, TurboAmount, EngineCompressionRatio, TurboEnabled, 
		VVTRPM, VVT_BuildUpTorque, VVT_TorqueRise, VVT_RiseRPM, VVT_OffsetTorque, VVT_FloatRate, 
		VVT_DeclineRPM, VVT_DeclineRate, SuperchargerEnabled, SCRPMInfluence, BlowRate, SCThreshold, 
		DeclineSharpness, VVT_DeclineSharpness
	)
	
	var hp = (i / 5252.0) * tr
	tr = convert_torque(tr)
	hp = convert_hp(hp)
	
	return { "torque": tr, "hp": hp }

# Función para convertir torque
func convert_torque(torque: float) -> float:
	match Torque_Unit:
		1: return torque * 1.3558179483  # ft⋅lb
		2: return torque * 0.138255      # kg/m
		_ : return torque                 # nm (por defecto)

# Función para convertir potencia
func convert_hp(hp: float) -> float:
	match Power_Unit:
		1: return hp * 0.986  # bhp
		2: return hp * 1.01387  # ps
		3: return hp * 0.7457  # kW
		_ : return hp  # hp (por defecto)

# Función para actualizar los valores máximos de torque y potencia
func update_peak_values(hp: float, tr: float, i: int, hp_p: Vector2, tr_p: Vector2):
	if hp > peakhp[0]:
		peakhp = [hp, i]
		$power/peak.position = hp_p
		
	if tr > peaktq[0]:
		peaktq = [tr, i]
		$torque/peak.position = tr_p
