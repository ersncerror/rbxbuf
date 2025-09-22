type Cursor = {
	__index: Cursor,

	Buffer: buffer,
	Offset: number,
	Max: number,
}

export type TypeFunc<T> = (c: Cursor, offset: number, value: T) -> any

export type DataType = {
	read: TypeFunc,
	write: TypeFunc,
	bytes: number,
}

local Enums = require(script.Parent.Enums)

local i8Mulit = 40.5
local i16Mulit = 182.04

local function findEnum(Enum: Enum): number?
	for i, v in Enums do
		if v == Enum then
			return i
		end
	end
end

local types = {}

-- [ UInt8 ] --
types.UInt8 = {}
types.UInt8.bytes = 1
types.UInt8.write = function(c: Cursor, offset: number, value: number)
	buffer.writeu8(c.Buffer, offset, value)
end
types.UInt8.read = function(c: Cursor, offset: number)
	return buffer.readu8(c.Buffer, offset)
end

-- [ Int8 ] --
types.Int8 = {}
types.Int8.bytes = 1
types.Int8.write = function(c: Cursor, offset: number, value: number)
	buffer.writei8(c.Buffer, offset, value)
end
types.Int8.read = function(c: Cursor, offset: number)
	return buffer.readi8(c.Buffer, offset)
end

-- [ UInt16 ] --
types.UInt16 = {}
types.UInt16.bytes = 2
types.UInt16.write = function(c: Cursor, offset: number, value: number)
	buffer.writeu16(c.Buffer, offset, value)
end
types.UInt16.read = function(c: Cursor, offset: number)
	return buffer.readu16(c.Buffer, offset)
end

-- [ Int16 ] --
types.Int16 = {}
types.Int16.bytes = 2
types.Int16.write = function(c: Cursor, offset: number, value: number)
	buffer.writei16(c.Buffer, offset, value)
end
types.Int16.read = function(c: Cursor, offset: number)
	return buffer.readi16(c.Buffer, offset)
end

-- [ UInt32 ] --
types.UInt32 = {}
types.UInt32.bytes = 4
types.UInt32.write = function(c: Cursor, offset: number, value: number)
	buffer.writeu32(c.Buffer, offset, value)
end
types.UInt32.read = function(c: Cursor, offset: number)
	return buffer.readu32(c.Buffer, offset)
end

-- [ Int32 ] --
types.Int32 = {}
types.Int32.bytes = 4
types.Int32.write = function(c: Cursor, offset: number, value: number)
	buffer.writei32(c.Buffer, offset, value)
end
types.Int32.read = function(c: Cursor, offset: number)
	return buffer.readi32(c.Buffer, offset)
end

-- [ Float32 ] --
types.Float32 = {}
types.Float32.bytes = 4
types.Float32.write = function(c: Cursor, offset: number, value: number)
	buffer.writef32(c.Buffer, offset, value)
end
types.Float32.read = function(c: Cursor, offset: number)
	return buffer.readf32(c.Buffer, offset)
end

-- [ Float64 ] --
types.Float64 = {}
types.Float64.bytes = 8
types.Float64.write = function(c: Cursor, offset: number, value: number)
	buffer.writef64(c.Buffer, offset, value)
end
types.Float64.read = function(c: Cursor, offset: number)
	return buffer.readf64(c.Buffer, offset)
end

-- [ String ] --
types.String = {}
types.String.bytes = 4
types.String.write = function(c: Cursor, offset: number, value: number)
	local bytes = #value
	buffer.writeu32(c.Buffer, offset, bytes) -- Write length of this string
	buffer.writestring(c.Buffer, offset + 4, value, bytes) -- write string here
	offset += 4 + #value
end
types.String.read = function(c: Cursor, offset: number)
	local length = buffer.readu32(c.Buffer, offset) :: number
	return buffer.readstring(c.Buffer, offset + 4, length)
end

-- [ Boolean ] --
types.Boolean = {}
types.Boolean.bytes = 1
types.Boolean.write = function(c: Cursor, offset: number, value: number)
	buffer.writeu8(c.Buffer, offset, if value == true then 1 else 0)
end
types.Boolean.read = function(c: Cursor, offset: number)
	local value = buffer.readu8(c.Buffer, offset)
	return value == 1
end

-- [ Color3 ] --
types.Color3 = {}
types.Color3.bytes = 3
types.Color3.write = function(c: Cursor, offset: number, value: number)
	local R = math.floor(value.R * 255)
	local G = math.floor(value.G * 255)
	local B = math.floor(value.B * 255)

	buffer.writeu8(c.Buffer, offset, R)
	buffer.writeu8(c.Buffer, offset + 1, G)
	buffer.writeu8(c.Buffer, offset + 2, B)
