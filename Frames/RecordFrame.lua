local AddonName, Addon = ...

local L = Addon.L
local Logger = Addon.Logger
local EventBus = Addon.EventBus
local Template = Addon.Template
local tinsert = table.insert
local tremove = table.remove

local TABLE_COLS = {
    { name = "serial", width = 32 },
    { name = "time",   width = 120 },
    { name = "target", width = 88 },
    { name = "type",   width = 48 },
    { name = "location", width = 64 },
    { name = "money",  width = 80 },
    { name = "giveItems",  width = 180 },
    { name = "receiveItems",  width = 180 },
}
local TITLE_BAR_HEIGHT = 32
local TABLE_ROW_HEIGHT = 32
local TABLE_ROW_COUNT = 10
local TABLE_ROW_CHECK_BTN_SIZE = 24
local TABLE_DIVIDER = 1
local ACTION_BAR_HEIGHT = 32

local Frame
local Dirty = true
local CurPage = 1
local CurRecords = {}
local SelectedRecords = {}

local Data = {}
local Action = {}
local Builder = {}

----------------------------------------
--              UI初始化               --
----------------------------------------

-- 创建主窗口
function Builder.InitFrame()
    if Frame then
        return
    end
    local frame = Builder.CreateMainFrame()
    Builder.CreateTitleBar(frame)
    Builder.CreateTable(frame)
    Builder.CreateActionBar(frame)
    Builder.CreateToolTip(frame)
    Frame = frame
end

-- 创建窗口容器
function Builder.CreateMainFrame()
    local frameName = AddonName .. "RecordFrame"
    local frame = Template.CreateBackDropFrame(frameName, UIParent, { 0, 0, 0, 0.7 })
    -- 确保不让鼠标穿透窗口
    frame:SetFrameStrata("DIALOG")
    frame:EnableMouse(true)
    frame:SetClampedToScreen(true)
    frame:SetPoint("CENTER", 0, 64)
    frame:SetMovable(true)
    frame:SetUserPlaced(true)
    frame:SetDontSavePosition(false)
    frame:SetScript("OnShow", Action.OnFrameShow)
    frame:SetScript("OnHide", Action.OnFrameHide)
    -- 确保窗口可以在按下Esc时关闭
    table.insert(UISpecialFrames, frameName)
    local height = TITLE_BAR_HEIGHT + ACTION_BAR_HEIGHT
        + TABLE_ROW_HEIGHT * (TABLE_ROW_COUNT + 1) + TABLE_DIVIDER
    local width = 0
    for _, col in ipairs(TABLE_COLS) do
        width = width + col.width
    end
    frame:SetSize(width, height)
    frame:Hide()
    return frame
end

-- 创建标题栏
function Builder.CreateTitleBar(frame)
    local titleBar = CreateFrame("Frame", nil, frame)
    titleBar:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, 0)
    titleBar:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, 0)
    titleBar:SetHeight(TITLE_BAR_HEIGHT)
    titleBar:EnableMouse(true)
    titleBar:SetScript("OnMouseDown", function(_, button)
        if button == "LeftButton" then
            frame:StartMoving()
        end
    end)
    titleBar:SetScript("OnMouseUp", function(_, button)
        if button == "LeftButton" then
            frame:StopMovingOrSizing()
        end
    end)
    -- 分割线
    local divider = Template.CreateDivider(titleBar)
    divider:SetPoint("BOTTOMLEFT", titleBar, "BOTTOMLEFT", 1, 0)
    divider:SetPoint("BOTTOMRIGHT", titleBar, "BOTTOMRIGHT", -1, 0)
    -- 标题
    local title = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    title:SetText("|cFF00CCFF" .. AddonName)
    title:SetPoint("CENTER", titleBar, "CENTER", 0, 0)
    title:SetFont(STANDARD_TEXT_FONT, 14)
    -- 版本号
    local version = titleBar:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    version:SetText("|cFF888888v" .. C_AddOns.GetAddOnMetadata(AddonName, "Version"))
    version:SetPoint("LEFT", title, "RIGHT", 8, -1)
    version:SetFont(STANDARD_TEXT_FONT, 12)
    -- 关闭按钮
    local closeButton = CreateFrame("Button", nil, titleBar, "UIPanelCloseButton")
    closeButton:SetSize(32, 32)
    closeButton:SetPoint("RIGHT", titleBar, "RIGHT", -4, 0)
    closeButton:SetScript("OnClick", function() frame:Hide(); end)
    frame.titleBar = titleBar
