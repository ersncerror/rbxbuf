local rbxbuf = require(game.ReplicatedStorage.rbxbuf)

local cursor = rbxbuf.new()

cursor:write(rbxbuf.Color3, Color3.fromRGB(255, 50, 75))
print(cursor:read(rbxbuf.Color3, 0))
