local _, Addon = ...

local Template = {
    SOLID = "Interface\\Buttons\\WHITE8x8",
}

----------------------------------------
--          定义UI模板创建函数           --
----------------------------------------

function Template.CreateBackDropFrame(name, parent, bgColor, borderColor)
    local frame = CreateFrame("Frame", name, parent, "BackdropTemplate")
    frame:SetBackdrop({ 
        bgFile = Template.SOLID,
        tile = true,
        tileSize = 16,
        edgeFile = Template.SOLID,
        edgeSize = 1,
        insets = { left = 1, right = 1, top = 1, bottom = 1 }
    })
    if bgColor then
        frame:SetBackdropColor(unpack(bgColor))
    else
        frame:SetBackdropColor(0, 0, 0, 0)
    end
    if borderColor then
        frame:SetBackdropBorderColor(unpack(borderColor))
        else
        frame:SetBackdropBorderColor(0, 0, 0, 0)
    end
    return frame
end

function Template.CreateDivider(parent)
    local divider = parent:CreateTexture(nil, "ARTWORK")
    divider:SetTexture(Template.SOLID)
    divider:SetVertexColor(1, 1, 1, 0.5)
    divider:SetHeight(1)
    return divider
end

function Template.CreateSolidTexture(parent, r, g, b, a)
    local texture = parent:CreateTexture(nil, "BACKGROUND")
    texture:SetColorTexture(r, g, b, a)
    texture:SetAllPoints()
    return texture
end

function Template.CreatePlainButton(parent, text, height, onClick)
    local button = CreateFrame("Button", nil, parent)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetHighlightTexture(Template.CreateSolidTexture(button, 1, 1, 1, 0.15))
    button:GetNormalFontObject():SetTextColor(1, 1, 1, 0.87)
    button:GetNormalFontObject():SetFont(STANDARD_TEXT_FONT, 13, "")
    button:GetHighlightFontObject():SetTextColor(1, 1, 1, 1)
    button:GetHighlightFontObject():SetFont(STANDARD_TEXT_FONT, 13, "")
    button:SetText(text)
    button:SetHeight(height)
    button:SetWidth(button:GetTextWidth() + 16)
    button:SetScript("OnClick", onClick)
    return button
end

function Template.CreateTableHeaderButton(parent, text, height, width)
    local button = CreateFrame("Button", nil, parent)
    button:SetNormalFontObject("GameFontNormal")
    button:SetHighlightFontObject("GameFontHighlight")
    button:SetHighlightTexture(Template.CreateSolidTexture(button, 1, 1, 1, 0.15))
    button:GetNormalFontObject():SetTextColor(1, 1, 1, 0.87)
    button:GetNormalFontObject():SetFont(STANDARD_TEXT_FONT, 13, "")
    button:GetHighlightFontObject():SetTextColor(1, 1, 1, 1)
    button:GetHighlightFontObject():SetFont(STANDARD_TEXT_FONT, 13, "")
    button:SetText(text)
    button:SetHeight(height)
    button:SetWidth(width)
    return button
end

function Template.CreateTableRow(parent, height)
    local row = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    row:SetBackdrop({ bgFile = Template.SOLID, tile = true, tileSize = 16 })
    row:SetBackdropColor(0, 0, 0, 0)
    row:SetScript("OnEnter", function(self)
        self:SetBackdropColor(1, 1, 1, 0.15)
        if row.OnHover then
            row.OnHover(true)
        end
    end)
    row:SetScript("OnLeave", function(self)
        self:SetBackdropColor(0, 0, 0, 0)
        if row.OnHover then
            row.OnHover(false)
        end
    end)
    row:SetHeight(height)
    row.Enable = function ()
        row:EnableMouse(true)
    end
    row.Disable = function ()
        row:EnableMouse(false)
    end
    return row
end

----------------------------------------
--         对其他模块暴露的接口          --
----------------------------------------

Addon.Template = Template;