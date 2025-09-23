local Types = require(script.Types)

local rbxbuf = {} :: Cursor
rbxbuf.__index = rbxbuf

-- [ Private Functions ] --

local function calculateBytes(type: DataType, value: any): number
	local bytes = 0

	if type == Types.String then
		bytes = #value
	elseif type == Types.EnumItem then
		bytes = #value.Name
	end

	return type.bytes + bytes
end

-- [ Constructors ] --

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
	assert(value, "Cursor import failed, no arugment #1 given.")
	assert(typeof(value) == "string", "Cursor import failed, the given arugment #1 is not a string.")

	local size = #value

	local self = {
		Buffer = buffer.fromstring(value),
		Length = size,
		Offset = 0,
	}

	return setmetatable(self, rbxbuf) :: Cursor
end

function rbxbuf.import(Buffer: buffer, offset: number)
	assert(Buffer, "Cursor import failed, no buffer given.")
	assert(typeof(Buffer) == "buffer", "Cursor import failed, the given arugment #1 is not a buffer.")

	assert(offset, "Cursor import failed, no offset given.")
	assert(typeof(offset) == "number", "Cursor import failed, the given arugment #2 is not a number.")

	local self = {
		Buffer = Buffer,
		Length = buffer.len(Buffer),
		Offset = offset,
	}

	return setmetatable(self, rbxbuf) :: Cursor
end

-- [ Methods ] --

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

function rbxbuf:export(destroyCursor: boolean)
	local toExport = self.Buffer

	if destroyCursor then
		self:destroy()
	else
		self.Buffer = buffer.create(self.Length)
		self.Offset = 0
	end

	return toExport
end

function rbxbuf:destroy()
	for i, _ in self do
		self[i] = nil
	end
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

	-- [ Properties ] --
	Buffer: buffer,
	Offset: number,
	Length: number,

	-- [ Methods ] --
	clear: (Cursor) -> (),
	write: <T>(c: Cursor, t: DataType, v: T) -> number,
	overwrite: <T>(c: Cursor, t: DataType, offset: number, v: T) -> (),
	read: (c: Cursor, t: DataType, v: T) -> any,
	copy: (c: Cursor, target: Cursor, targetOffset: number, sourceOffset: number, count: number) -> (),
	fill: (c: Cursor, offset: number, value: number, count: number) -> (),
	len: (c: Cursor) -> number,
	tostring: (c: Cursor) -> string,
	export: (c: Cursor, destroyCursor: boolean) -> buffer,
	destroy: (c: Cursor) -> (),
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

	-- [ Constructors ] --
	new: (size: number) -> Cursor,
	fromstring: (value: string) -> Cursor,
	import: (b: buffer, offset: number) -> Cursor,
}

return rbxbuf :: CursorMeta
