local Types = require(script.Types)

local rbxbuf = {
	Types = Types,
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

function rbxbuf:write(type: Types.DataType, value: any)
	type.write(self, value)
end

function rbxbuf:read(type: Types.DataType, offset: number)
	return type.read(self, offset)
end

export type Cursor = {
	__index: Cursor,

	Buffer: buffer,
	Offset: number,
	Max: number,

	clear: (Cursor) -> (),
	write: <T>(c: Cursor, t: Types.DataType, v: T) -> (),
	read: (c: Cursor, t: Types.DataType, v: T) -> number | string | boolean,
}

export type CursorMeta = {
	__index: Cursor,

	Types: typeof(Types),
	new: (Size: number) -> Cursor,
}

return rbxbuf :: CursorMeta