end

-- 创建表格
function Builder.CreateTable(frame)
    local table = Template.CreateBackDropFrame(nil, frame, { 0, 0, 0, 0.3 })
    table:SetPoint("TOPLEFT", frame.titleBar, "BOTTOMLEFT", 0, 0)
    table:SetPoint("TOPRIGHT", frame.titleBar, "TOPRIGHT", 0, 0)
    table:SetHeight(TABLE_ROW_HEIGHT * (TABLE_ROW_COUNT + 1) + TABLE_DIVIDER)
    Builder.CreateTableHeader(frame, table)
    table.rows = {}
    for i = 1, TABLE_ROW_COUNT do
        local row = Builder.CreateTableRow(table)
        row:SetPoint("TOPLEFT", table, "TOPLEFT", 0, -TABLE_ROW_HEIGHT * i)
        row:SetPoint("TOPRIGHT", table, "TOPRIGHT", 0, -TABLE_ROW_HEIGHT * i)
        table.rows[i] = row
    end
    -- 分割线
    local divider = Template.CreateDivider(table)
    divider:SetPoint("BOTTOMLEFT", table, "BOTTOMLEFT", 1, 0)
    divider:SetPoint("BOTTOMRIGHT", table, "BOTTOMRIGHT", -1, 0)
    frame.table = table
end

-- 创建表格头
function Builder.CreateTableHeader(frame, table)
    local header = CreateFrame("Frame", nil, table)
    header:SetPoint("TOPLEFT", table, "TOPLEFT", 0, 0)
    header:SetPoint("TOPRIGHT", table, "TOPRIGHT", 0, 0)
    header:SetHeight(TABLE_ROW_HEIGHT)
    header:EnableMouse(true)
    -- 字段
    local left = 0
    local keyPrefix = "recordFrameTableHeader"
    local remainWidth = header:GetWidth()
    for i, col in ipairs(TABLE_COLS) do
        -- 序号的位置是一个CheckButton
        if i == 1 then
            local selectAllBtn = CreateFrame("CheckButton", nil, header, "ChatConfigCheckButtonTemplate")
            selectAllBtn:SetPoint("LEFT", header, "LEFT", (col.width - TABLE_ROW_CHECK_BTN_SIZE) / 2, 0)
            selectAllBtn:SetSize(TABLE_ROW_CHECK_BTN_SIZE, TABLE_ROW_CHECK_BTN_SIZE)
            selectAllBtn:SetWidth(TABLE_ROW_CHECK_BTN_SIZE)
            selectAllBtn:SetChecked(false)
            selectAllBtn:SetScript("OnClick", function ()
                if selectAllBtn:GetChecked() then
                    Action.OnActionSelectAllClick()
                else
                    Action.OnActionSelectClearClick()
                end
            end)
            frame.selectAllBtn = selectAllBtn
        else
            local string = Template.CreateTableHeader(header, L[keyPrefix..col.name:gsub("^%l", string.upper)], 30,
            col.width == -1 and remainWidth or col.width)
            string:SetPoint("LEFT", header, "LEFT", left, 0)
        end
        left = left + col.width
        remainWidth = remainWidth - col.width
    end
    frame.tabHeader = header
end

-- 创建表格行
function Builder.CreateTableRow(table)
    local row = Template.CreateTableRow(table, TABLE_ROW_HEIGHT)
    local left = 0
    for i = 1, #TABLE_COLS do
        local string = row:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        string:SetHeight(TABLE_ROW_HEIGHT)
        string:SetWidth(TABLE_COLS[i].width)
        string:SetPoint("LEFT", row, "LEFT", left, 0)
        string:SetTextColor(1, 1, 1, 0.8)
        left = left + TABLE_COLS[i].width
        row[TABLE_COLS[i].name] = string
        -- 在序号的位置创建一个隐藏的CheckButton
        if i == 1 then
            local checkBtn = CreateFrame("CheckButton", nil, row, "ChatConfigCheckButtonTemplate")
            checkBtn:SetPoint("LEFT", row, "LEFT", (TABLE_COLS[1].width - TABLE_ROW_CHECK_BTN_SIZE) / 2, 0)
            checkBtn:SetSize(TABLE_ROW_CHECK_BTN_SIZE, TABLE_ROW_CHECK_BTN_SIZE)
            checkBtn:SetChecked(false)
            checkBtn:EnableMouse(false)
            checkBtn:Hide()
            row.checkBtn = checkBtn
        end
    end
    return row
