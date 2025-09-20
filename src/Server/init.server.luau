local rbxbuf = require(game.ReplicatedStorage.rbxbuf)

local cursor = rbxbuf.new()

cursor:write(rbxbuf.Types.String, "Hello World!")

print(cursor:read(rbxbuf.Types.String, 0))
