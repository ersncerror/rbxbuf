local Types = require(script.Types)

local rbxbuf = {} :: Cursor
rbxbuf.__index = rbxbuf

local function calculateBytes(type: DataType, value: any): number
	local bytes = 0

	if type == Types.String then
		bytes = #value
	elseif type == Types.EnumItem then
		bytes = #value.Name
	end

	return type.bytes + bytes
end

function rbxbuf.new(size: number?)
	size = size or 128

	local self = {
		Buffer = buffer.create(size),
		Length = size,
		Offset = 0,
	}

	return setmetatable(self, rbxbuf) :: Cursor
end

function rbxbuf.fromstring(value: string)
	local size = #value

	local self = {
		Buffer = buffer.fromstring(value),
		Length = size,
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
	local bytes = calculateBytes(type, value)

	if self.Offset + bytes > self.Length then
		warn(
			`There's not enough spaces to write! (spaces need: {bytes} bytes, spaces left: {self.Length - self.Offset} bytes)`,
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
	local bytes = calculateBytes(type, value)

	if offset + bytes > self.Offset then
		warn(
			`There's not enough spaces to overwrite! (spaces need: {bytes} bytes, spaces left: {self.Length - self.Offset} bytes)`,
			debug.traceback()
		)
		return
	end

	type.write(self, offset, value)
end

function rbxbuf:read(type: DataType, offset: number)
	return type.read(self, offset)
end

-- copys specified values into the another cursor.
function rbxbuf:copy(target: Cursor, targetOffset: number, sourceOffset: number, count: number)
	buffer.copy(self.Buffer, sourceOffset, target.Buffer, targetOffset, count)
	-- buffer.copy(c, 0, b, 0, 1)
end

function rbxbuf:fill(offset: number, value: number, count: number)
	buffer.fill(self.Buffer, offset, value, count)
end

function rbxbuf:len(): number
	return buffer.len(self.Buffer)
end

function rbxbuf:tostring(): string
	return buffer.tostring(self.Buffer)
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
	copy: (c: Cursor, target: Cursor, targetOffset: number, sourceOffset: number, count: number) -> (),
	fill: (c: Cursor, offset: number, value: number, count: number) -> (),
	len: (c: Cursor) -> number,
	tostring: (c: Cursor) -> string,
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

	new: (size: number) -> Cursor,
	fromstring: (value: string) -> Cursor,
}

return rbxbuf :: CursorMeta
