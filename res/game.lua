
-- Engine init
function OnInit()
	print(_VERSION .. ' with ' .. (jit and jit.version or 'Standard Lua'))

	Engine.LoadModel("res/test.glb")

	print("Engine init")
end


function OnUpdate()

end

function OnPhysicsUpdate()

end
