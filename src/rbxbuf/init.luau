local Types = require(script.Types)

local rbxbuf = {
	["UInt8"] = Types.UInt8,
	["Int8"] = Types.Int8,
	["UInt16"] = Types.UInt16,
	["Int16"] = Types.Int16,
	["UInt32"] = Types.UInt32,
	["Int32"] = Types.Int32,
	["Float32"] = Types.Float32,
	["Float64"] = Types.Float64,
	["String"] = Types.String,
	["Boolean"] = Types.Boolean,
	["Color3"] = Types.Color3,
	["EnumItem"] = Types.EnumItem,
} :: Cursor
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

	UInt8: DataType,
	Int8: DataType,
	UInt16: DataType,
	Int16: DataType,
	UInt32: DataType,
	Int32: DataType,
	Float32: DataType,
	Float64: DataType,
	String: DataType,
	Boolean: DataType,
	Color3: DataType,
	EnumItem: DataType,

	new: (Size: number) -> Cursor,
}

return rbxbuf :: CursorMeta