end
types.Color3.read = function(c: Cursor, offset: number)
	local R
	local G
	local B

	R = buffer.readu8(c.Buffer, offset)
	G = buffer.readu8(c.Buffer, offset + 1)
	B = buffer.readu8(c.Buffer, offset + 2)

	return Color3.fromRGB(R / 255, G / 255, B / 255)
end

-- [ EnumItem ] --
types.EnumItem = {}
types.EnumItem.bytes = 2
types.EnumItem.write = function(c: Cursor, offset: number, value: number)
	local enumIndex = findEnum(value.EnumType)

	if not enumIndex then
		warn(
			`{value.EnumType} is not found. If you want write this enum to buffer, please add a enum to the "Enums" module.`
		)
		return
	end

	-- Write Name
	local bytes = #value.Name

	buffer.writeu8(c.Buffer, offset, bytes) --> 1
	buffer.writestring(c.Buffer, offset + 4, value.Name, bytes)

	-- Write Enum Parent
	buffer.writeu8(c.Buffer, offset + 1 + bytes, enumIndex) --> 1
end
types.EnumItem.read = function(c: Cursor, offset: number)
	local nameLength = buffer.readu8(c.Buffer, offset)

	local itemName = buffer.readstring(c.Buffer, offset + 1, nameLength)
	local enumIndex = buffer.readu8(c.Buffer, offset + 1 + nameLength)

	return Enums[enumIndex]:FromName(itemName)
end

-- [ Vector3 ] --
types.Vector3 = {}
types.Vector3.bytes = 12
types.Vector3.write = function(c: Cursor, offset: number, value: number)
	local X = value.X
	local Y = value.Y
	local Z = value.Z

	buffer.writef32(c.Buffer, offset, X)
	buffer.writef32(c.Buffer, offset + 4, Y)
	buffer.writef32(c.Buffer, offset + 8, Z)
end
types.Vector3.read = function(c: Cursor, offset: number)
	local X = buffer.readf32(c.Buffer, offset)
	local Y = buffer.readf32(c.Buffer, offset + 4)
	local Z = buffer.readf32(c.Buffer, offset + 8)

	return Vector3.new(X, Y, Z)
end

-- [ Vector3Int16 ] --
types.Vector3Int16 = {}
types.Vector3Int16.bytes = 6
types.Vector3Int16.write = function(c: Cursor, offset: number, value: number)
	local X = value.X
	local Y = value.Y
	local Z = value.Z

	buffer.writei16(c.Buffer, offset, X)
	buffer.writei16(c.Buffer, offset + 2, Y)
	buffer.writei16(c.Buffer, offset + 4, Z)
end
types.Vector3Int16.read = function(c: Cursor, offset: number)
	local X = buffer.readi16(c.Buffer, offset)
	local Y = buffer.readi16(c.Buffer, offset + 2)
	local Z = buffer.readi16(c.Buffer, offset + 4)

	return Vector3.new(X, Y, Z)
end

-- [ Vector2 ] --
types.Vector2 = {}
types.Vector2.bytes = 8
types.Vector2.write = function(c: Cursor, offset: number, value: number)
	local X = value.X
	local Y = value.Y

	buffer.writef32(c.Buffer, offset, X)
	buffer.writef32(c.Buffer, offset + 4, Y)
end
types.Vector2.read = function(c: Cursor, offset: number)
	local X = buffer.readf32(c.Buffer, offset)
	local Y = buffer.readf32(c.Buffer, offset + 4)

	return Vector2.new(X, Y)
end

-- [ Vector2Int16 ] --
types.Vector2Int16 = {}
types.Vector2Int16.bytes = 4
types.Vector2Int16.write = function(c: Cursor, offset: number, value: number)
	local X = value.X
	local Y = value.Y

	buffer.writei16(c.Buffer, offset, X)
	buffer.writei16(c.Buffer, offset + 2, Y)
end
types.Vector2Int16.read = function(c: Cursor, offset: number)
	local X = buffer.readi16(c.Buffer, offset)
	local Y = buffer.readi16(c.Buffer, offset + 2)

	return Vector2.new(X, Y)
end

-- [ CFrameI16I8 ] --
types.CFrameI16I8 = {}
types.CFrameI16I8.bytes = 9
types.CFrameI16I8.write = function(c: Cursor, offset: number, value: number)
	local pos = value.Position

	buffer.writei16(c.Buffer, offset, pos.X) -- 2
	buffer.writei16(c.Buffer, offset + 2, pos.Y) -- 2
	buffer.writei16(c.Buffer, offset + 4, pos.Z) -- 2

	local x, y, z = value:ToEulerAnglesXYZ()

	buffer.writei8(c.Buffer, offset + 6, math.floor(x * i8Mulit)) -- 1
	buffer.writei8(c.Buffer, offset + 7, math.floor(y * i8Mulit)) -- 1
	buffer.writei8(c.Buffer, offset + 8, math.floor(z * i8Mulit)) -- 1
