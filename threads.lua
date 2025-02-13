-- class's resource's
Threads = { };
Threads.__mode, Threads.__index = 'k', Threads;

Threads.__elements = { };

-- util's resource's
local function generateUUID ()
    local template = 'xxxxxxxx-xxxx-4xxx';
    local id = template:gsub ('[x]',
        function ()
            local random = math.random (0, 0xf);
            return ('%x'):format (random);
        end
    );

    local timestamp = ('%x'):format (getTickCount ());
    return id .. '-' .. timestamp;
end

-- method's resource's
function Threads.new (func, delay)
    if (type (func) ~= 'function') then
        return false;
    end

    local self = setmetatable ({ }, Threads);
    self.id = generateUUID ();

    self.callback = func;
    self.coroutine = coroutine.create (self.callback);

    self.paused = false;
    self.status = 'created';

    self.delay = (delay or 0);
    self.lastInterval = 0;
    self.currentInterval = 0;

    self.timer = setTimer (
        function ()
            return self:resume ();
        end, self.delay, 0
    );

    self.error = nil;

    Threads.__elements[self.id] = self;

    return self;
end

function Threads.yield (milliseconds)
    milliseconds = tonumber (milliseconds);
    if (not milliseconds) then
        return false;
    end

    return coroutine.yield (milliseconds or 0);
end

function Threads.destroyAll ()
    local threads = Threads.__elements;
    if (table.size (threads) < 1) then
        return false;
    end

    for _, thread in pairs (threads) do
        thread:destroy ();
    end
    Threads.__elements = { };

    return true;
end

function Threads:destroy ()
    if (not self.coroutine) then
        return false;
    end

    self.status, self.coroutine = 'dead', nil;
    if (isTimer (self.timer)) then
        killTimer (self.timer);
    end
    Threads.__elements[self.id] = nil;

    collectgarbage ('collect');

    return true;
end

function Threads:resume ()
    if (self.paused) or (self.status == 'dead') then
        return false;
    end

    local tickNow = getTickCount ();
    if (self.currentInterval > 0) then
        local elapsed = (tickNow - self.lastInterval);
        if (elapsed < self.currentInterval) then
            return true;
        end

        self.currentInterval = 0;
    end

    local success, result = coroutine.resume (self.coroutine);
    if (self.coroutine) then
        self.status = coroutine.status (self.coroutine);
    end

    if (not success) then
        self.error = result;

        self:destroy ();
        return false, result;
    end

    if (type (result) == 'number') and (result > 0) then
        self.currentInterval, self.lastInterval = result, tickNow;
    end

    if (self.status == 'dead') then
        self:destroy ();
    end

    return true, result;
end

function Threads:get ()
    return {
        id = self.id,
        delay = self.delay,

        paused = self.paused,
        status = self.status,

        error = self.error,
    };
end

function Threads:setDelay (milliseconds)
    milliseconds = tonumber (milliseconds);
    if (not milliseconds) then
        return false;
    end

    local data = self:get ();
    if (data.delay == milliseconds) then
        return false;
    end
    self.delay = milliseconds;

    if (isTimer (self.timer)) then
        killTimer (self.timer);
    end

    self.timer = setTimer (
        function ()
            return self:resume ();
        end, self.delay, 0
    );
    
    return true;
end

function Threads:setPause (state)
    if (type (state) ~= 'boolean') then
        return false;
    end

    if (self.paused == state) then
        return false;
    end
    self.paused = state;
    
    return true;
end
