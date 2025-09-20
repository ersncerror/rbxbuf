type Cursor = {
	__index: Cursor,

	Buffer: buffer,
	Offset: number,
	Max: number,
}

export type TypeFunc<T> = (c: Cursor, value: T) -> ()

export type DataType = {
	read: TypeFunc,
	write: TypeFunc,
}

return {
	["U8"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu8(c.Buffer, c.Offset, value)
			c.Offset += 1
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readu8(c.Buffer, offset)
		end,
	},
	["I8"] = {
		write = function(c: Cursor, value: number)
			buffer.writei8(c.Buffer, c.Offset, value)
			c.Offset += 2
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readi8(c.Buffer, offset)
		end,
	},
	["U16"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu16(c.Buffer, c.Offset, value)
			c.Offset += 2
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readu16(c.Buffer, offset)
		end,
	},
	["I16"] = {
		write = function(c: Cursor, value: number)
			buffer.writei16(c.Buffer, c.Offset, value)
			c.Offset += 2
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readi16(c.Buffer, offset)
		end,
	},
	["U32"] = {
		write = function(c: Cursor, value: number)
			buffer.writeu32(c.Buffer, c.Offset, value)
			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readu32(c.Buffer, offset)
		end,
	},
	["I32"] = {
		write = function(c: Cursor, value: number)
			buffer.writei32(c.Buffer, c.Offset, value)
			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readi32(c.Buffer, offset)
		end,
	},
	["F32"] = {
		write = function(c: Cursor, value: number)
			buffer.writef32(c.Buffer, c.Offset, value)
			c.Offset += 4
		end,
		read = function(c: Cursor, offset: number)
			return buffer.readf32(c.Buffer, offset)
		end,
	},
	["F64"] = {
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
}
