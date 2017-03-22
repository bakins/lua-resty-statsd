local _M = {}

require "resty.core"

local mt = { __index = _M }

function _M.new(options)
    options = options or {}
    local self = {
        host = options.host or "127.0.0.1",
        port = options.port or 8125,
        namespace = options.namespace,
        tags = options.tags or {},
        timeout = options.timeout or 250,
        queue = {},
        delay = (options.delay or 500) / 1000,
        timer_started = false
    }
    return setmetatable(self, mt)
end

local concat = table.concat

local function create_message(self, key, value, kind, sample_rate, tags)
    local rate = ""
    if sample_rate and sample_rate ~= 1 then
        rate = "|@"..sample_rate
    end

    local tag_string = ""
    local self_tags = self.tags
    if tags and self_tags then
        tag_string = "|#" .. self_tags .. "," .. tags
    else
        if self_tags then
            tag_string = "|#" .. self_tags
        else
            if tags then
                tag_string = "|#" .. tags
            end
        end
    end

    local message = {
        self.namespace,
        ".",
        key,
        ":",
        value,
        "|",
        kind,
        rate,
        tag_string,
        "\n"
    }
    return message
end

local send_messages

local function set_timer(self)
    if not self.timer_started then
        local ok, err = ngx.timer.at(self.delay, send_messages, self)
        self.timer_started = ok
    end
end

local remove = table.remove
send_messages = function(premature, self)
    if premature then
        return
    end
    -- mark as not started. openresty has no "repeat" so we must do logic ourselves
    self.timer_started = false

    local sock = ngx.socket.udp()
    local ok, err = sock:setpeername(self.host, self.port)
    if not ok then
        ngx.log(ngx.ERR, "setpeername failed for ", self.host, ":", self.port, " => ", err)
        self.queue = {}
        set_timer(self)
        return
    end

    sock:settimeout(self.timeout)

    local q = self.queue
    for i=1,#q do
        local message = q[i]
        local ok, err = sock:send(message)
        if not ok then
            ngx.log(ngx.ERR, "send failed for ", self.host, ":", self.port, " => ", err)
        end
    end
    sock:close()
    self.queue = {}
    set_timer(self)
end

local insert = table.insert
local function queue(self, key, value, kind, sample_rate, tags)
    local message = create_message(self, key, value, kind, sample_rate, tags)
    insert(self.queue, message)
    set_timer(self)
end

function _M.gauge(self, key, value, sample_rate, tags)
    return queue(self, key, value, "g", sample_rate, tags)
end

function _M.count(self, key, value, sample_rate, tags)
    return queue(self, key, value, "c", sample_rate, tags)
end

function _M.timing(self, key, value, tags)
    return queue(self, key, value, "ms", nil, tags)
end

return _M
