local rbxbuf = require(game.ReplicatedStorage.rbxbuf)

local cursor = rbxbuf.new()

cursor:write(rbxbuf.UInt8, 12)
cursor:write(rbxbuf.UInt16, 24)
cursor:write(rbxbuf.UInt32, 36)
print(cursor:read(rbxbuf.UInt8, 0))
print(cursor:read(rbxbuf.UInt16, 1))
print(cursor:read(rbxbuf.UInt32, 3))
