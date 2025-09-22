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
	local extraBytes = 0

	if type == Types.String then
		extraBytes = #value
	elseif type == Types.EnumItem then
		extraBytes = #value.Name
	end

	local finalBytes = self.Offset + type.bytes + extraBytes

	if finalBytes > self.Length then
		warn(
			`There's not enough spaces to write! (spaces need: {finalBytes} bytes, spaces left: {self.Length - self.Offset} bytes)`,
			debug.traceback()
		)
		return
	end

	local valuePos = self.Offset

	if type == Types.String then
		local String = value :: string

		self.Offset += #String
	elseif type == Types.EnumItem then
		local enumItem = value :: EnumItem

		self.Offset += #enumItem.Name
	end

	type.write(self, self.Offset, value)

	self.Offset += type.bytes

	return valuePos
end

function rbxbuf:overwrite(type: DataType, offset: number, value: any)
	type.write(self, offset, value)
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
	bytes: number,
}

export type Cursor = {
	__index: Cursor,

	Buffer: buffer,
	Offset: number,
	Length: number,

	clear: (Cursor) -> (),
	write: <T>(c: Cursor, t: DataType, v: T) -> number,
	overwrite: <T>(c: Cursor, t: DataType, offset: number, v: T) -> (),
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
