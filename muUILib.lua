--[[
    yes ai made, idk UIs
]]

local player = game.Players.LocalPlayer
local mouse = player:GetMouse()
local UIS = game:GetService("UserInputService")

-- ─────────────────────────────────────────────
--  Colour / theme defaults
-- ─────────────────────────────────────────────
local themes = {
    Background    = Color3.fromRGB(24,  24,  24),
    Accent        = Color3.fromRGB(10,  10,  10),
    LightContrast = Color3.fromRGB(40,  40,  40),
    DarkContrast  = Color3.fromRGB(14,  14,  14),
    TextColor     = Color3.fromRGB(255, 255, 255),
    Highlight     = Color3.fromRGB(60,  60,  60),
}

-- ─────────────────────────────────────────────
--  Tiny Drawing helpers
-- ─────────────────────────────────────────────
local function makeRect(x, y, w, h, color, filled, zindex)
    local r = Drawing.new("Square")
    r.Position  = Vector2.new(x, y)
    r.Size      = Vector2.new(w, h)
    r.Color     = color or themes.Background
    r.Filled    = filled ~= false
    r.Transparency = 1
    r.ZIndex    = zindex or 1
    r.Visible   = true
    return r
end

local function makeText(x, y, text, size, color, zindex, center, outline)
    local t = Drawing.new("Text")
    t.Position  = Vector2.new(x, y)
    t.Text      = text or ""
    t.Size      = size or 13
    t.Color     = color or themes.TextColor
    t.Transparency = 1
    t.ZIndex    = zindex or 2
    t.Center    = center or false
    t.Outline   = outline or false
    t.Font      = Drawing.Fonts.UI
    t.Visible   = true
    return t
end

local function makeLine(x1, y1, x2, y2, color, thickness, zindex)
    local l = Drawing.new("Line")
    l.From      = Vector2.new(x1, y1)
    l.To        = Vector2.new(x2, y2)
    l.Color     = color or themes.LightContrast
    l.Thickness = thickness or 1
    l.Transparency = 1
    l.ZIndex    = zindex or 1
    l.Visible   = true
    return l
end

-- ─────────────────────────────────────────────
--  Color3.toHSV polyfill (not in Matcha)
-- ─────────────────────────────────────────────
local function Color3toHSV(c)
    local r, g, b = c.R, c.G, c.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local delta = max - min
    local h, s, v = 0, 0, max
    if max ~= 0 then s = delta / max end
    if delta ~= 0 then
        if max == r then
            h = (g - b) / delta % 6
        elseif max == g then
            h = (b - r) / delta + 2
        else
            h = (r - g) / delta + 4
        end
        h = h / 6
    end
    return h, s, v
end

-- ─────────────────────────────────────────────
--  Input helpers
-- ─────────────────────────────────────────────
local function mouseInside(x, y, w, h)
    local mx, my = mouse.X, mouse.Y
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

-- ─────────────────────────────────────────────
--  Library constants / layout
-- ─────────────────────────────────────────────
local WIN_X, WIN_Y   = 100, 80
local WIN_W, WIN_H   = 520, 400
local TOPBAR_H       = 28
local SIDEBAR_W      = 120
local SECTION_PAD    = 8
local ELEM_H         = 24
local ELEM_PAD       = 5
local FONT_SIZE      = 13
local TITLE_SIZE     = 14

-- ─────────────────────────────────────────────
--  Library
-- ─────────────────────────────────────────────
local library = {}
library.__index = library

function library.new(title)
    local self = setmetatable({}, library)

    self.title       = title or "UI"
    self.visible     = true
    self.pages       = {}
    self.focusedPage = nil
    self.drawings    = {}   -- all drawing objects (for cleanup)
    self.keybinds    = {}
    self.keybindEnded = {}

    -- ── window chrome ──
    -- shadow
    self._shadow = makeRect(WIN_X - 4, WIN_Y - 4, WIN_W + 8, WIN_H + 8,
                            Color3.fromRGB(0,0,0), true, 0)
    self._shadow.Transparency = 0.5

    -- background
    self._bg = makeRect(WIN_X, WIN_Y, WIN_W, WIN_H, themes.Background, true, 1)

    -- top-bar
    self._topbar = makeRect(WIN_X, WIN_Y, WIN_W, TOPBAR_H, themes.Accent, true, 2)

    -- title text
    self._titleText = makeText(WIN_X + 10, WIN_Y + 7, title, TITLE_SIZE,
                               themes.TextColor, 3)

    -- sidebar background
    self._sidebar = makeRect(WIN_X, WIN_Y + TOPBAR_H, SIDEBAR_W,
                             WIN_H - TOPBAR_H, themes.DarkContrast, true, 2)

    -- sidebar / content divider
    self._divider = makeLine(WIN_X + SIDEBAR_W, WIN_Y + TOPBAR_H,
                             WIN_X + SIDEBAR_W, WIN_Y + WIN_H,
                             themes.LightContrast, 1, 3)

    -- ── dragging ──
    self._dragging  = false
    self._dragOffX  = 0
    self._dragOffY  = 0

    -- ── keybind listener ──
    UIS.InputBegan:Connect(function(inp)
        if self.keybinds[inp.KeyCode] then
            for _, cb in pairs(self.keybinds[inp.KeyCode]) do
                cb()
            end
        end
    end)

    UIS.InputEnded:Connect(function(inp)
        for _, cb in pairs(self.keybindEnded) do
            cb(inp)
        end
    end)

    -- ── per-frame update loop ──
    spawn(function()
        while task.wait(0) do
            self:_update()
        end
    end)

    return self
