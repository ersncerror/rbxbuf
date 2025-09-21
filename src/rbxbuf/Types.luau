type Cursor = {
	__index: Cursor,

	Buffer: buffer,
	Offset: number,
	Max: number,
}

export type TypeFunc<T> = (c: Cursor, value: T) -> any

export type DataType = {
	read: TypeFunc,
	write: TypeFunc,
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

return {
	["UInt8"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu8(c.Buffer, c.Offset, value)
			c.Offset += 1
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readu8(c.Buffer, offset)
		end,
	},
	["Int8"] = {
		write = function(c: Cursor, value: number)
			buffer.writei8(c.Buffer, c.Offset, value)
			c.Offset += 1
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readi8(c.Buffer, offset)
		end,
	},
	["UInt16"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu16(c.Buffer, c.Offset, value)
			c.Offset += 2
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readu16(c.Buffer, offset)
		end,
	},
	["Int16"] = {
		write = function(c: Cursor, value: number)
			buffer.writei16(c.Buffer, c.Offset, value)
			c.Offset += 2
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readi16(c.Buffer, offset)
		end,
	},
	["UInt32"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu32(c.Buffer, c.Offset, value)
			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readu32(c.Buffer, offset)
		end,
	},
	["Int32"] = {
		write = function(c: Cursor, value: number)
			buffer.writei32(c.Buffer, c.Offset, value)
			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readi32(c.Buffer, offset)
		end,
	},
	["Float32"] = {
		write = function(c: Cursor, value: number)
			buffer.writef32(c.Buffer, c.Offset, value)
			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readf32(c.Buffer, offset)
		end,
	},
	["Float64"] = {
		write = function(c: Cursor, value: number)
			buffer.writef64(c.Buffer, c.Offset, value)
			c.Offset += 8
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readf64(c.Buffer, offset)
		end,
	},
	["String"] = {
		write = function(c: Cursor, value: string)
			local bytes = #value
			buffer.writeu32(c.Buffer, c.Offset, bytes) -- Write length of this string
			buffer.writestring(c.Buffer, c.Offset + 4, value, bytes) -- write string here
			c.Offset += 4 + #value
		end,
		read = function(c: Cursor, offset: number)
			local length = buffer.readu32(c.Buffer, offset) :: number
			return buffer.readstring(c.Buffer, offset + 4, length)
		end,
	},
	["Boolean"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu8(c.Buffer, c.Offset, if value == true then 1 else 0)
			c.Offset += 1
		end,
		read = function(c: Cursor, offset: number)
			local value = buffer.readu8(c.Buffer, offset)
			return if value == 1 then true else false
		end,
	},
	["Color3"] = {
		write = function(c: Cursor, value: Color3)
			local R = math.floor(value.R * 255)
			local G = math.floor(value.G * 255)
			local B = math.floor(value.B * 255)

			buffer.writeu8(c.Buffer, c.Offset, R)
			buffer.writeu8(c.Buffer, c.Offset + 1, G)
			buffer.writeu8(c.Buffer, c.Offset + 2, B)

			print("Write RGB:", R, G, B)
			c.Offset += 3
		end,

		read = function(c: Cursor, offset: number)
			local R
			local G
			local B

			R = buffer.readu8(c.Buffer, offset)
			G = buffer.readu8(c.Buffer, offset + 1)
			B = buffer.readu8(c.Buffer, offset + 2)

			return Color3.fromRGB(R / 255, G / 255, B / 255)
		end,
	},
	["EnumItem"] = {
		write = function(c: Cursor, value: EnumItem)
			local enumIndex = findEnum(value.EnumType)

			if not enumIndex then
				warn(
					`{value.EnumType} is not found. If you want write this enum to buffer, please add a enum to the "Enums" module.`
				)
				return
			end

			-- Write Name
			local bytes = #value.Name

			buffer.writef32(c.Buffer, c.Offset, bytes)
			buffer.writestring(c.Buffer, c.Offset + 4, value.Name, bytes)

			-- Write Enum Parent
			buffer.writeu8(c.Buffer, c.Offset + 4 + bytes, enumIndex)
			c.Offset += 4 + bytes + 1
		end,
		read = function(c: Cursor, offset: number)
			local nameLength = buffer.readf32(c.Buffer, offset)

			local itemName = buffer.readstring(c.Buffer, offset + 4, nameLength)
			local enumIndex = buffer.readu8(c.Buffer, offset + 4 + nameLength)

			return Enums[enumIndex]:FromName(itemName)
		end,
	},
	["Vector3"] = {
		write = function(c: Cursor, value: Vector3)
			local X = value.X
			local Y = value.Y
			local Z = value.Z

			buffer.writef32(c.Buffer, c.Offset, X)
			buffer.writef32(c.Buffer, c.Offset + 4, Y)
			buffer.writef32(c.Buffer, c.Offset + 8, Z)

			c.Offset += 12
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readf32(c.Buffer, offset)
			local Y = buffer.readf32(c.Buffer, offset + 4)
			local Z = buffer.readf32(c.Buffer, offset + 8)

			return Vector3.new(X, Y, Z)
		end,
	},
	["Vector3Int16"] = {
		write = function(c: Cursor, value: Vector3)
			local X = value.X
			local Y = value.Y
			local Z = value.Z

			buffer.writei16(c.Buffer, c.Offset, X)
			buffer.writei16(c.Buffer, c.Offset + 2, Y)
			buffer.writei16(c.Buffer, c.Offset + 4, Z)

			c.Offset += 6
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readi16(c.Buffer, offset)
			local Y = buffer.readi16(c.Buffer, offset + 2)
			local Z = buffer.readi16(c.Buffer, offset + 4)

			return Vector3.new(X, Y, Z)
		end,
	},
	["Vector2"] = {
		write = function(c: Cursor, value: Vector2)
			local X = value.X
			local Y = value.Y

			buffer.writef32(c.Buffer, c.Offset, X)
			buffer.writef32(c.Buffer, c.Offset + 4, Y)

			c.Offset += 8
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readf32(c.Buffer, offset)
			local Y = buffer.readf32(c.Buffer, offset + 4)

			return Vector2.new(X, Y)
		end,
	},
	["Vector2Int16"] = {
		write = function(c: Cursor, value: Vector2)
			local X = value.X
			local Y = value.Y

			buffer.writei16(c.Buffer, c.Offset, X)
			buffer.writei16(c.Buffer, c.Offset + 2, Y)

			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readi16(c.Buffer, offset)
			local Y = buffer.readi16(c.Buffer, offset + 2)

			return Vector2.new(X, Y)
		end,
	},
	["CFrameI16I8"] = {
		write = function(c: Cursor, value: CFrame)
			local pos = value.Position

			buffer.writei16(c.Buffer, c.Offset, pos.X) -- 2
			buffer.writei16(c.Buffer, c.Offset + 2, pos.Y) -- 2
			buffer.writei16(c.Buffer, c.Offset + 4, pos.Z) -- 2

			local x, y, z = value:ToEulerAnglesXYZ()

			buffer.writei8(c.Buffer, c.Offset + 6, math.floor(x * i8Mulit)) -- 1
			buffer.writei8(c.Buffer, c.Offset + 7, math.floor(y * i8Mulit)) -- 1
			buffer.writei8(c.Buffer, c.Offset + 8, math.floor(z * i8Mulit)) -- 1

			c.Offset += 9
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readi16(c.Buffer, offset)
			local Y = buffer.readi16(c.Buffer, offset + 2)
			local Z = buffer.readi16(c.Buffer, offset + 4)

			local rX = buffer.readi8(c.Buffer, offset + 6) / i8Mulit
			local rY = buffer.readi8(c.Buffer, offset + 7) / i8Mulit
			local rZ = buffer.readi8(c.Buffer, offset + 8) / i8Mulit

			return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
		end,
	},
	["CFrameF32I8"] = {
		write = function(c: Cursor, value: CFrame)
			local pos = value.Position

			buffer.writef32(c.Buffer, c.Offset, pos.X) -- 4
			buffer.writef32(c.Buffer, c.Offset + 4, pos.Y) -- 4
			buffer.writef32(c.Buffer, c.Offset + 8, pos.Z) -- 4

			local x, y, z = value:ToEulerAnglesXYZ()

			buffer.writei8(c.Buffer, c.Offset + 12, math.floor(x * i8Mulit)) -- 1
			buffer.writei8(c.Buffer, c.Offset + 13, math.floor(y * i8Mulit)) -- 1
			buffer.writei8(c.Buffer, c.Offset + 14, math.floor(z * i8Mulit)) -- 1

			c.Offset += 15
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readf32(c.Buffer, offset)
			local Y = buffer.readf32(c.Buffer, offset + 4)
			local Z = buffer.readf32(c.Buffer, offset + 8)

			local rX = buffer.readi8(c.Buffer, offset + 12) / i8Mulit
			local rY = buffer.readi8(c.Buffer, offset + 13) / i8Mulit
			local rZ = buffer.readi8(c.Buffer, offset + 14) / i8Mulit

			return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
		end,
	},
	["CFrameI16I16"] = {
		write = function(c: Cursor, value: CFrame)
			local pos = value.Position

			buffer.writei16(c.Buffer, c.Offset, pos.X) -- 2
			buffer.writei16(c.Buffer, c.Offset + 2, pos.Y) -- 2
			buffer.writei16(c.Buffer, c.Offset + 4, pos.Z) -- 2

			local x, y, z = value:ToEulerAnglesXYZ()

			buffer.writei16(c.Buffer, c.Offset + 6, math.floor(x * i16Mulit)) -- 2
			buffer.writei16(c.Buffer, c.Offset + 8, math.floor(y * i16Mulit)) -- 2
			buffer.writei16(c.Buffer, c.Offset + 10, math.floor(z * i16Mulit)) -- 2

			c.Offset += 12
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readi16(c.Buffer, offset)
			local Y = buffer.readi16(c.Buffer, offset + 2)
			local Z = buffer.readi16(c.Buffer, offset + 4)

			local rX = buffer.readi16(c.Buffer, offset + 6) / i16Mulit
			local rY = buffer.readi16(c.Buffer, offset + 8) / i16Mulit
			local rZ = buffer.readi16(c.Buffer, offset + 10) / i16Mulit

			return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
		end,
	},
	["CFrameF32I16"] = {
		write = function(c: Cursor, value: CFrame)
			local pos = value.Position

			buffer.writef32(c.Buffer, c.Offset, pos.X) -- 4
			buffer.writef32(c.Buffer, c.Offset + 4, pos.Y) -- 4
			buffer.writef32(c.Buffer, c.Offset + 8, pos.Z) -- 4

			local x, y, z = value:ToEulerAnglesXYZ()

			buffer.writei16(c.Buffer, c.Offset + 12, math.floor(x * i16Mulit)) -- 2
			buffer.writei16(c.Buffer, c.Offset + 14, math.floor(y * i16Mulit)) -- 2
			buffer.writei16(c.Buffer, c.Offset + 16, math.floor(z * i16Mulit)) -- 2

			c.Offset += 18
		end,
		read = function(c: Cursor, offset: number)
			local X = buffer.readf32(c.Buffer, offset)
			local Y = buffer.readf32(c.Buffer, offset + 4) -- 4
			local Z = buffer.readf32(c.Buffer, offset + 8) -- 4 + 4

			local rX = buffer.readi16(c.Buffer, offset + 12) / i16Mulit
			local rY = buffer.readi16(c.Buffer, offset + 14) / i16Mulit
			local rZ = buffer.readi16(c.Buffer, offset + 16) / i16Mulit

			return CFrame.fromEulerAnglesXYZ(rX, rY, rZ) + Vector3.new(X, Y, Z)
		end,
	},
}
