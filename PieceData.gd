extends Resource
class_name PieceData

@export var colorIdx : int
@export var shapeType : GlobalEnum.PieceType
@export var letterData : String 
@export var jigsawLeft : GlobalEnum.JigsawConnection
@export var jigsawRight : GlobalEnum.JigsawConnection

const numCols : int = 8


const letterRollMax : int = 182303

static func rollColor(numCol :int, cd : Dictionary):
	const maxPer = 0.3
	
	var total : int = cd.get("total", 0)
	cd["total"] = total + 1
	
	var c : int = -1
	while c < 0:
		c = randi() % numCol
		var numC = cd.get(c, 0)
		if (numC / maxPer) > total:
			c = -1
		else:
			cd[c] = numC+1
	# end while
	
	return c

static func rollLetter(ld : Dictionary):
	var letters : Array = [
		["E",	21912],
		["T",	16587],
		["A",	14810],
		["O",	14003],
		["I",	13318],
		["N",	12666],
		["S",	11450],
		["R",	10977],
		["H",	10795],
		["D",	7874],
		["L",	7253],
		["U",	5246],
		["C",	4943],
		["M",	4761],
		["F",	4200],
		["Y",	3853],
		["W",	3819],
		["G",	3693],
		["P",	3316],
		["B",	2715],
		["V",	2019],
		["K",	1257],
		["X",	315	 ],
		["Q",	205	 ],
		["J",	188	 ],
		["Z",	128	 ]]
	
	var lRoll = randi_range(0, letterRollMax)
	var lRes = "."
	for l in letters:
		if lRoll < l[1]:
			lRes = l[0]
			ld[lRes] = ld.get(lRes, 0) + 1
			return lRes
		lRoll -= l[1]
	#end for
	return lRes
	
func regen(pt : GlobalEnum.PieceType):
	shapeType = pt
	var globalCD : Dictionary = Engine.get_meta("ColDict", {})
	colorIdx = rollColor(numCols, globalCD)
	Engine.set_meta("ColDict", globalCD)
	
	match pt:
		GlobalEnum.PieceType.Letter:
			var globalLD : Dictionary = Engine.get_meta("LetDict", {})
			letterData = rollLetter(globalLD)
			Engine.set_meta("LetDict", globalLD)
		GlobalEnum.PieceType.Jigsaw:
			pass
	
	print("REGEN ", shapeType, " - ", colorIdx)
	
	
func getColorCached():
	var colorVales : PackedColorArray = [
		Color.DARK_RED, # .hex(0xd85736),
		Color.DARK_GREEN,
		Color.DARK_BLUE,
		Color.DARK_CYAN,
		Color.DARK_GOLDENROD,
		Color.DARK_MAGENTA,
		Color.DARK_TURQUOISE,
		Color.DARK_GRAY,
		Color.PINK
	]
	return colorVales[colorIdx]