end

-- ── per-frame drag + visibility ──
function library:_update()
    if not self.visible then return end

    local mx, my = mouse.X, mouse.Y

    -- drag start
    if ismouse1pressed() then
        if not self._dragging then
            if mouseInside(WIN_X, WIN_Y, WIN_W, TOPBAR_H) then
                self._dragging = true
                self._dragOffX = mx - WIN_X
                self._dragOffY = my - WIN_Y
            end
        end
    else
        self._dragging = false
    end

    if self._dragging then
        local nx = mx - self._dragOffX
        local ny = my - self._dragOffY
        self:_move(nx, ny)
    end
end

function library:_move(nx, ny)
    local dx = nx - WIN_X
    local dy = ny - WIN_Y
    WIN_X, WIN_Y = nx, ny

    self._shadow.Position  = Vector2.new(WIN_X - 4, WIN_Y - 4)
    self._bg.Position      = Vector2.new(WIN_X, WIN_Y)
    self._topbar.Position  = Vector2.new(WIN_X, WIN_Y)
    self._titleText.Position = Vector2.new(WIN_X + 10, WIN_Y + 7)
    self._sidebar.Position = Vector2.new(WIN_X, WIN_Y + TOPBAR_H)
    self._divider.From     = Vector2.new(WIN_X + SIDEBAR_W, WIN_Y + TOPBAR_H)
    self._divider.To       = Vector2.new(WIN_X + SIDEBAR_W, WIN_Y + WIN_H)

    for _, p in pairs(self.pages) do
        p:_move(dx, dy)
    end
end

function library:toggle()
    self.visible = not self.visible

    local v = self.visible
    self._shadow.Visible   = v
    self._bg.Visible       = v
    self._topbar.Visible   = v
    self._titleText.Visible = v
    self._sidebar.Visible  = v
    self._divider.Visible  = v

    for _, p in pairs(self.pages) do
        p:_setVisible(v and (self.focusedPage == p))
        p._btn.Visible = v
        p._btnText.Visible = v
    end
end

function library:addPage(title, icon)
    local idx   = #self.pages
    local btnY  = WIN_Y + TOPBAR_H + 10 + idx * 28

    local p = setmetatable({
        library  = self,
        title    = title,
        sections = {},
        _btn     = makeRect(WIN_X + 6, btnY, SIDEBAR_W - 12, 22,
                            themes.DarkContrast, true, 3),
        _btnText = makeText(WIN_X + 10, btnY + 5, title, FONT_SIZE,
                            themes.TextColor, 4),
    }, {})

    -- store methods via closure
    p._setVisible = function(self2, v)
        for _, sec in pairs(self2.sections) do
            sec:_setVisible(v)
        end
    end

    p._move = function(self2, dx, dy)
        self2._btn.Position = Vector2.new(
            self2._btn.Position.X + dx,
            self2._btn.Position.Y + dy)
        self2._btnText.Position = Vector2.new(
            self2._btnText.Position.X + dx,
            self2._btnText.Position.Y + dy)
        for _, sec in pairs(self2.sections) do
            sec:_move(dx, dy)
        end
    end

    p.addSection = function(self2, stitle)
        return library._addSection(self2, stitle)
    end

    p.Resize = function(self2)
        -- recalc section Y positions
        local cy = WIN_Y + TOPBAR_H + SECTION_PAD
        for _, sec in pairs(self2.sections) do
            sec:_reposition(cy)
            cy = cy + sec:_height() + SECTION_PAD
        end
    end

    table.insert(self.pages, p)

    -- click detection per-frame
    spawn(function()
        local wasDown = false
        while task.wait(0) do
            local down = ismouse1pressed()
            if down and not wasDown then
                if mouseInside(p._btn.Position.X, p._btn.Position.Y, SIDEBAR_W - 12, 22) then
                    self:SelectPage(p, true)
                end
            end
            wasDown = down
        end
    end)

    return p