end

-- 创建操作栏
function Builder.CreateActionBar(frame)
    -- 外层容器
    local actionBar = CreateFrame("Frame", nil, frame)
    actionBar:SetPoint("TOPLEFT", frame.table, "BOTTOMLEFT", 0, 0)
    actionBar:SetPoint("TOPRIGHT", frame.table, "BOTTOMRIGHT", 0, 0)
    actionBar:SetHeight(ACTION_BAR_HEIGHT)

    -- -- 分割线
    -- local divider = Template.CreateDivider(actionBar)
    -- divider:SetPoint("TOPLEFT", actionBar, "TOPLEFT", 1, 0)
    -- divider:SetPoint("TOPRIGHT", actionBar, "TOPRIGHT", -1, 0)

    -- pagination
    local preBtn = Template.CreatePlainButton(actionBar,
        L["recordFrameActionBtnPre"], ACTION_BAR_HEIGHT, Action.OnActionPreClick)
    local nextBtn = Template.CreatePlainButton(actionBar,
        L["recordFrameActionBtnNext"], ACTION_BAR_HEIGHT, Action.OnActionNextClick)
    local pageBtn = Template.CreatePlainButton(actionBar, "1/1", ACTION_BAR_HEIGHT, nil)
    pageBtn:Disable()
    pageBtn:SetWidth(pageBtn:GetTextWidth() + 16 < ACTION_BAR_HEIGHT
        and ACTION_BAR_HEIGHT or pageBtn:GetTextWidth() + 16)

    nextBtn:SetPoint("RIGHT", actionBar, "RIGHT", 0, 0)
    pageBtn:SetPoint("RIGHT", nextBtn, "LEFT", -8, 0)
    preBtn:SetPoint("RIGHT", pageBtn, "LEFT", -8, 0)

    -- 选中状态下的按钮
    local selectActionBtn = Template.CreatePlainButton(actionBar,
        L["Action.OnActionSelectClearClick"], ACTION_BAR_HEIGHT, Action.OnActionSelectClearClick)
    selectActionBtn:SetPoint("LEFT", actionBar, "LEFT", 0, 0)
    selectActionBtn:Hide()

    frame.actionBar = actionBar
    frame.pageBtn = pageBtn
    frame.selectActionBtn = selectActionBtn
end

-- 创建鼠标提示
function Builder.CreateToolTip(frame)
    local name = AddonName .. "RecordFrameListTooltip"
    frame.detailTooltip = CreateFrame("GameTooltip", name, UIParent, "GameTooltipTemplate")
    frame.detailTooltip:Hide()
end

----------------------------------------
--              数据函数               --
----------------------------------------

