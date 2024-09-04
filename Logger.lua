local _, Addon = ...

local Logger = {};

Logger.LEVEL = {
    ["DEBUG"] = 0,
    ["INFO"] = 1,
    ["WARN"] = 2,
    ["ERROR"] = 3,
}

local LEVEL_COLOR = {
    ["DEBUG"] = "|cFFBBBBBB",
    ["INFO"] = "|cFF00FF00",
    ["WARN"] = "|cFFFFFF00",
    ["ERROR"] = "|cFFFF0000",
}

local LOGGER_TEMPLATE = "|cFFBBBBBB<|cFF00CCFFTradeLogger|cFFBBBBBB>: %s%s|r";

function Logger.PrintImpl(content, deps)
    if type(content) == "function" then
        return "[function]";
    elseif type(content) == "table" then
        local str = "{";
        local indent = string.rep(" ", deps * 4);
        local indent2 = string.rep(" ", (deps + 1) * 4);
        for k, v in pairs(content) do
            str = str .. format("|n%s%s: %s", indent2, k, Logger.PrintImpl(v, deps + 1));
        end
        str = str .. format("|n%s%s", indent, "}");
        return str;
    else
        return tostring(content);
    end
end
function Logger.Info(content)
    local config = TradeLoggerDB.config;
    if config.logLevel <= Logger.LEVEL.INFO then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.INFO, Logger.PrintImpl(content, 0)));
    end
end
function Logger.Debug(content)
    local config = TradeLoggerDB.config;
    if config.logLevel <= Logger.LEVEL.DEBUG then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.DEBUG, Logger.PrintImpl(content, 0)));
    end
end
function Logger.Warn(content)
    local config = TradeLoggerDB.config;
    if config.logLevel <= Logger.LEVEL.WARN then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.WARN, Logger.PrintImpl(content, 0)));
    end
end
function Logger.Error(content)
    if Addon.Config.logLevel <= Logger.LEVEL.ERROR then
        print(format(LOGGER_TEMPLATE, LEVEL_COLOR.ERROR, Logger.PrintImpl(content, 0)));
    end
end

Addon.Logger = Logger;