end

function library:SelectPage(page, toggle)
    if toggle and self.focusedPage == page then return end

    -- deselect old
    if self.focusedPage then
        local old = self.focusedPage
        old._btn.Color = themes.DarkContrast
        old._btnText.Transparency = 0.6
        old:_setVisible(false)
    end

    self.focusedPage = page
    page._btn.Color = themes.Highlight
    page._btnText.Transparency = 1
    page:_setVisible(true)
    page:Resize()
end

function library:setTheme(theme, color3)
    themes[theme] = color3
    -- propagate to background / accent / etc.
    if theme == "Background" then
        self._bg.Color = color3
        self._shadow.Color = Color3.fromRGB(0,0,0)
    elseif theme == "Accent" then
        self._topbar.Color = color3
    elseif theme == "DarkContrast" then
        self._sidebar.Color = color3
    elseif theme == "LightContrast" then
        self._divider.Color = color3
    elseif theme == "TextColor" then
        self._titleText.Color = color3
    end
    -- propagate into sections
    for _, p in pairs(self.pages) do
        for _, sec in pairs(p.sections) do
            sec:_applyTheme(theme, color3)
        end
    end
end

function library:Notify(title, text, duration)
    notify(text or "", title or "Notification", duration or 5)
end

function library:BindToKey(key, cb)
    self.keybinds[key] = self.keybinds[key] or {}
    table.insert(self.keybinds[key], cb)
    return {
        UnBind = function()
            for i, b in pairs(self.keybinds[key]) do
                if b == cb then table.remove(self.keybinds[key], i) end
            end
        end
    }
end

