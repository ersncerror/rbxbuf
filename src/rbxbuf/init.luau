--!strict

local rbxbuf = {
	Types = require(script.Types),
} :: Cursor
rbxbuf.__index = rbxbuf

function rbxbuf.new(Size: number?)
	Size = Size or 128

	local self = {
		Buffer = buffer.create(Size),
		Max = Size,
		Offset = 0,
	}

	return setmetatable(self, rbxbuf) :: Cursor
end

-- Actually this creates a new buffer
function rbxbuf:clear(): ()
	self.Buffer = nil -- the old one should be garbage collect
	self.Buffer = buffer.create(self.Max)
	self.Offset = 0
end

function rbxbuf:write(type: (Cursor, number | string | boolean) -> (), value: any)
	type(self, value)
end

function rbxbuf:read() end

export type Cursor = {
	__index: Cursor,
	Buffer: buffer | nil,
	Offset: number,
	Max: number,

	new: (Size: number) -> Cursor,
	clear: (Cursor) -> (),
	write: (Cursor) -> (),
	read: (Cursor) -> (),
}

export type CursorMeta = {
	__index: Cursor,

	new: (Size: number) -> Cursor,
}

return rbxbuf :: CursorMeta
