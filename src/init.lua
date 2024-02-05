--!strict

export type Collector = {
	collect: (self: Collector) -> (),
	destroy: (self: Collector) -> (),
	add: (self: Collector, ...any) -> ...any,
	remove: (self: Collector, ...any) -> ...any,
	sub: (self: Collector, lifetime: number?) -> Collector,
}

local function Collector(lifetime: number?): Collector

	local items = {} :: {[any]: true}
	local self = {} :: Collector

	--// Methods
	function self:destroy() self:collect() end --// alias
	function self:collect()

		for item in items do

			if typeof(item) == "thread" then if coroutine.status(item) == 'suspended' then coroutine.close(item) end
			elseif typeof(item) == "RBXScriptConnection" then item:Disconnect()
			elseif typeof(item) == "Instance" then item:Destroy()
			elseif typeof(item) == 'function' then task.spawn(item)
			elseif typeof(item) == "table" then
				if typeof(rawget(item, "cancel")) == "function" then item:cancel()
				elseif typeof(rawget(item, "Cancel")) == "function" then item:Cancel()
				elseif typeof(rawget(item, "destroy")) == "function" then item:destroy()
				elseif typeof(rawget(item, "Destroy")) == "function" then item:Destroy()
				elseif typeof(rawget(item, "disconnect")) == "function" then item:disconnect()
				elseif typeof(rawget(item, "Disconnect")) == "function" then item:Disconnect()
				end
			end
		end

		table.clear(items)
	end
	function self:add(...: any)

		for _,item in {...} do items[item] = true end
		return ...
	end
	function self:remove(...: any)

		for _,item in {...} do items[item] = nil end
		return ...
	end
	function self:sub(lifetime: number?)

		return self:add(Collector(lifetime))
	end

	--// Setup
	if lifetime then self:add(task.delay(lifetime, function() self:collect() end)) end

	--// End
	return self
end

--// End
return Collector
