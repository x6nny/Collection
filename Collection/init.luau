--!strict
local CollectionService = game:GetService('CollectionService')

--> types
type struct = {
	GetTagged : (struct) -> {Instance},
	tagAdded : (struct, fn : (instance : Instance) -> (), ancestors : {Instance?}?) -> (),
	tagRemoved : (struct, fn : (instance : Instance) -> (), ancestors : {Instance?}?) -> (),
	AddTag : (struct, instance : Instance) -> (),
	RemoveTag : (struct, instance : Instance) -> (),
	HasTag : (struct, instance : Instance) -> boolean,
}

--> Class
local collection = {}
collection.__index = collection

--> private
local function isAncestor(descendant : Instance, ancestors : {Instance}?) : boolean
	if ancestors == nil then return true end

	local _isAncestor = false

	for _, v in pairs(ancestors) do
		if v:IsAncestorOf(descendant) then
			_isAncestor = true
			break
		end
	end

	return _isAncestor
end

--> methods
function collection:GetTagged() : {Instance}
	return CollectionService:GetTagged(self.tag)
end

function collection:tagAdded(fn : (instance : Instance) -> (), ancestors : {Instance?}?)
	table.insert(self.tagAddedListeners, fn)
	
	for _, v : Instance in pairs(self:GetTagged()) do
		if isAncestor(v, ancestors :: any) == false then continue end
		task.spawn(fn, v)
	end
	
	if self.tagAddedConnection == nil then
		self.tagAddedConnection = CollectionService:GetInstanceAddedSignal(self.tag):Connect(function(v : Instance)
			if isAncestor(v, ancestors :: any) == false then return end
			task.spawn(fn, v)
		end)
	end
	
	return function()
		local index = table.find(self.tagAddedListeners, fn)
		if index == nil then return end
		table.remove(self.tagAddedListeners, index)
		
		if #self.tagAddedListeners == 0 then
			self.tagAddedConnection:Disconnect()
			self.tagAddedConnection = nil
		end
	end
end

function collection:tagRemoved(fn : (instance : Instance) -> (), ancestors : {Instance?}?) : () -> ()
	table.insert(self.tagAddedListeners, fn)

	if self.tagRemovedConnection == nil then
		self.tagRemovedConnection = CollectionService:GetInstanceRemovedSignal(self.tag):Connect(function(v : Instance)
			if isAncestor(v, ancestors :: any) == false then return end
			task.spawn(fn, v)
		end)
	end

	return function()
		local index = table.find(self.tagRemovedListeners, fn)
		if index == nil then return end
		table.remove(self.tagRemovedListeners, index)

		if #self.tagRemovedListeners == 0 then
			self.tagRemovedConnection:Disconnect()
			self.tagRemovedConnection = nil
		end
	end
end

function collection:AddTag(instance : Instance | {Instance})
	if typeof(instance) ~= 'table' then
		instance:AddTag(self.tag)
	else
		for _, v in pairs(instance) do
			v:AddTag(self.tag)
		end
	end
end

function collection:RemoveTag(instance : Instance | {Instance})
	if typeof(instance) ~= 'table' then
		instance:RemoveTag(self.tag)
	else
		for _, v in pairs(instance) do
			v:RemoveTag(self.tag)
		end
	end
end

function collection:HasTag(instance : Instance | {Instance}) : boolean
	if typeof(instance) ~= 'table' then
		return CollectionService:HasTag(instance, self.tag)
	else
		for _, v in pairs(instance) do
			if v:HasTag(self.tag) == false then
				return false
			end
		end
		return true
	end
end

--> return
return function(tag : string) : struct
	return setmetatable({
		tag = tag,
		
		tagAddedListeners = {},
		tagRemovedListeners = {}
	}, collection) :: any
end