end
types.CFrameI16I8.read = function(c: Cursor, offset: number)
	local X = buffer.readi16(c.Buffer, offset)
	local Y = buffer.readi16(c.Buffer, offset + 2)
	local Z = buffer.readi16(c.Buffer, offset + 4)

	local rX = buffer.readi8(c.Buffer, offset + 6) / i8Mulit
	local rY = buffer.readi8(c.Buffer, offset + 7) / i8Mulit
	local rZ = buffer.readi8(c.Buffer, offset + 8) / i8Mulit

	return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
end

-- [ CFrameF32I8 ] --
types.CFrameF32I8 = {}
types.CFrameF32I8.bytes = 15
types.CFrameF32I8.write = function(c: Cursor, offset: number, value: number)
	local pos = value.Position

	buffer.writef32(c.Buffer, offset, pos.X) -- 4
	buffer.writef32(c.Buffer, offset + 4, pos.Y) -- 4
	buffer.writef32(c.Buffer, offset + 8, pos.Z) -- 4

	local x, y, z = value:ToEulerAnglesXYZ()

	buffer.writei8(c.Buffer, offset + 12, math.floor(x * i8Mulit)) -- 1
	buffer.writei8(c.Buffer, offset + 13, math.floor(y * i8Mulit)) -- 1
	buffer.writei8(c.Buffer, offset + 14, math.floor(z * i8Mulit)) -- 1
end
types.CFrameF32I8.read = function(c: Cursor, offset: number)
	local X = buffer.readf32(c.Buffer, offset)
	local Y = buffer.readf32(c.Buffer, offset + 4)
	local Z = buffer.readf32(c.Buffer, offset + 8)

	local rX = buffer.readi8(c.Buffer, offset + 12) / i8Mulit
	local rY = buffer.readi8(c.Buffer, offset + 13) / i8Mulit
	local rZ = buffer.readi8(c.Buffer, offset + 14) / i8Mulit

	return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
end

-- [ CFrameI16I16 ] --
types.CFrameI16I16 = {}
types.CFrameI16I16.bytes = 12
types.CFrameI16I16.write = function(c: Cursor, offset: number, value: number)
	local pos = value.Position

	buffer.writei16(c.Buffer, offset, pos.X) -- 2
	buffer.writei16(c.Buffer, offset + 2, pos.Y) -- 2
	buffer.writei16(c.Buffer, offset + 4, pos.Z) -- 2

	local x, y, z = value:ToEulerAnglesXYZ()

	buffer.writei16(c.Buffer, offset + 6, math.floor(x * i16Mulit)) -- 2
	buffer.writei16(c.Buffer, offset + 8, math.floor(y * i16Mulit)) -- 2
	buffer.writei16(c.Buffer, offset + 10, math.floor(z * i16Mulit)) -- 2
end
types.CFrameI16I16.read = function(c: Cursor, offset: number)
	local X = buffer.readi16(c.Buffer, offset)
	local Y = buffer.readi16(c.Buffer, offset + 2)
	local Z = buffer.readi16(c.Buffer, offset + 4)

	local rX = buffer.readi16(c.Buffer, offset + 6) / i16Mulit
	local rY = buffer.readi16(c.Buffer, offset + 8) / i16Mulit
	local rZ = buffer.readi16(c.Buffer, offset + 10) / i16Mulit

	return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
end

-- [ CFrameF32I16 ] --
types.CFrameF32I16 = {}
types.CFrameF32I16.bytes = 18
types.CFrameF32I16.write = function(c: Cursor, offset: number, value: number)
	local pos = value.Position

	buffer.writef32(c.Buffer, offset, pos.X) -- 4
	buffer.writef32(c.Buffer, offset + 4, pos.Y) -- 4
	buffer.writef32(c.Buffer, offset + 8, pos.Z) -- 4

	local x, y, z = value:ToEulerAnglesXYZ()

	buffer.writei16(c.Buffer, offset + 12, math.floor(x * i16Mulit)) -- 2
	buffer.writei16(c.Buffer, offset + 14, math.floor(y * i16Mulit)) -- 2
	buffer.writei16(c.Buffer, offset + 16, math.floor(z * i16Mulit)) -- 2
end
types.CFrameF32I16.read = function(c: Cursor, offset: number)
	local X = buffer.readf32(c.Buffer, offset)
	local Y = buffer.readf32(c.Buffer, offset + 4) -- 4
	local Z = buffer.readf32(c.Buffer, offset + 8) -- 4 + 4

	local rX = buffer.readi16(c.Buffer, offset + 12) / i16Mulit
	local rY = buffer.readi16(c.Buffer, offset + 14) / i16Mulit
	local rZ = buffer.readi16(c.Buffer, offset + 16) / i16Mulit

	return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
end

return types