-- ─────────────────────────────────────────────
--  Section factory (called from page.addSection)
-- ─────────────────────────────────────────────
function library._addSection(page, stitle)
    local lib    = page.library
    local startX = WIN_X + SIDEBAR_W + SECTION_PAD
    local startY = WIN_Y + TOPBAR_H + SECTION_PAD
    local secW   = WIN_W - SIDEBAR_W - SECTION_PAD * 2

    local sec = {
        page     = page,
        title    = stitle,
        modules  = {},
        elements = {},   -- all drawing objects belonging to this section
        _x       = startX,
        _y       = startY,
        _w       = secW,
        _visible = false,
    }

    -- section header bg
    sec._hdrBg = makeRect(startX, startY, secW, 20, themes.Accent, true, 3)
    sec._hdrText = makeText(startX + 6, startY + 4, stitle, FONT_SIZE - 1,
                            themes.TextColor, 4)

    sec._setVisible = function(self2, v)
        self2._visible = v
        self2._hdrBg.Visible   = v
        self2._hdrText.Visible = v
        for _, e in pairs(self2.elements) do
            if type(e) == "table" and e.setVisible then
                e:setVisible(v)
            elseif e.Visible ~= nil then
                e.Visible = v
            end
        end
    end

    sec._move = function(self2, dx, dy)
        self2._x = self2._x + dx
        self2._y = self2._y + dy
        self2._hdrBg.Position   = Vector2.new(self2._hdrBg.Position.X + dx, self2._hdrBg.Position.Y + dy)
        self2._hdrText.Position = Vector2.new(self2._hdrText.Position.X + dx, self2._hdrText.Position.Y + dy)
        for _, e in pairs(self2.elements) do
            if type(e) == "table" and e.move then e:move(dx, dy) end
        end
        for _, m in pairs(self2.modules) do
            if type(m) == "table" and m._move then m:_move(dx, dy) end
        end
    end

    sec._height = function(self2)
        local h = 20 + SECTION_PAD
        for _, m in pairs(self2.modules) do
            h = h + (m._h or ELEM_H) + ELEM_PAD
        end
        return h
    end

    sec._reposition = function(self2, newY)
        local dy = newY - self2._y
        self2:_move(0, dy)
    end

    sec._applyTheme = function(self2, theme, color3)
        if theme == "Accent" then
            self2._hdrBg.Color = color3
        elseif theme == "TextColor" then
            self2._hdrText.Color = color3
        end
        for _, m in pairs(self2.modules) do
            if m._applyTheme then m:_applyTheme(theme, color3) end
        end
    end

    -- ── element Y tracker ──
    local function nextY(self2)
        local y = self2._y + 20 + SECTION_PAD
        for _, m in pairs(self2.modules) do
            y = y + (m._h or ELEM_H) + ELEM_PAD
        end
        return y
    end

    -- ─────────────────────────────────────────
    --  addButton
    -- ─────────────────────────────────────────
    function sec:addButton(title, callback)
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w

        local bg   = makeRect(ex, ey, ew, ELEM_H, themes.DarkContrast, true, 4)
        local txt  = makeText(ex + ew/2, ey + 5, title, FONT_SIZE, themes.TextColor, 5, true)

        local mod = {
            _h   = ELEM_H,
            _bg  = bg,
            _txt = txt,
            _visible = self._visible,
        }
        bg.Visible  = self._visible
        txt.Visible = self._visible

        mod.setVisible = function(self2, v)
            self2._bg.Visible  = v
            self2._txt.Visible = v
        end
        mod._move = function(self2, dx, dy)
            self2._bg.Position  = Vector2.new(self2._bg.Position.X + dx, self2._bg.Position.Y + dy)
            self2._txt.Position = Vector2.new(self2._txt.Position.X + dx, self2._txt.Position.Y + dy)
        end
        mod._applyTheme = function(self2, theme, color3)
            if theme == "DarkContrast" then self2._bg.Color = color3 end
            if theme == "TextColor" then self2._txt.Color = color3 end
        end

        table.insert(self.modules, mod)

        -- click detection
        spawn(function()
            local wasDown = false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()
                if down and not wasDown then
                    local p = mod._bg.Position
                    if mouseInside(p.X, p.Y, ew, ELEM_H) then
                        mod._bg.Color = themes.Highlight
                        if callback then callback() end
                        task.wait(0.15)
                        mod._bg.Color = themes.DarkContrast
                    end
                end
                wasDown = down
            end
        end)

        return mod
    end

    -- ─────────────────────────────────────────
    --  addToggle
    -- ─────────────────────────────────────────
    function sec:addToggle(title, default, callback)
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w

        local bg      = makeRect(ex, ey, ew, ELEM_H, themes.DarkContrast, true, 4)
        local txt     = makeText(ex + 8, ey + 5, title, FONT_SIZE, themes.TextColor, 5)
        -- toggle pill
        local pillBg  = makeRect(ex + ew - 38, ey + 5, 30, 14, themes.LightContrast, true, 5)
        local pillDot = makeRect(ex + ew - 36, ey + 7, 10, 10, themes.TextColor, true, 6)

        local active = default or false

        local mod = {
            _h       = ELEM_H,
            _bg      = bg,
            _txt     = txt,
            _pillBg  = pillBg,
            _pillDot = pillDot,
            _active  = active,
            _visible = self._visible,
        }

        local function applyState(v)
            mod._active = v
            if v then
                mod._pillDot.Position = Vector2.new(
                    mod._pillBg.Position.X + 16,
                    mod._pillBg.Position.Y + 2)
                mod._pillBg.Color = Color3.fromRGB(80, 200, 80)
            else
                mod._pillDot.Position = Vector2.new(
                    mod._pillBg.Position.X + 2,
                    mod._pillBg.Position.Y + 2)
                mod._pillBg.Color = themes.LightContrast
            end
        end
        applyState(active)

        for _, d in pairs({bg, txt, pillBg, pillDot}) do
            d.Visible = self._visible
        end

        mod.setVisible = function(self2, v)
            self2._visible = v
            for _, d in pairs({self2._bg, self2._txt, self2._pillBg, self2._pillDot}) do
                d.Visible = v
            end
        end
        mod._move = function(self2, dx, dy)
            for _, d in pairs({self2._bg, self2._txt, self2._pillBg, self2._pillDot}) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
        end
        mod._applyTheme = function(self2, theme, color3)
            if theme == "DarkContrast" then self2._bg.Color = color3 end
            if theme == "TextColor" then
                self2._txt.Color = color3
                if not self2._active then self2._pillDot.Color = color3 end
            end
            if theme == "LightContrast" and not self2._active then
                self2._pillBg.Color = color3
            end
        end

        table.insert(self.modules, mod)

        spawn(function()
            local wasDown = false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()
                if down and not wasDown then
                    local p = mod._bg.Position
                    if mouseInside(p.X, p.Y, ew, ELEM_H) then
                        active = not active
                        applyState(active)
                        if callback then callback(active, function(v) applyState(v) end) end
                    end
                end
                wasDown = down
            end
        end)

        mod.setValue = function(v)
            applyState(v)
            if callback then callback(v, function(v2) applyState(v2) end) end
        end

        return mod
    end

    -- ─────────────────────────────────────────
    --  addSlider
    -- ─────────────────────────────────────────
    function sec:addSlider(title, default, min, max, callback)
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w
        local eh = ELEM_H + 14  -- taller for slider bar

        local bg      = makeRect(ex, ey, ew, eh, themes.DarkContrast, true, 4)
        local txt     = makeText(ex + 8, ey + 5, title, FONT_SIZE, themes.TextColor, 5)
        local valTxt  = makeText(ex + ew - 30, ey + 5, tostring(default or min), FONT_SIZE, themes.TextColor, 5)
        -- track
        local trackX  = ex + 8
        local trackY  = ey + eh - 10
        local trackW  = ew - 16
        local track   = makeRect(trackX, trackY, trackW, 4, themes.LightContrast, true, 5)
        local fill    = makeRect(trackX, trackY, 0, 4, themes.TextColor, true, 6)
        -- knob
        local knob    = makeRect(trackX - 5, trackY - 3, 10, 10, themes.TextColor, true, 7)

        local value   = default or min
        local dragging = false

        local function updateVisual(v)
            value = math.clamp(v, min, max)
            local pct = (value - min) / (max - min)
            fill.Size    = Vector2.new(trackW * pct, 4)
            knob.Position = Vector2.new(trackX + trackW * pct - 5, trackY - 3)
            valTxt.Text  = tostring(math.floor(value))
        end
        updateVisual(value)

        local mod = {
            _h = eh, _bg = bg, _txt = txt, _valTxt = valTxt,
            _track = track, _fill = fill, _knob = knob,
            _visible = self._visible,
        }

        for _, d in pairs({bg, txt, valTxt, track, fill, knob}) do
            d.Visible = self._visible
        end

        mod.setVisible = function(self2, v)
            self2._visible = v
            for _, d in pairs({self2._bg, self2._txt, self2._valTxt,
                               self2._track, self2._fill, self2._knob}) do
                d.Visible = v
            end
        end
        mod._move = function(self2, dx, dy)
            trackX = trackX + dx
            trackY = trackY + dy
            for _, d in pairs({self2._bg, self2._txt, self2._valTxt,
                               self2._track, self2._fill, self2._knob}) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
        end
        mod._applyTheme = function(self2, theme, color3)
            if theme == "DarkContrast" then self2._bg.Color = color3 end
            if theme == "TextColor" then
                self2._txt.Color = color3
                self2._valTxt.Color = color3
                self2._fill.Color = color3
                self2._knob.Color = color3
            end
            if theme == "LightContrast" then self2._track.Color = color3 end
        end

        table.insert(self.modules, mod)

        spawn(function()
            local wasDown = false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()
                if down and not wasDown then
                    local bp = mod._bg.Position
                    if mouseInside(bp.X, bp.Y, ew, eh) then
                        dragging = true
                    end
                end
                if not down then dragging = false end

                if dragging then
                    local pct = math.clamp((mouse.X - trackX) / trackW, 0, 1)
                    local v   = math.floor(min + (max - min) * pct)
                    updateVisual(v)
                    if callback then callback(v) end
                end
                wasDown = down
            end
        end)

        mod.setValue = function(v) updateVisual(v) end

        return mod
    end

    -- ─────────────────────────────────────────
    --  addKeybind
    -- ─────────────────────────────────────────
    function sec:addKeybind(title, default, callback, changedCallback)
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w

        local bg     = makeRect(ex, ey, ew, ELEM_H, themes.DarkContrast, true, 4)
        local txt    = makeText(ex + 8, ey + 5, title, FONT_SIZE, themes.TextColor, 5)
        local keyTxt = makeText(ex + ew - 70, ey + 5, default and tostring(default) or "None",
                                FONT_SIZE - 1, themes.TextColor, 5)
        local keyBg  = makeRect(ex + ew - 74, ey + 3, 68, ELEM_H - 6, themes.LightContrast, true, 4)

        local currentKey = default
        local listening  = false
        local connection

        local lib = self.page.library

        local mod = {
            _h = ELEM_H, _bg = bg, _txt = txt, _keyTxt = keyTxt, _keyBg = keyBg,
            _visible = self._visible,
        }

        for _, d in pairs({bg, txt, keyTxt, keyBg}) do d.Visible = self._visible end

        mod.setVisible = function(self2, v)
            self2._visible = v
            for _, d in pairs({self2._bg, self2._txt, self2._keyTxt, self2._keyBg}) do
                d.Visible = v
            end
        end
        mod._move = function(self2, dx, dy)
            for _, d in pairs({self2._bg, self2._txt, self2._keyTxt, self2._keyBg}) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
        end
        mod._applyTheme = function(self2, theme, color3)
            if theme == "DarkContrast" then self2._bg.Color = color3 end
            if theme == "TextColor" then
                self2._txt.Color = color3
                self2._keyTxt.Color = color3
            end
            if theme == "LightContrast" then self2._keyBg.Color = color3 end
        end

        local function bindKey(key)
            if connection then connection:UnBind() end
            currentKey = key
            keyTxt.Text = key and tostring(key) or "None"
            if key and callback then
                connection = lib:BindToKey(key, function()
                    if callback then callback() end
                end)
            end
        end

        if default then bindKey(default) end

        table.insert(self.modules, mod)

        spawn(function()
            local wasDown = false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()
                if down and not wasDown then
                    local p = mod._bg.Position
                    if mouseInside(p.X, p.Y, ew, ELEM_H) then
                        if currentKey then
                            bindKey(nil)  -- unbind on click if bound
                        else
                            listening = true
                            keyTxt.Text = "..."
                        end
                    end
                end
                wasDown = down
            end
        end)

        UIS.InputBegan:Connect(function(inp)
            if listening then
                listening = false
                bindKey(inp.KeyCode)
                if changedCallback then changedCallback(inp) end
            end
        end)

        return mod
    end

    -- ─────────────────────────────────────────
    --  addColorPicker  (simplified HSV picker)
    -- ─────────────────────────────────────────
    function sec:addColorPicker(title, default, callback)
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w

        local bg       = makeRect(ex, ey, ew, ELEM_H, themes.DarkContrast, true, 4)
        local txt      = makeText(ex + 8, ey + 5, title, FONT_SIZE, themes.TextColor, 5)
        local swatch   = makeRect(ex + ew - 38, ey + 4, 30, 16, default or themes.TextColor, true, 5)
        local swatchBorder = makeRect(ex + ew - 39, ey + 3, 32, 18, themes.LightContrast, false, 5)
        swatchBorder.Thickness = 1

        -- Picker popup (hidden initially)
        local PW, PH = 160, 120
        local px  = ex + ew + 6
        local py  = ey
        local popBg  = makeRect(px, py, PW, PH, themes.Background, true, 10)
        local popHdr = makeRect(px, py, PW, 18, themes.Accent, true, 11)
        local popTxt = makeText(px + 6, py + 3, title, FONT_SIZE - 1, themes.TextColor, 12)

        -- Hue bar
        local hueBarY = py + PH - 20
        local hueColors = {
            Color3.fromRGB(255,0,0), Color3.fromRGB(255,128,0),
            Color3.fromRGB(255,255,0), Color3.fromRGB(0,255,0),
            Color3.fromRGB(0,255,255), Color3.fromRGB(0,0,255),
            Color3.fromRGB(255,0,255), Color3.fromRGB(255,0,0),
        }
        local hueSections = {}
        local sectionW = math.floor(PW / #hueColors)
        for i, col in ipairs(hueColors) do
            local hb = makeRect(px + (i-1)*sectionW, hueBarY, sectionW, 12, col, true, 11)
            hb.Visible = false
            table.insert(hueSections, hb)
        end

        -- SV canvas (approximate with 4 corner rects)
        local svX, svY = px + 6, py + 22
        local svW, svH = PW - 12, PH - 48
        local svBg    = makeRect(svX, svY, svW, svH, Color3.fromRGB(255,0,0), true, 11)
        local svCursor = Drawing.new("Circle")
        svCursor.Radius = 5
        svCursor.Color  = themes.TextColor
        svCursor.Thickness = 2
        svCursor.Filled = false
        svCursor.Position = Vector2.new(svX + svW, svY)
        svCursor.ZIndex = 13
        svCursor.Visible = false

        -- hue selector line
        local hueSelector = makeRect(px, hueBarY, 4, 12, themes.TextColor, true, 12)
        hueSelector.Visible = false

        -- Close button text
        local closeTxt = makeText(px + PW - 16, py + 2, "x", FONT_SIZE, themes.TextColor, 12)
        closeTxt.Visible = false

        local popupVisible = false
        local color3 = default or Color3.fromRGB(255, 255, 255)
        local hue, sat, val_ = Color3toHSV(color3)

        local allPop = {popBg, popHdr, popTxt, svBg, svCursor, hueSelector, closeTxt}
        for _, h2 in ipairs(hueSections) do table.insert(allPop, h2) end

        local function setPopVisible(v)
            popupVisible = v
            for _, d in pairs(allPop) do d.Visible = v end
        end

        local function updateSwatch(c)
            color3 = c
            swatch.Color = c
            svBg.Color   = Color3.fromHSV(hue, 1, 1)
            svCursor.Position = Vector2.new(
                svX + sat * svW,
                svY + (1 - val_) * svH)
            hueSelector.Position = Vector2.new(
                px + hue * PW, hueBarY)
        end
        updateSwatch(color3)

        local mod = {
            _h = ELEM_H, _bg = bg, _txt = txt, _swatch = swatch,
            _swatchBorder = swatchBorder, _visible = self._visible,
            _allPop = allPop,
        }

        for _, d in pairs({bg, txt, swatch, swatchBorder}) do d.Visible = self._visible end

        mod.setVisible = function(self2, v)
            self2._visible = v
            for _, d in pairs({self2._bg, self2._txt, self2._swatch, self2._swatchBorder}) do
                d.Visible = v
            end
            if not v then setPopVisible(false) end
        end
        mod._move = function(self2, dx, dy)
            px = px + dx; py = py + dy; svX = svX + dx; svY = svY + dy
            hueBarY = hueBarY + dy
            for _, d in pairs({self2._bg, self2._txt, self2._swatch, self2._swatchBorder}) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
            for _, d in pairs(allPop) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
        end
        mod._applyTheme = function(self2, theme, color3_)
            if theme == "DarkContrast" then self2._bg.Color = color3_ end
            if theme == "TextColor" then self2._txt.Color = color3_ end
            if theme == "LightContrast" then self2._swatchBorder.Color = color3_ end
        end

        mod.setValue = function(c)
            hue, sat, val_ = Color3toHSV(c)
            updateSwatch(c)
            if callback then callback(c) end
        end

        table.insert(self.modules, mod)

        -- interaction loop
        spawn(function()
            local wasDown = false
            local draggingSV, draggingHue = false, false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()

                if down and not wasDown then
                    -- toggle popup
                    if mouseInside(swatch.Position.X, swatch.Position.Y, 30, 16)
                    or mouseInside(bg.Position.X, bg.Position.Y, ew, ELEM_H) then
                        setPopVisible(not popupVisible)
                    end
                    -- close button
                    if popupVisible and mouseInside(px + PW - 18, py, 18, 18) then
                        setPopVisible(false)
                    end
                    -- sv drag start
                    if popupVisible and mouseInside(svX, svY, svW, svH) then
                        draggingSV = true
                    end
                    -- hue drag start
                    if popupVisible and mouseInside(px, hueBarY, PW, 12) then
                        draggingHue = true
                    end
                end

                if not down then draggingSV = false; draggingHue = false end

                if draggingSV then
                    sat  = math.clamp((mouse.X - svX) / svW, 0, 1)
                    val_ = 1 - math.clamp((mouse.Y - svY) / svH, 0, 1)
                    color3 = Color3.fromHSV(hue, sat, val_)
                    updateSwatch(color3)
                    if callback then callback(color3) end
                end

                if draggingHue then
                    hue = math.clamp((mouse.X - px) / PW, 0, 1)
                    color3 = Color3.fromHSV(hue, sat, val_)
                    updateSwatch(color3)
                    if callback then callback(color3) end
                end

                wasDown = down
            end
        end)

        return mod
    end

    -- ─────────────────────────────────────────
    --  addDropdown
    -- ─────────────────────────────────────────
    function sec:addDropdown(title, list, callback)
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w
        local ITEM_H = ELEM_H

        local bg     = makeRect(ex, ey, ew, ELEM_H, themes.DarkContrast, true, 4)
        local txt    = makeText(ex + 8, ey + 5, title, FONT_SIZE, themes.TextColor, 5)
        local arrow  = makeText(ex + ew - 18, ey + 5, "v", FONT_SIZE, themes.TextColor, 5)

        list = list or {}
        local open = false
        local itemBgs, itemTxts = {}, {}

        local function buildItems()
            for _, b in ipairs(itemBgs) do b:Remove() end
            for _, t in ipairs(itemTxts) do t:Remove() end
            itemBgs, itemTxts = {}, {}

            if not open then return end

            for i, val in ipairs(list) do
                local iy  = ey + ELEM_H + (i-1) * (ITEM_H + 2)
                local ibg = makeRect(ex, iy, ew, ITEM_H, themes.Background, true, 7)
                local itx = makeText(ex + 8, iy + 5, tostring(val), FONT_SIZE, themes.TextColor, 8)
                ibg.Visible = self._visible
                itx.Visible = self._visible
                table.insert(itemBgs, ibg)
                table.insert(itemTxts, itx)
            end
        end

        local mod = {
            _h = ELEM_H, _bg = bg, _txt = txt, _arrow = arrow,
            _itemBgs = itemBgs, _itemTxts = itemTxts,
            _visible = self._visible,
        }

        bg.Visible    = self._visible
        txt.Visible   = self._visible
        arrow.Visible = self._visible

        mod.setVisible = function(self2, v)
            self2._visible = v
            self2._bg.Visible    = v
            self2._txt.Visible   = v
            self2._arrow.Visible = v
            for _, b in ipairs(self2._itemBgs) do b.Visible = v end
            for _, t in ipairs(self2._itemTxts) do t.Visible = v end
        end
        mod._move = function(self2, dx, dy)
            ey = ey + dy
            for _, d in pairs({self2._bg, self2._txt, self2._arrow}) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
            for _, b in ipairs(self2._itemBgs) do
                b.Position = Vector2.new(b.Position.X + dx, b.Position.Y + dy)
            end
            for _, t in ipairs(self2._itemTxts) do
                t.Position = Vector2.new(t.Position.X + dx, t.Position.Y + dy)
            end
        end
        mod._applyTheme = function(self2, theme, color3_)
            if theme == "DarkContrast" then self2._bg.Color = color3_ end
            if theme == "TextColor" then
                self2._txt.Color = color3_
                self2._arrow.Color = color3_
            end
        end

        table.insert(self.modules, mod)

        spawn(function()
            local wasDown = false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()

                if down and not wasDown then
                    -- toggle open
                    if mouseInside(bg.Position.X, bg.Position.Y, ew, ELEM_H) then
                        open = not open
                        arrow.Text = open and "^" or "v"
                        buildItems()
                    end

                    -- item clicks
                    if open then
                        for i, ibg in ipairs(itemBgs) do
                            if mouseInside(ibg.Position.X, ibg.Position.Y, ew, ITEM_H) then
                                txt.Text = tostring(list[i])
                                if callback then callback(list[i]) end
                                open = false
                                arrow.Text = "v"
                                buildItems()
                            end
                        end
                    end
                end

                wasDown = down
            end
        end)

        return mod
    end

    -- ─────────────────────────────────────────
    --  addTextbox
    -- ─────────────────────────────────────────
    function sec:addTextbox(title, default, callback)
        -- Matcha has no TextBox Drawing object, so we simulate a click-to-copy style
        -- that uses notify() to tell the user to type, and setclipboard feedback
        local ex = self._x
        local ey = nextY(self)
        local ew = self._w

        local bg    = makeRect(ex, ey, ew, ELEM_H, themes.DarkContrast, true, 4)
        local txt   = makeText(ex + 8, ey + 5, title, FONT_SIZE, themes.TextColor, 5)
        local valBg = makeRect(ex + ew - 104, ey + 4, 98, ELEM_H - 8, themes.LightContrast, true, 5)
        local valTxt= makeText(ex + ew - 100, ey + 5, default or "", FONT_SIZE - 1, themes.TextColor, 6)

        local stored = default or ""

        local mod = {
            _h = ELEM_H, _bg = bg, _txt = txt, _valBg = valBg, _valTxt = valTxt,
            _visible = self._visible, _value = stored,
        }

        for _, d in pairs({bg, txt, valBg, valTxt}) do d.Visible = self._visible end

        mod.setVisible = function(self2, v)
            self2._visible = v
            for _, d in pairs({self2._bg, self2._txt, self2._valBg, self2._valTxt}) do
                d.Visible = v
            end
        end
        mod._move = function(self2, dx, dy)
            for _, d in pairs({self2._bg, self2._txt, self2._valBg, self2._valTxt}) do
                d.Position = Vector2.new(d.Position.X + dx, d.Position.Y + dy)
            end
        end
        mod._applyTheme = function(self2, theme, color3_)
            if theme == "DarkContrast" then self2._bg.Color = color3_ end
            if theme == "LightContrast" then self2._valBg.Color = color3_ end
            if theme == "TextColor" then
                self2._txt.Color = color3_
                self2._valTxt.Color = color3_
            end
        end
        mod.setValue = function(self2, v)
            self2._value = v
            self2._valTxt.Text = tostring(v)
        end

        table.insert(self.modules, mod)

        spawn(function()
            local wasDown = false
            while task.wait(0) do
                if not mod._visible then wasDown = ismouse1pressed(); task.wait(0); continue end
                local down = ismouse1pressed()
                if down and not wasDown then
                    if mouseInside(bg.Position.X, bg.Position.Y, ew, ELEM_H) then
                        notify("Click OK then paste new value", "Textbox: " .. title, 3)
                        -- In a real scenario the user would update via mod:setValue()
                    end
                end
                wasDown = down
            end
        end)

        return mod
    end

    table.insert(page.sections, sec)
    return sec
end

-- Register as global so loadstring() callers can access it
-- even if Matcha's loadstring doesn't propagate return values
_G.MatchaUI = library
return library
