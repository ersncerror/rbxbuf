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
}
