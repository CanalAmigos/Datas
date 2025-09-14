local lib = {}
lib.Version = 'Ancestor_v1'
lib.Template = {type='',value={},version=lib.Version}
lib.TemplateTable = function(type,value)
	local temp = table.clone(lib.Template)
	temp.type = type
	temp.value = value
	return temp
end

function lib:TransformInJson(v: 'Primitive'): {("type" & string) | ("value" & {any}) | ("version" & string)}
	if typeof(v) ~= 'table' then
		if typeof(v) == 'CFrame' then
			return lib.TemplateTable('CFrame',{v:GetComponents()})
		elseif typeof(v) == 'Vector3' then
			return lib.TemplateTable('Vector3',{v.X,v.Y,v.Z})
		elseif typeof(v) == 'Vector2' then
			return lib.TemplateTable('Vector2',{v.X,v.Y})
		elseif typeof(v) == 'UDim' then
			return lib.TemplateTable('UDim',{v.Scale,v.Offset})
		elseif typeof(v) == 'UDim2' then
			return lib.TemplateTable('UDim2',{v.X.Scale,v.X.Offset,v.Y.Scale,v.Y.Offset})
		elseif typeof(v) == 'Color3' then
			return lib.TemplateTable('Color3',{v.R,v.G,v.B})
		elseif typeof(v) == 'BrickColor' then
			return lib.TemplateTable('BrickColor',{v.Number})
		elseif typeof(v) == 'EnumItem' then
			return lib.TemplateTable('EnumItem',{tostring(v.EnumType),v.Name})
		elseif typeof(v) == 'Ray' then
			return lib.TemplateTable('Ray',{{v.Origin.X,v.Origin.Y,v.Origin.Z},{v.Direction.X,v.Direction.Y,v.Direction.Z}})
		elseif typeof(v) == 'NumberSequence' then
			local keypoints = {}
			for _, kp in ipairs(v.Keypoints) do
				table.insert(keypoints, {kp.Time, kp.Value, kp.Envelope})
			end
			return lib.TemplateTable('NumberSequence', keypoints)
		elseif typeof(v) == 'ColorSequence' then
			local keypoints = {}
			for _, kp in ipairs(v.Keypoints) do
				table.insert(keypoints, {kp.Time, {kp.Value.R, kp.Value.G, kp.Value.B}})
			end
			return lib.TemplateTable('ColorSequence', keypoints)
		elseif typeof(v) == 'Rect' then
			return lib.TemplateTable('Rect',{v.Min.X,v.Min.Y,v.Max.X,v.Max.Y})
		elseif typeof(v) == 'Region3' then
			local min, max = v.CFrame.Position - v.Size/2, v.CFrame.Position + v.Size/2
			return lib.TemplateTable('Region3',{{min.X,min.Y,min.Z},{max.X,max.Y,max.Z}})
		elseif typeof(v) == 'NumberRange' then
			return lib.TemplateTable('NumberRange',{v.Min,v.Max})
		elseif typeof(v) == 'DateTime' then
			return lib.TemplateTable('DateTime',v.UnixTimestamp)
		elseif typeof(v) == 'Faces' then
			local faces = {}
			for _,e in pairs(Enum.NormalId:GetEnumItems()) do
				if v[e.Name] then
					table.insert(faces, e.Name)
				end
			end
			return lib.TemplateTable('Faces',faces)
		elseif typeof(v) == 'PhysicalProperties' then
			return lib.TemplateTable('PhysicalProperties',{v.Density,v.Friction,v.Elasticity,v.FrictionWeight,v.ElasticityWeight})
		elseif typeof(v) == 'number' then
			local string = tostring(v)
			if string:find('inf',1,true) or string == 'nan' then
				return lib.TemplateTable('number',string)
			end
		end
	elseif typeof(v) == 'table' and (not v.version or v.version ~= lib.Version) then
		local t = {}
		for i,e in pairs(v) do
			t[i] = lib:TransformInJson(e)
		end
		return t
	end
	return v
end

function lib:UnTransformJson(v: {("type" & string) | ("value" & {any}) | ("version" & string)})
	if typeof(v) == 'table' and v.type ~= nil and (v.version ~= nil and v.version == lib.Version) then
		if v.type == 'CFrame' then
			return CFrame.new(unpack(v.value))
		elseif v.type == 'Vector3' then
			return Vector3.new(unpack(v.value))
		elseif v.type == 'Vector2' then
			return Vector2.new(unpack(v.value))
		elseif v.type == 'UDim' then
			return UDim.new(unpack(v.value))
		elseif v.type == 'UDim2' then
			return UDim2.new(unpack(v.value))
		elseif v.type == 'Color3' then
			return Color3.new(unpack(v.value))
		elseif v.type == 'BrickColor' then
			return BrickColor.new(v.value[1])
		elseif v.type == 'EnumItem' then
			return Enum[v.value[1]][v.value[2]]
		elseif v.type == 'Ray' then
			return Ray.new(Vector3.new(unpack(v.value[1])),Vector3.new(unpack(v.value[2])))
		elseif v.type == 'NumberSequence' then
			local keypoints = {}
			for _, kpData in ipairs(v.value) do
				table.insert(keypoints, NumberSequenceKeypoint.new(kpData[1], kpData[2], kpData[3] or 0))
			end
			return NumberSequence.new(keypoints)
		elseif v.type == 'ColorSequence' then
			local keypoints = {}
			for _, kpData in ipairs(v.value) do
				local color = Color3.new(kpData[2][1], kpData[2][2], kpData[2][3])
				table.insert(keypoints, ColorSequenceKeypoint.new(kpData[1], color))
			end
			return ColorSequence.new(keypoints)
		elseif v.type == 'Rect' then
			return Rect.new(unpack(v.value))
		elseif v.type == 'Region3' then
			return Region3.new(Vector3.new(unpack(v.value[1])),Vector3.new(unpack(v.value[2])))
		elseif v.type == 'NumberRange' then
			return NumberRange.new(unpack(v.value))
		elseif v.type == 'DateTime' then
			return DateTime.fromUnixTimestamp(v.value)
		elseif v.type == 'Faces' then
			for i,e in pairs(v.value) do
				v.value[i] = Enum.NormalId[e]
			end
			return Faces.new(unpack(v.value))
		elseif v.type == 'PhysicalProperties' then
			return PhysicalProperties.new(unpack(v.value))
		elseif v.type == 'number' then
			return (v.value == 'nan' and math.huge-math.huge) or (v.value:sub(1,1) == '-' and -math.huge) or math.huge
		end
	elseif typeof(v) == 'table' and (not v.version or v.version ~= lib.Version) then
		local t = {}
		for i,e in pairs(v) do
			t[i] = lib:UnTransformJson(e)
		end
		return t
	end
	return v
end

return lib