function Data.GetTotalPage()
    return ceil(#CurRecords / TABLE_ROW_COUNT)
end

function Data.UpdatePagination()
    Frame.pageBtn:SetText(format("%d/%d", CurPage, Data.GetTotalPage()))
    Frame.pageBtn:SetWidth(Frame.pageBtn:GetTextWidth() + 16 < ACTION_BAR_HEIGHT
        and ACTION_BAR_HEIGHT or Frame.pageBtn:GetTextWidth() + 16)
end

-- 根据目前的（排序、筛选、翻页等）条件刷新要显示的数据
function Data.UpdateCurRecords()
    -- TODO 过滤、排序
    CurRecords = {}
    local size = #TradeLoggerDB.tradeRecord
    for i = size, 1, -1 do
        tinsert(CurRecords, TradeLoggerDB.tradeRecord[i])
    end
end

-- 判断record在不在SelectedRecords中
function Data.IsRecordSelected(record)
    for _, r in ipairs(SelectedRecords) do
        if r.timestamp == record.timestamp then
            return true
        end
    end
    return false
end

function Data.SelectRecord(record)
    if not Data.IsRecordSelected(record) then
        tinsert(SelectedRecords, record)
    end
end

function Data.UnselectRecord(record)
    for i = #SelectedRecords, 1, -1 do
        if SelectedRecords[i].timestamp == record.timestamp then
            tremove(SelectedRecords, i)
            return
        end
    end
end

function Data.ShowTableData()
    for i = 1, TABLE_ROW_COUNT do
        local index = (CurPage - 1) * TABLE_ROW_COUNT + i
        if index <= #CurRecords then
            Data.SetRowText(Frame.table.rows[i], CurRecords[index], index)
        end
    end
end

function Data.ClearTableData()
    for i = 1, TABLE_ROW_COUNT do
        local row = Frame.table.rows[i]
        for _, col in ipairs(TABLE_COLS) do
            row[col.name]:SetText("")
            row.selected = false
            row.checkBtn:SetChecked(false)
            row.checkBtn:Hide()
            row:SetBackdropColor(0, 0, 0, 0)
            row:SetScript("OnEnter", nil)
            row:SetScript("OnLeave", nil)
            row:SetScript("OnMouseDown", nil)
            row:Disable()
        end
    end
end

-- 根据交易记录填充行数据
function Data.SetRowText(row, record, index)
    row:Enable()
    row.record = record
    -- serial & checkBtn
    row.serial:SetFont(STANDARD_TEXT_FONT, 12)
    row.serial:SetText(index)
    local isSelected = Data.IsRecordSelected(record)
    row.selected = isSelected
    row.checkBtn:SetChecked(isSelected)
    if isSelected then
        row:SetBackdropColor(1, 1, 1, 0.15)
        row.serial:Hide()
        row.checkBtn:Show()
    else
        row:SetBackdropColor(0, 0, 0, 0)
        row.serial:Show()
        row.checkBtn:Hide()
    end
    -- time
    row.time:SetFont(STANDARD_TEXT_FONT, 12)
    row.time:SetText(date("%Y-%m-%d %H:%M:%S", record.timestamp))
    -- target
    local tClassColorR, tClassColorG, tClassColorB = GetClassColor(record.targetClass)
    row.target:SetText(record.targetName)
    row.target:SetTextColor(tClassColorR, tClassColorG, tClassColorB, 1)
    -- type
    if record.type == 0 then
        row.type:SetText(L["recordFrameTableTypeTrade"])
    elseif record.type == 1 then
        row.type:SetText(L["recordFrameTableTypeMail"])
    end
    -- location
    row.location:SetText(record.location)
    -- money
    local diffMoney = record.receiveMoney - record.giveMoney
    if diffMoney == 0 then
        row.money:SetText("-")
        row.money:SetTextColor(1, 1, 1, 0.8)
    elseif diffMoney > 0 then
        row.money:SetText(GetMoneyString(diffMoney))
        row.money:SetTextColor(0.3, 1, 0.3, 0.8)
    else
        row.money:SetText("-" .. GetMoneyString(-diffMoney))
        row.money:SetTextColor(1, 0.3, 0.3, 0.8)
    end
    -- give items
    row.giveItems:SetText(Data.GetRecordItemsDesc(record.giveItems))
    row.giveItems:SetNonSpaceWrap(false)
    row.giveItems:SetMaxLines(1)
    -- receive items
    row.receiveItems:SetText(Data.GetRecordItemsDesc(record.receiveItems))
    row.receiveItems:SetNonSpaceWrap(false)
    row.receiveItems:SetMaxLines(1)
    -- hover & click & etc.
    Data.SetRowHover(row, record)
    Data.SetRowClick(row, record)
end

-- 设置鼠标提示
function Data.SetRowHover(row, record)
    local tip = Frame.detailTooltip
    row:SetScript("OnEnter", function(self)
        self:SetBackdropColor(1, 1, 1, 0.15)
        row.serial:Hide()
        row.checkBtn:Show()
        if #record.giveItems > 0 or #record.receiveItems > 0 then
            tip:SetOwner(row, "ANCHOR_NONE")
            tip:SetPoint("LEFT", row, "RIGHT", 2, 0)
            tip:ClearLines()
            if #record.giveItems > 0 then
                tip:AddLine(L["recordFrameTooltipGiveItems"], 1, 1, 1)
                for _, item in ipairs(record.giveItems) do
                    tip:AddDoubleLine(item.itemLink, "x"..item.count, 1, 1, 1, 1, 1, 1)
                end
            end
            if #record.receiveItems > 0 then
                if #record.giveItems > 0 then
                    tip:AddLine(" ")
                end
                tip:AddLine(L["recordFrameTooltipReceiveItems"], 1, 1, 1)
                for _, item in ipairs(record.receiveItems) do
                    tip:AddDoubleLine(item.itemLink, "x"..item.count, 1, 1, 1, 1, 1, 1)
                end
            end
            tip:Show()
            return
        end
    end)
    row:SetScript("OnLeave", function(self)
        if not row.selected then
            self:SetBackdropColor(0, 0, 0, 0)
            row.serial:Show()
            row.checkBtn:Hide()
        end
        tip:Hide()
    end)
end

-- 设置行点击
function Data.SetRowClick(row, record)
    row:SetScript("OnMouseDown", function (self, button)
        if button == "LeftButton" then
            if row.selected then
                Data.UnselectRecord(record)
            else
                Data.SelectRecord(record)
            end
            row.selected = not row.selected
            row.checkBtn:SetChecked(row.selected)
            Data.UpdateSelectActionBtn()
        end
    end)
end

function Data.UpdateSelectActionBtn()
    if #SelectedRecords == 0 then
        Frame.selectActionBtn:Hide()
        Frame.selectAllBtn:SetChecked(false)
    else
        local all = #CurRecords
        local selected = #SelectedRecords
        local text = format(L["recordFrameActionBtnSelect"], selected, all)
        Frame.selectActionBtn:SetText(text)
        Frame.selectActionBtn:SetWidth(Frame.selectActionBtn:GetTextWidth() + 16)
        Frame.selectActionBtn:Show()
        Frame.selectAllBtn:SetChecked(selected == all)
    end
end

function Data.GetRecordItemsDesc(items)
    if #items == 0 then
        return "-"
    end
    local getItemWithCount = function(item)
        if item.count > 1 then
            return item.itemLink .. "x" .. item.count
        else
            return item.itemLink
        end
    end
    local desc = ""
    if #items > 0 then
        for _, item in ipairs(items) do
            desc = desc .. getItemWithCount(item)
        end
    end
    return desc
end

----------------------------------------
--              逻辑函数               --
----------------------------------------

function Action.OnActionPreClick()
    if CurPage > 1 then
        CurPage = CurPage - 1
        Data.ClearTableData()
        Data.UpdatePagination()
        Data.ShowTableData()
    end
end

function Action.OnActionNextClick()
    if CurPage < Data.GetTotalPage() then
        CurPage = CurPage + 1
        Data.ClearTableData()
        Data.UpdatePagination()
        Data.ShowTableData()
    end
end

function Action.OnActionSelectAllClick()
    for _, record in ipairs(CurRecords) do
        Data.SelectRecord(record)
    end
    Data.UpdateSelectActionBtn()
    Data.ClearTableData()
    Data.ShowTableData()
end

function Action.OnActionSelectClearClick()
    SelectedRecords = {}
    Data.UpdateSelectActionBtn()
    Data.ClearTableData()
    Data.ShowTableData()
end

function Action.OnActionFilterClick()
    -- TODO
end

function Action.OnActionSearchClick()
    -- TODO
end

function Action.OnFrameShow()
    if not Dirty then
        return
    end
    CurPage = 1
    Data.ClearTableData()
    Data.UpdateCurRecords()
    Data.UpdatePagination()
    Data.UpdateSelectActionBtn()
    Data.ShowTableData()
    Dirty = false
end

function Action.OnFrameHide()
    if CurPage ~= 1 or #SelectedRecords > 0 then
        SelectedRecords = {}
        Dirty = true
    end
end

function Action.ToggleRecordFrame()
    if not Frame then
        Builder.InitFrame()
    end
    if Frame:IsShown() then
        Frame:Hide()
    else
        Frame:Show()
    end
end

----------------------------------------
--              注册事件               --
----------------------------------------

EventBus.Register("TL_TOGGLE_RECORD_FRAME", Action.ToggleRecordFrame)
EventBus.Register("TL_TRADE_RECORD_ADDED", function() Dirty = true; end)
