extends Line2D

func _ready():
	pass # Replace with function body.

func swing():
#	local x, y, r = 0, 0, 1
#	for i = 1, 360 do
#  		local angle = i * math.pi / 180
#  		local ptx, pty = x + r * math.cos( angle ), y + r * math.sin( angle )
#  		drawPoint( ptx, pty )
#	end
	var x = 400
	var y = 425
	var r = 550 - 425
	for i in range(1,360):
		var angle = i * PI / 180
		var pos = Vector2(x + r * cos(angle), x + y * sin(angle))
		points = PoolVector2Array([Vector2(400, 550), pos])
		yield()
