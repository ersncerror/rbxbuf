local Types = require(script.Types)

local rbxbuf = {} :: Cursor
rbxbuf.__index = rbxbuf

function rbxbuf.new(Size: number?)
	Size = Size or 128

	local self = {
		Buffer = buffer.create(Size),
		Length = Size,
		Offset = 0,
	}

	return setmetatable(self, rbxbuf) :: Cursor
end

-- Actually this creates a new buffer
function rbxbuf:clear(): ()
	self.Buffer = nil -- the old one should be garbage collect
	self.Buffer = buffer.create(self.Length)
	self.Offset = 0
end

function rbxbuf:write(type: DataType, value: any)
	type.write(self, value)
end

function rbxbuf:read(type: DataType, offset: number)
	return type.read(self, offset)
end

function rbxbuf:len(): number
	return buffer.len(self.Buffer)
end

for i, v in Types do
	rbxbuf[i] = v
end

type TypeFunc<T> = (c: Cursor, value: T) -> any

type DataType = {
	read: TypeFunc,
	write: TypeFunc,
}

export type Cursor = {
	__index: Cursor,

	Buffer: buffer,
	Offset: number,
	Length: number,

	clear: (Cursor) -> (),
	write: <T>(c: Cursor, t: DataType, v: T) -> (),
	read: (c: Cursor, t: DataType, v: T) -> any,
	len: (c: Cursor) -> number,
}

export type CursorMeta = {
	__index: Cursor,

	-- [ Numbers ] --
	UInt8: DataType,
	Int8: DataType,
	UInt16: DataType,
	Int16: DataType,
	UInt32: DataType,
	Int32: DataType,
	Float32: DataType,
	Float64: DataType,

	-- [ Lua Data types ] --
	String: DataType,
	Boolean: DataType,

	-- [ RBX Data Types ] --
	Color3: DataType,
	EnumItem: DataType,

	-- [ Vectors ] --
	Vector3: DataType,
	Vector3Int16: DataType,
	Vector2: DataType,
	Vector2Int16: DataType,

	-- [ CFrames ] --
	CFrameI16I8: DataType, --> 9 bytes
	CFrameI16I16: DataType, --> 12 bytes
	CFrameF32I8: DataType, --> 15 bytes
	CFrameF32I16: DataType, --> 18 bytes

	new: (Size: number) -> Cursor,
}

return rbxbuf :: CursorMeta
