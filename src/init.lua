export type params = { lifetime: number? }

local function Collector(params: params)
    
    local items = {}
    local self = { hasCollected = false }
    
    --// Methods
    function self:destroy() return self:collect() end
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
        self.hasCollected = true
        table.clear(items)
    end
    
    function self:add(...: any)
        
        assert(not self.hasCollected, `already collected`)
        
        for _,item in {...} do items[item] = true end
        return ...
    end
    function self:sub(params: params)
        
        assert(not self.hasCollected, `already collected`)
        return self:add(Collector(params))
    end
    
    --// Setup
    if params.lifetime then self:add(task.delay(params.lifetime, function() self:collect() end)) end
    
    --// End
    return self
end

--// End
return Collector