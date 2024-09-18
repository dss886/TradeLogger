local _, Addon = ...

local EventBus = {};
local CallbackCenter = {};
local CUSTOM_EVENT_PREFIX = "TL_";

----------------------------------------
--             事件代理函数             --
----------------------------------------

local EventFrame = CreateFrame("Frame", nil)
EventFrame:Hide()
EventFrame:SetScript("OnEvent", function(self, event, ...)
    EventBus.Post(event, ...);
end)

----------------------------------------
--             外部接口函数             --
----------------------------------------

function EventBus.Register(event, callback)
    if callback ~= nil and type(callback) == "function" then
        if string.sub(event, 1, #CUSTOM_EVENT_PREFIX) ~= CUSTOM_EVENT_PREFIX
            and not EventFrame:IsEventRegistered(event) then
            EventFrame:RegisterEvent(event);
        end
        CallbackCenter[event] = CallbackCenter[event] or {};
        local callbacks = CallbackCenter[event];
        for index = 1, #callbacks do
            if callbacks[index] == callback then
                return;
            end
        end
        callbacks[#callbacks + 1] = callback;
    end
end

function EventBus.Unregister(event, callback)
    local callbacks = CallbackCenter[event];
    if callbacks ~= nil and callback ~= nil and type(callback) == "function" then
        for index = #callbacks, 1, -1 do
            if callbacks[index] == callback then
                tremove(callbacks, index);
            end
        end
    end
end

function EventBus.Post(event, ...)
    local callbacks = CallbackCenter[event];
    if callbacks ~= nil then
        for index = #callbacks, 1, -1 do
            callbacks[index](...);
        end
    end
end

----------------------------------------
--         对其他模块暴露的接口          --
----------------------------------------

Addon.EventBus = EventBus;