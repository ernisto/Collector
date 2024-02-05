--!strict
export type params = { lifetime: number? }

export type Collector = {
	collect: (self: Collector) -> (),
	destroy: (self: Collector) -> (),
	add: <T...>(self: Collector, T...) -> T...,
	remove: <T...>(self: Collector, T...) -> T...,
	sub: (self: Collector, params: params?) -> Collector,
}

local function Collector(params: params?): Collector

	local items = {} :: {[any]: true}
	local self = {} :: Collector

	--// Methods
	function self:destroy() return self:collect() end --// alias
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
	function self:add<T...>(...: T...): T...

		for _,item in {select(1, ...)} do items[item] = true end
		return ...
	end
	function self:remove<T...>(...: T...): T...

		for _,item in {select(1, ...)} do items[item] = nil end
		return ...
	end
	function self:sub(params: params?): Collector

		return self:add(Collector(params))
	end

	--// Setup
	if params and params.lifetime then self:add(task.delay(params.lifetime, function() self:collect() end)) end

	--// End
	return self
end

--// End
return Collector
