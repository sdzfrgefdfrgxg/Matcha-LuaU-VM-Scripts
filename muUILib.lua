--[[
    MatchaUI - A Rayfield-style UI Library for Matcha LuaU VM
    Version: 1.0.0
    
    USAGE:
    
    local UI = require("MatchaUI")
    
    local Window = UI:CreateWindow({
        Name = "My Script",
        Subtitle = "by you",
        Icon = nil,
        LoadingTitle = "Loading...",
        LoadingSubtitle = "Please wait",
    })
    
    local Tab = Window:CreateTab("General")
    
    Tab:CreateButton({ Name = "Click Me", Callback = function() end })
    Tab:CreateToggle({ Name = "Toggle", Default = false, Callback = function(v) end })
    Tab:CreateSlider({ Name = "Speed", Min = 0, Max = 100, Default = 50, Callback = function(v) end })
    Tab:CreateDropdown({ Name = "Mode", Options = {"A","B"}, Default = "A", Callback = function(v) end })
    Tab:CreateTextbox({ Name = "Name", Placeholder = "Enter name...", Callback = function(v) end })
    Tab:CreateLabel("Some label text")
    Tab:CreateDivider()
    Tab:CreateKeybind({ Name = "Bind", Default = 0x70, DefaultName = "F1", Callback = function() end })
    Tab:CreateColorPicker({ Name = "Color", Default = Color3.fromRGB(0,200,255), Callback = function(c) end })
    
    UI:Notify({ Title = "Hello", Content = "World", Duration = 3 })
    
    UI:Destroy()
]]

local Players       = game:GetService("Players")
local UIS           = game:GetService("UserInputService")
local player        = Players.LocalPlayer
local mouse         = player:GetMouse()
local VP            = workspace.CurrentCamera.ViewportSize

-- ─── Palette ────────────────────────────────────────────────────────────────
local C = {
    bg       = Color3.fromRGB(15,  15,  20),
    bgPanel  = Color3.fromRGB(20,  20,  28),
    sidebar  = Color3.fromRGB(18,  18,  26),
    card     = Color3.fromRGB(24,  24,  34),
    cardHov  = Color3.fromRGB(30,  30,  42),
    acc      = Color3.fromRGB(0,   180, 255),
    accDim   = Color3.fromRGB(0,   100, 155),
    accGlow  = Color3.fromRGB(120, 220, 255),
    accDark  = Color3.fromRGB(0,   40,  65),
    bord     = Color3.fromRGB(38,  38,  54),
    bordAcc  = Color3.fromRGB(0,   120, 170),
    txt      = Color3.fromRGB(215, 225, 240),
    txtDim   = Color3.fromRGB(120, 130, 160),
    txtMuted = Color3.fromRGB(65,  70,  100),
    dropBg   = Color3.fromRGB(10,  10,  16),
    dropHov  = Color3.fromRGB(0,   50,  75),
    black    = Color3.fromRGB(0,   0,   0),
    white    = Color3.fromRGB(255, 255, 255),
    green    = Color3.fromRGB(0,   200, 110),
    greenDk  = Color3.fromRGB(0,   60,  35),
    red      = Color3.fromRGB(230, 55,  75),
    redDk    = Color3.fromRGB(85,  15,  22),
    orange   = Color3.fromRGB(230, 135, 0),
    orangeDk = Color3.fromRGB(70,  42,  0),
    slider   = Color3.fromRGB(28,  28,  40),
    toggle_on  = Color3.fromRGB(0,  180, 255),
    toggle_off = Color3.fromRGB(50, 52,  72),
    input    = Color3.fromRGB(12,  12,  18),
    notifBg  = Color3.fromRGB(18,  20,  30),
}

-- ─── Drawing Pool ────────────────────────────────────────────────────────────
local pool     = {}
local poolUsed = {}

local function getObj(key, dtype)
    if not pool[key] then
        pool[key] = Drawing.new(dtype)
        pool[key].Visible = false
    end
    poolUsed[key] = true
    return pool[key]
end

local function beginFrame() table.clear(poolUsed) end
local function endFrame()
    for k, d in pairs(pool) do
        if not poolUsed[k] then d.Visible = false end
    end
end

local _uid = 0
local function uid(prefix)
    _uid = _uid + 1
    return (prefix or "o") .. tostring(_uid)
end

local function sq(key,x,y,w,h,col,zi,filled)
    local d = getObj(key,"Square")
    d.Position  = Vector2.new(x,y)
    d.Size      = Vector2.new(w,h)
    d.Color     = col
    d.Filled    = (filled ~= false)
    d.Thickness = 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end
local function sqo(key,x,y,w,h,col,zi)   sq(key,x,y,w,h,col,zi,false) end

local function tx(key,text,x,y,sz,col,zi,center)
    local d = getObj(key,"Text")
    d.Text     = tostring(text)
    d.Position = Vector2.new(x,y)
    d.Size     = sz or 13
    d.Color    = col or C.txt
    d.Font     = Drawing.Fonts.UI
    d.Outline  = false
    d.Center   = (center==true)
    d.ZIndex   = zi or 2
    d.Visible  = true
end

local function ln(key,x1,y1,x2,y2,col,thick,zi)
    local d = getObj(key,"Line")
    d.From      = Vector2.new(x1,y1)
    d.To        = Vector2.new(x2,y2)
    d.Color     = col
    d.Thickness = thick or 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

local function circ(key,cx,cy,r,col,zi,sides)
    local d = getObj(key,"Circle")
    d.Position  = Vector2.new(cx,cy)
    d.Radius    = r
    d.Color     = col
    d.Filled    = true
    d.NumSides  = sides or 24
    d.Thickness = 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

local function hit(mx,my,x,y,w,h)
    return mx>=x and mx<=x+w and my>=y and my<=y+h
end

-- ─── VK Scan Table ──────────────────────────────────────────────────────────
local VK_SCAN = {
    {0x41,"A"},{0x42,"B"},{0x43,"C"},{0x44,"D"},{0x45,"E"},{0x46,"F"},
    {0x47,"G"},{0x48,"H"},{0x49,"I"},{0x4A,"J"},{0x4B,"K"},{0x4C,"L"},
    {0x4D,"M"},{0x4E,"N"},{0x4F,"O"},{0x50,"P"},{0x51,"Q"},{0x52,"R"},
    {0x53,"S"},{0x54,"T"},{0x55,"U"},{0x56,"V"},{0x57,"W"},{0x58,"X"},
    {0x59,"Y"},{0x5A,"Z"},
    {0x30,"0"},{0x31,"1"},{0x32,"2"},{0x33,"3"},{0x34,"4"},
    {0x35,"5"},{0x36,"6"},{0x37,"7"},{0x38,"8"},{0x39,"9"},
    {0x70,"F1"},{0x71,"F2"},{0x72,"F3"},{0x73,"F4"},{0x74,"F5"},
    {0x75,"F6"},{0x76,"F7"},{0x77,"F8"},{0x78,"F9"},{0x79,"F10"},
    {0x7A,"F11"},{0x7B,"F12"},
    {0x2D,"Insert"},{0x2E,"Delete"},{0x24,"Home"},{0x23,"End"},
    {0x21,"PageUp"},{0x22,"PageDown"},
    {0x26,"Up"},{0x28,"Down"},{0x25,"Left"},{0x27,"Right"},
    {0x60,"Num0"},{0x61,"Num1"},{0x62,"Num2"},{0x63,"Num3"},{0x64,"Num4"},
    {0x65,"Num5"},{0x66,"Num6"},{0x67,"Num7"},{0x68,"Num8"},{0x69,"Num9"},
    {0x20,"Space"},{0xBC,"Comma"},{0xBE,"Period"},{0xBF,"Slash"},
    {0x10,"Shift"},{0x11,"Ctrl"},{0x12,"Alt"},
}

local KEYMAP = {}
do
    for _,c in ipairs({"A","B","C","D","E","F","G","H","I","J","K","L","M",
                        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}) do
        pcall(function() KEYMAP[Enum.KeyCode[c]]=c:lower() end)
    end
    local ns={"Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
    for i,n in ipairs(ns) do pcall(function() KEYMAP[Enum.KeyCode[n]]=tostring(i-1) end) end
    pcall(function() KEYMAP[Enum.KeyCode.Minus]  = "-" end)
    pcall(function() KEYMAP[Enum.KeyCode.Period] = "." end)
    pcall(function() KEYMAP[Enum.KeyCode.Space]  = " " end)
end

local prevVK = {}
local function vkEdge(vk)
    local now  = iskeypressed(vk)
    local prev = prevVK[vk] or false
    prevVK[vk] = now
    return now and not prev
end

-- ─── Layout Constants ────────────────────────────────────────────────────────
local WW       = 560
local WH       = 460
local SIDEBAR  = 120
local TOPBAR   = 48
local CONTENT_PAD = 10
local TAB_H    = 34
local ELEM_H   = 44  -- standard element card height
local ELEM_GAP = 6

-- ─── Notifications Queue ─────────────────────────────────────────────────────
local notifQueue = {}
local NOTIF_W = 300
local NOTIF_H = 60

-- ─── Library State ───────────────────────────────────────────────────────────
local MatchaUI = {}
MatchaUI.__index = MatchaUI

local _windowInst = nil  -- only one window at a time

-- ─── Window ──────────────────────────────────────────────────────────────────
function MatchaUI:CreateWindow(cfg)
    local self = setmetatable({}, MatchaUI)

    -- config
    self.Name      = cfg.Name     or "MatchaUI"
    self.Subtitle  = cfg.Subtitle or ""
    self.ToggleKey = cfg.ToggleKey     or 0x71  -- F2
    self.ToggleKeyName = cfg.ToggleKeyName or "F2"
    self.Visible   = true

    -- position
    VP = workspace.CurrentCamera.ViewportSize
    self.WX = math.floor((VP.X - WW) / 2)
    self.WY = math.floor((VP.Y - WH) / 2)

    -- drag
    self.dragOn = false
    self.dragOX = 0
    self.dragOY = 0

    -- tabs
    self.tabs     = {}
    self.activeTab = 1

    -- zones (rebuilt every frame)
    self.zones    = {}
    self.ddZones  = {}

    -- dropdown state
    self.DD       = nil
    self.ddScrollDragging = false
    self.ddScrollDragStartY  = 0
    self.ddScrollDragStartOff = 0

    -- keybind listening
    self.bindListening  = false
    self.bindTarget     = nil  -- keybind element currently listening

    -- scroll per tab
    self.scrollOff = {}

    -- color picker state
    self.cpOpen = nil  -- open ColorPicker element

    -- notification list
    self.notifs = {}

    _windowInst = self

    -- Show loading screen
    if cfg.LoadingTitle then
        self:_showLoading(cfg.LoadingTitle, cfg.LoadingSubtitle or "")
    end

    -- Start render loop
    self:_startLoop()

    return self
end

function MatchaUI:_showLoading(title, sub)
    local lw, lh = 320, 100
    local lx = math.floor((VP.X - lw) / 2)
    local ly = math.floor((VP.Y - lh) / 2)
    local k = uid("load")

    sq(k.."bg",  lx,   ly,   lw, lh, C.bg,     50)
    sqo(k.."bd", lx,   ly,   lw, lh, C.acc,    51)
    sq(k.."tl",  lx,   ly,   lw, 2,  C.acc,    52)
    tx(k.."t",   title, lx+lw/2, ly+20, 16, C.acc,    53, true)
    tx(k.."s",   sub,   lx+lw/2, ly+44, 12, C.txtDim, 53, true)

    -- animated dots
    task.spawn(function()
        local dots = {"   ","·  ","·· ","···"}
        local di = 1
        for _ = 1, 12 do
            local d = getObj(k.."dot","Text")
            d.Text = dots[di]
            d.Position = Vector2.new(lx+lw/2, ly+62)
            d.Size = 14; d.Color = C.acc; d.Font = Drawing.Fonts.UI
            d.Outline = false; d.Center = true; d.ZIndex = 54; d.Visible = true
            di = (di % #dots) + 1
            task.wait(0.15)
        end
        -- hide loading
        pool[k.."bg"].Visible  = false
        pool[k.."bd"].Visible  = false
        pool[k.."tl"].Visible  = false
        pool[k.."t"].Visible   = false
        pool[k.."s"].Visible   = false
        pool[k.."dot"].Visible = false
    end)
end

function MatchaUI:_addZone(x,y,w,h,fn)
    table.insert(self.zones,{x=x,y=y,w=w,h=h,fn=fn})
end
function MatchaUI:_addDDZone(x,y,w,h,fn)
    table.insert(self.ddZones,{x=x,y=y,w=w,h=h,fn=fn})
end

-- ─── Tab ─────────────────────────────────────────────────────────────────────
function MatchaUI:CreateTab(name, icon)
    local tab = {
        name     = name,
        icon     = icon,
        elements = {},
        scroll   = 0,
    }
    table.insert(self.tabs, tab)

    -- Create element-creation methods on tab
    local win = self

    function tab:CreateSection(name_)
        local el = {type="section", name=name_, id=uid("sec")}
        table.insert(self.elements, el)
        return el
    end

    function tab:CreateDivider()
        local el = {type="divider", id=uid("div")}
        table.insert(self.elements, el)
        return el
    end

    function tab:CreateLabel(text)
        local el = {type="label", text=text, id=uid("lbl")}
        table.insert(self.elements, el)
        return el
    end

    function tab:CreateButton(cfg_)
        local el = {
            type     = "button",
            name     = cfg_.Name or "Button",
            desc     = cfg_.Description or "",
            callback = cfg_.Callback or function() end,
            id       = uid("btn"),
        }
        table.insert(self.elements, el)
        return el
    end

    function tab:CreateToggle(cfg_)
        local el = {
            type     = "toggle",
            name     = cfg_.Name or "Toggle",
            desc     = cfg_.Description or "",
            value    = cfg_.Default or false,
            callback = cfg_.Callback or function() end,
            id       = uid("tgl"),
        }
        table.insert(self.elements, el)
        -- Return object with :Set()
        local obj = {}
        function obj:Set(v)
            el.value = v
            pcall(el.callback, v)
        end
        return obj
    end

    function tab:CreateSlider(cfg_)
        local el = {
            type     = "slider",
            name     = cfg_.Name or "Slider",
            desc     = cfg_.Description or "",
            min      = cfg_.Min or 0,
            max      = cfg_.Max or 100,
            value    = cfg_.Default or 0,
            suffix   = cfg_.Suffix or "",
            dragging = false,
            callback = cfg_.Callback or function() end,
            id       = uid("sld"),
        }
        table.insert(self.elements, el)
        local obj = {}
        function obj:Set(v)
            el.value = math.clamp(v, el.min, el.max)
            pcall(el.callback, el.value)
        end
        return obj
    end

    function tab:CreateDropdown(cfg_)
        local el = {
            type     = "dropdown",
            name     = cfg_.Name or "Dropdown",
            desc     = cfg_.Description or "",
            options  = cfg_.Options or {},
            value    = cfg_.Default or (cfg_.Options and cfg_.Options[1]) or "",
            callback = cfg_.Callback or function() end,
            id       = uid("dd"),
        }
        table.insert(self.elements, el)
        local obj = {}
        function obj:Set(v)
            el.value = v
            pcall(el.callback, v)
        end
        function obj:Refresh(opts, newDefault)
            el.options = opts
            el.value = newDefault or (opts and opts[1]) or ""
        end
        return obj
    end

    function tab:CreateTextbox(cfg_)
        local el = {
            type        = "textbox",
            name        = cfg_.Name or "Textbox",
            desc        = cfg_.Description or "",
            placeholder = cfg_.Placeholder or "Type here...",
            value       = cfg_.Default or "",
            active      = false,
            callback    = cfg_.Callback or function() end,
            id          = uid("tbx"),
        }
        table.insert(self.elements, el)
        -- UIS hook for typing
        UIS.InputBegan:Connect(function(input)
            if not el.active then return end
            local kc = input.KeyCode
            if not kc then return end
            if kc == Enum.KeyCode.BackSpace then
                el.value = el.value:sub(1,-2)
            elseif kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter then
                el.active = false
                pcall(el.callback, el.value)
            elseif kc == Enum.KeyCode.Escape then
                el.active = false
            else
                local ch = KEYMAP[kc]
                if ch then
                    local shift = iskeypressed(0xA0) or iskeypressed(0xA1)
                    el.value = el.value .. (shift and ch:upper() or ch)
                end
            end
        end)
        local obj = {}
        function obj:Set(v) el.value = v end
        return obj
    end

    function tab:CreateKeybind(cfg_)
        local el = {
            type        = "keybind",
            name        = cfg_.Name or "Keybind",
            desc        = cfg_.Description or "",
            vk          = cfg_.Default or 0x70,
            vkName      = cfg_.DefaultName or "F1",
            listening   = false,
            callback    = cfg_.Callback or function() end,
            id          = uid("kb"),
        }
        table.insert(self.elements, el)
        local obj = {}
        function obj:Set(vk, vkName)
            el.vk = vk; el.vkName = vkName or "?"
        end
        return obj
    end

    function tab:CreateColorPicker(cfg_)
        local el = {
            type     = "colorpicker",
            name     = cfg_.Name or "Color",
            desc     = cfg_.Description or "",
            value    = cfg_.Default or Color3.fromRGB(255,255,255),
            open     = false,
            -- HSV state
            h = 0, s = 1, v = 1,
            callback = cfg_.Callback or function() end,
            id       = uid("cp"),
        }
        -- init HSV from default
        do
            local col = el.value
            -- simple RGB→HSV
            local r,g,b = col.R, col.G, col.B
            local mx2 = math.max(r,g,b)
            local mn2 = math.min(r,g,b)
            local d2  = mx2 - mn2
            el.v = mx2
            el.s = mx2==0 and 0 or d2/mx2
            if d2==0 then el.h=0
            elseif mx2==r then el.h=((g-b)/d2)%6
            elseif mx2==g then el.h=(b-r)/d2+2
            else el.h=(r-g)/d2+4 end
            el.h = el.h/6
        end
        table.insert(self.elements, el)
        local obj = {}
        function obj:Set(col)
            el.value = col; pcall(el.callback, col)
        end
        return obj
    end

    return tab
end

-- ─── Notifications ────────────────────────────────────────────────────────────
function MatchaUI:Notify(cfg)
    table.insert(self.notifs, {
        title    = cfg.Title or "Notice",
        content  = cfg.Content or "",
        duration = cfg.Duration or 3,
        expires  = tick() + (cfg.Duration or 3),
        id       = uid("nf"),
        entering = true,
        enterT   = tick(),
    })
end

-- ─── Destroy ─────────────────────────────────────────────────────────────────
function MatchaUI:Destroy()
    self._destroyed = true
    for _,d in pairs(pool) do
        pcall(function() d.Visible = false end)
    end
end

-- ─── Element height helpers ──────────────────────────────────────────────────
local function elemH(el)
    if el.type == "section" then return 26 end
    if el.type == "divider" then return 14 end
    if el.type == "label"   then return 24 end
    if el.type == "slider"  then return 54 end
    return ELEM_H
end

-- ─── Render an element ───────────────────────────────────────────────────────
function MatchaUI:_renderElement(el, ex, ey, ew, mx, my, zi)
    local p = el.id.."_"

    if el.type == "section" then
        tx(p.."lbl", el.name:upper(), ex, ey+6, 10, C.acc, zi+1)
        ln(p.."ln", ex + #el.name*6+6, ey+11, ex+ew, ey+11, C.accDim, 1, zi)
        return
    end

    if el.type == "divider" then
        ln(p.."ln", ex, ey+7, ex+ew, ey+7, C.bord, 1, zi)
        return
    end

    if el.type == "label" then
        tx(p.."tx", el.text, ex, ey+5, 12, C.txtDim, zi+1)
        return
    end

    -- Card background for all other elements
    local eH = elemH(el)
    local hov = hit(mx,my,ex,ey,ew,eH)
    sq(p.."bg",  ex,   ey,   ew, eH, hov and C.cardHov or C.card, zi)
    sqo(p.."bd", ex,   ey,   ew, eH, C.bord, zi+1)

    -- Left accent pip on hover
    if hov then
        sq(p.."pip", ex, ey, 2, eH, C.acc, zi+2)
    end

    -- Name + desc
    if el.type ~= "slider" then
        tx(p.."nm",  el.name, ex+12, ey + (el.desc~="" and 8 or 15), 13, C.txt, zi+2)
        if el.desc and el.desc ~= "" then
            tx(p.."ds", el.desc, ex+12, ey+24, 11, C.txtMuted, zi+2)
        end
    else
        tx(p.."nm", el.name, ex+12, ey+8, 13, C.txt, zi+2)
    end

    -- ── Button ──
    if el.type == "button" then
        local bw = 70; local bx = ex+ew-bw-10; local by = ey+10
        sq(p.."cbg",  bx, by, bw, 24, C.accDim,  zi+3)
        sqo(p.."cbd", bx, by, bw, 24, C.acc,     zi+4)
        tx(p.."ctx",  "Execute", bx+bw/2, by+6, 11, C.white, zi+5, true)
        self:_addZone(ex,ey,ew,eH,function()
            pcall(el.callback)
        end)

    -- ── Toggle ──
    elseif el.type == "toggle" then
        local pw = 38; local ph = 18
        local px = ex+ew-pw-10; local py = ey+13
        local on = el.value
        sq(p.."pbg",  px, py, pw, ph, on and C.toggle_on or C.toggle_off, zi+3)
        sqo(p.."pbd", px, py, pw, ph, on and C.acc or C.bord, zi+4)
        local kx = on and (px+pw-ph+2) or (px+2)
        sq(p.."knb",  kx, py+2, ph-4, ph-4, on and C.white or C.txtMuted, zi+5)
        tx(p.."ptx",  on and "ON" or "OFF", px+pw/2, py+4, 9,
            on and C.white or C.txtMuted, zi+5, true)
        self:_addZone(ex,ey,ew,eH,function()
            el.value = not el.value
            pcall(el.callback, el.value)
        end)

    -- ── Slider ──
    elseif el.type == "slider" then
        local sw = ew-24; local sx = ex+12; local sy = ey+30
        local sh = 6
        local pct = (el.value - el.min) / (el.max - el.min)
        local fillW = math.floor(pct * sw)

        sq(p.."tr",  sx,     sy, sw, sh, C.slider, zi+3)
        sq(p.."fl",  sx,     sy, math.max(4,fillW), sh, C.acc, zi+4)
        circ(p.."kn", sx+fillW, sy+sh/2, 6, C.accGlow, zi+5)
        sqo(p.."trd",sx,     sy, sw, sh, C.bord, zi+3)

        local valStr = tostring(math.floor(el.value)) .. el.suffix
        tx(p.."val", valStr, ex+ew-14, ey+8, 12, C.accGlow, zi+3)

        -- slider drag
        if el.dragging then
            if ismouse1pressed() then
                local rx = math.clamp(mx - sx, 0, sw)
                local newPct = rx / sw
                el.value = el.min + newPct * (el.max - el.min)
                el.value = math.floor(el.value + 0.5)
                el.value = math.clamp(el.value, el.min, el.max)
                pcall(el.callback, el.value)
            else
                el.dragging = false
            end
        end
        -- start drag zone
        self:_addZone(sx, sy-6, sw, sh+12, function()
            el.dragging = true
        end)

    -- ── Dropdown ──
    elseif el.type == "dropdown" then
        local dw = 130; local dx = ex+ew-dw-10; local dy = ey+10
        local dh = 22
        local ddOpen = self.DD ~= nil and self.DD.tag == p.."dd"
        sq(p.."dbg",  dx, dy, dw, dh, C.dropBg, zi+3)
        sqo(p.."dbd", dx, dy, dw, dh, ddOpen and C.acc or C.bord, zi+4)
        tx(p.."dtx",  tostring(el.value), dx+8, dy+5, 12,
            ddOpen and C.accGlow or C.txtDim, zi+5)
        tx(p.."dar",  "v", dx+dw-12, dy+5, 12, C.txtMuted, zi+5)

        self:_addZone(dx,dy,dw,dh, function()
            if self.DD and self.DD.tag == p.."dd" then self.DD = nil; return end
            local iH = 20; local ms = math.min(8, #el.options)
            local popH = ms*iH+4
            local popY = dy+dh+1
            if popY+popH > self.WY+WH-4 then popY = dy-popH-1 end
            local so = 0
            for idx,v in ipairs(el.options) do
                if v==el.value then so=math.max(0,idx-math.floor(ms/2)); break end
            end
            self.DD = {
                x=dx, y=popY, w=dw, h=popH,
                items=el.options, cur=el.value,
                scrollOff=so, maxShow=ms, itemH=iH,
                tag=p.."dd", hovIdx=0,
                onSelect=function(c)
                    el.value=c; pcall(el.callback,c); self.DD=nil
                end
            }
        end)

    -- ── Textbox ──
    elseif el.type == "textbox" then
        local tw2 = 140; local tx2 = ex+ew-tw2-10; local ty2 = ey+10
        local th2 = 24
        sq(p.."tbg",  tx2, ty2, tw2, th2, C.input, zi+3)
        sqo(p.."tbd", tx2, ty2, tw2, th2, el.active and C.acc or C.bord, zi+4)
        local disp = el.active and (el.value..(tick()%1>0.5 and "|" or "")) or
            (el.value~="" and el.value or el.placeholder)
        tx(p.."ttx",  disp, tx2+6, ty2+6, 12,
            el.active and C.txt or (el.value~="" and C.txt or C.txtMuted), zi+5)
        self:_addZone(tx2,ty2,tw2,th2,function()
            -- deactivate all others
            for _,t in ipairs(self.tabs) do
                for _,e in ipairs(t.elements) do
                    if e.type=="textbox" then e.active=false end
                end
            end
            el.active=true
        end)

    -- ── Keybind ──
    elseif el.type == "keybind" then
        local kbW = math.max(52, #el.vkName*8+16)
        local kbX = ex+ew-kbW-10; local kbY = ey+12; local kbH = 20
        if el.listening then
            sq(p.."kbg",  kbX,kbY,kbW,kbH, C.redDk, zi+3)
            sqo(p.."kbd", kbX,kbY,kbW,kbH, C.red,   zi+4)
            tx(p.."ktx","...", kbX+kbW/2,kbY+4, 11, C.red, zi+5, true)
        else
            sq(p.."kbg",  kbX,kbY,kbW,kbH, C.accDark, zi+3)
            sqo(p.."kbd", kbX,kbY,kbW,kbH, C.acc,     zi+4)
            tx(p.."ktx", el.vkName, kbX+kbW/2,kbY+4, 11, C.accGlow, zi+5, true)
        end
        self:_addZone(kbX,kbY,kbW,kbH,function()
            -- stop all other keybind listening
            for _,t in ipairs(self.tabs) do
                for _,e in ipairs(t.elements) do
                    if e.type=="keybind" then e.listening=false end
                end
            end
            el.listening = true
            self.bindTarget = el
        end)
        -- handle VK detection while listening
        if el.listening then
            if vkEdge(0x1B) then
                el.listening = false
                self.bindTarget = nil
            else
                for _,entry in ipairs(VK_SCAN) do
                    local vk2, nm2 = entry[1], entry[2]
                    if vkEdge(vk2) then
                        el.vk = vk2; el.vkName = nm2
                        el.listening = false
                        self.bindTarget = nil
                        pcall(el.callback)
                        break
                    end
                end
            end
        end

    -- ── ColorPicker ──
    elseif el.type == "colorpicker" then
        local swW = 28; local swX = ex+ew-swW-10; local swY = ey+10; local swH = 24
        sq(p.."sw",   swX, swY, swW, swH, el.value, zi+3)
        sqo(p.."swd", swX, swY, swW, swH, C.bord,   zi+4)
        self:_addZone(swX,swY,swW,swH, function()
            el.open = not el.open
        end)

        if el.open then
            self:_renderColorPicker(el, ex, ey+eH+2, ew, mx, my, zi+10)
        end
    end
end

-- ─── Color Picker Popup ──────────────────────────────────────────────────────
function MatchaUI:_renderColorPicker(el, ex, py, ew, mx, my, zi)
    local p  = el.id.."_cp_"
    local pw = ew
    local ph = 120
    -- clamp to window
    if py + ph > self.WY+WH-4 then py = py - elemH(el) - ph - 4 end

    sq(p.."bg",  ex,   py,   pw, ph, C.dropBg, zi)
    sqo(p.."bd", ex,   py,   pw, ph, C.acc,    zi+1)

    -- Hue bar (full width, 12px tall)
    local hbX = ex+8; local hbY = py+8; local hbW = pw-16; local hbH = 12
    -- Draw hue gradient via segments
    for i=0,hbW-1 do
        local hh = i/hbW
        ln(p.."hg"..i, hbX+i, hbY, hbX+i, hbY+hbH,
            Color3.fromHSV(hh, 1, 1), 1, zi+2)
    end
    sqo(p.."hbd", hbX, hbY, hbW, hbH, C.bord, zi+3)
    -- hue handle
    local hkX = hbX + math.floor(el.h * hbW)
    sq(p.."hk",  hkX-2, hbY-2, 4, hbH+4, C.white, zi+4)

    -- Saturation/Value box
    local svX = ex+8; local svY = hbY+hbH+8; local svW = pw-16; local svH = 60
    for xi=0,svW-1 do
        for yi=0,svH-1 do
            -- sample every 3 pixels for performance
            if xi%3==0 and yi%3==0 then
                local s2 = xi/svW
                local v2 = 1-(yi/svH)
                ln(p.."sv"..xi.."_"..yi,
                    svX+xi, svY+yi, svX+xi, svY+yi+3,
                    Color3.fromHSV(el.h, s2, v2), 1, zi+2)
            end
        end
    end
    sqo(p.."svbd",svX,svY,svW,svH, C.bord, zi+3)
    -- SV handle
    local skX = svX + math.floor(el.s * svW)
    local skY = svY + math.floor((1-el.v) * svH)
    circ(p.."svk", skX, skY, 5, C.white, zi+4)

    -- Preview swatch
    local pvX = ex+pw-40; local pvY = py+ph-28; local pvW = 32; local pvH = 20
    sq(p.."pv",  pvX, pvY, pvW, pvH, el.value, zi+3)
    sqo(p.."pvd",pvX, pvY, pvW, pvH, C.bord,   zi+4)

    -- HEX label
    local function toHex(c)
        return string.format("%02X%02X%02X",
            math.floor(c.R*255), math.floor(c.G*255), math.floor(c.B*255))
    end
    tx(p.."hex","#"..toHex(el.value), ex+10, py+ph-24, 11, C.txtDim, zi+3)

    -- Hue drag
    self:_addZone(hbX, hbY, hbW, hbH, function()
        -- handled in loop
    end)
    if ismouse1pressed() and hit(mx,my,hbX,hbY,hbW,hbH) then
        el.h = math.clamp((mx-hbX)/hbW, 0, 1)
        el.value = Color3.fromHSV(el.h, el.s, el.v)
        pcall(el.callback, el.value)
    end
    -- SV drag
    if ismouse1pressed() and hit(mx,my,svX,svY,svW,svH) then
        el.s = math.clamp((mx-svX)/svW, 0, 1)
        el.v = 1 - math.clamp((my-svY)/svH, 0, 1)
        el.value = Color3.fromHSV(el.h, el.s, el.v)
        pcall(el.callback, el.value)
    end
end

-- ─── Render Notifications ────────────────────────────────────────────────────
function MatchaUI:_renderNotifs()
    -- clean expired
    local now = tick()
    for i=#self.notifs,1,-1 do
        if now > self.notifs[i].expires then
            table.remove(self.notifs,i)
        end
    end

    local baseX = VP.X - NOTIF_W - 14
    local baseY = VP.Y - 14

    for i,n in ipairs(self.notifs) do
        local ny = baseY - i*(NOTIF_H+8)
        local p  = n.id.."_"

        -- slide-in from right
        local age = now - n.enterT
        local slide = math.min(1, age/0.25)
        local nx = baseX + NOTIF_W*(1-slide)

        sq(p.."sh",  nx+3, ny+3, NOTIF_W, NOTIF_H, C.black,  44)
        sq(p.."bg",  nx,   ny,   NOTIF_W, NOTIF_H, C.notifBg,45)
        sqo(p.."bd", nx,   ny,   NOTIF_W, NOTIF_H, C.acc,     46)
        sq(p.."tl",  nx,   ny,   4,       NOTIF_H, C.acc,     47)
        sq(p.."lt",  nx,   ny,   NOTIF_W, 1,       C.acc,     47)

        tx(p.."tt",  n.title,   nx+14, ny+10, 14, C.acc,    48)
        tx(p.."ct",  n.content, nx+14, ny+28, 12, C.txtDim, 48)

        -- time bar
        local pct  = math.max(0, (n.expires-now)/n.duration)
        local barW = math.floor(pct * (NOTIF_W-8))
        sq(p.."tbr", nx+4, ny+NOTIF_H-4, NOTIF_W-8, 2, C.bord, 48)
        if barW > 0 then
            sq(p.."tbl", nx+4, ny+NOTIF_H-4, barW, 2, C.acc, 49)
        end
    end
end

-- ─── Main Render ─────────────────────────────────────────────────────────────
function MatchaUI:_render(mx, my)
    beginFrame()
    table.clear(self.zones)
    table.clear(self.ddZones)

    self:_renderNotifs()

    if not self.Visible then
        endFrame()
        return
    end

    local WX = self.WX; local WY = self.WY

    -- ── Window shell ──
    sq("w_sh",  WX+4, WY+4, WW,    WH,    C.black,   0)
    sq("w_bg",  WX,   WY,   WW,    WH,    C.bg,      1)
    sqo("w_bd", WX,   WY,   WW,    WH,    C.bord,    2)
    sq("w_el",  WX,   WY,   2,     WH,    C.acc,     3)
    sq("w_et",  WX,   WY,   WW,    1,     C.acc,     3)

    -- ── Topbar ──
    sq("tb_bg", WX, WY,      WW, TOPBAR, C.sidebar, 2)
    sq("tb_ln", WX, WY+TOPBAR-1, WW, 1, C.acc,     3)
    tx("tb_nm", self.Name,    WX+16, WY+10, 15, C.txt,    4)
    tx("tb_sb", self.Subtitle,WX+16, WY+28, 11, C.txtDim, 4)
    tx("tb_hnt",self.ToggleKeyName.." toggle", WX+WW-90, WY+19, 11, C.txtMuted, 4)

    -- Close button
    sq("tb_cx",  WX+WW-28, WY+12, 16, 16, C.redDk, 4)
    sqo("tb_cxd",WX+WW-28, WY+12, 16, 16, C.red,   5)
    tx("tb_cxt", "X",  WX+WW-20, WY+15, 11, C.red, 6, true)
    self:_addZone(WX+WW-28, WY+12, 16, 16, function()
        self.Visible = false
    end)

    -- drag zone on topbar
    self:_addZone(WX, WY, WW-34, TOPBAR, function()
        self.dragOn=true; self.dragOX=mx-WX; self.dragOY=my-WY
    end)

    -- ── Sidebar ──
    sq("sb_bg",  WX,          WY+TOPBAR, SIDEBAR, WH-TOPBAR, C.sidebar, 2)
    sq("sb_sep", WX+SIDEBAR-1,WY+TOPBAR, 1,       WH-TOPBAR, C.bord,   3)

    for i,tab in ipairs(self.tabs) do
        local ty  = WY+TOPBAR + (i-1)*TAB_H
        local isA = (i==self.activeTab)
        local p   = "stb"..i.."_"
        sq(p.."bg",  WX,   ty,   SIDEBAR, TAB_H, isA and C.accDark or C.sidebar, 4)
        sq(p.."pip", WX,   ty,   3,       TAB_H, isA and C.acc or C.bord,        5)
        sq(p.."bot", WX,   ty+TAB_H-1, SIDEBAR, 1, C.bord, 4)
        tx(p.."lb",  tab.name, WX+14, ty+math.floor((TAB_H-13)/2), 13,
            isA and C.acc or C.txtDim, 5)
        local ci=i
        self:_addZone(WX,ty,SIDEBAR,TAB_H,function()
            if self.activeTab~=ci then self.activeTab=ci; self.DD=nil end
        end)
    end

    -- ── Content area ──
    local cx = WX+SIDEBAR
    local cy = WY+TOPBAR
    local cw = WW-SIDEBAR
    local ch = WH-TOPBAR

    sq("ct_bg", cx, cy, cw, ch, C.bgPanel, 2)

    local tab = self.tabs[self.activeTab]
    if not tab then endFrame(); return end

    -- measure total height
    local totalH = CONTENT_PAD
    for _,el in ipairs(tab.elements) do
        totalH = totalH + elemH(el) + ELEM_GAP
    end

    -- scroll
    local maxScroll = math.max(0, totalH - ch + CONTENT_PAD)
    if not tab.scroll then tab.scroll = 0 end
    tab.scroll = math.clamp(tab.scroll, 0, maxScroll)

    -- scrollbar
    if maxScroll > 0 then
        local sbX = cx+cw-5; local sbY = cy+2; local sbH2 = ch-4
        sq("ctsb_t",sbX,sbY,4,sbH2, C.bord, 5)
        local tH = math.max(20, math.floor(sbH2*(ch/totalH)))
        local tY = sbY + math.floor((sbH2-tH)*(tab.scroll/maxScroll))
        sq("ctsb_h",sbX,tY,4,tH, C.acc, 6)
    end

    -- clip: only render elements visible in window
    local ey0 = cy + CONTENT_PAD - tab.scroll
    local elemW = cw - CONTENT_PAD*2 - (maxScroll>0 and 8 or 0)

    for _,el in ipairs(tab.elements) do
        local eH = elemH(el)
        local ey  = ey0
        if ey+eH >= cy and ey <= cy+ch then
            self:_renderElement(el, cx+CONTENT_PAD, ey, elemW, mx, my, 5)
        end
        ey0 = ey0 + eH + ELEM_GAP
    end

    -- ── Dropdown overlay ──
    if self.DD then
        local d = self.DD
        local x,y,w,h = d.x, d.y, d.w, d.h
        local maxSc  = math.max(0, #d.items - d.maxShow)
        d.scrollOff  = math.clamp(d.scrollOff, 0, maxSc)
        local hasSb  = maxSc > 0
        local sbW2   = 5
        local itemW  = hasSb and (w-sbW2-1) or w

        sq("ddo_sh",  x+3, y+3, w, h, C.black,  28)
        sq("ddo_bg",  x,   y,   w, h, C.dropBg, 29)
        sqo("ddo_bd", x,   y,   w, h, C.acc,    30)
        sq("ddo_tl",  x,   y,   w, 2, C.acc,    31)

        if hasSb then
            local sbX2 = x+w-sbW2; local sbY2 = y+2; local sbH3 = h-4
            local tH2  = math.max(14,math.floor(sbH3*(d.maxShow/#d.items)))
            local tY2  = sbY2+math.floor((sbH3-tH2)*(d.scrollOff/maxSc))
            sq("ddo_str",sbX2,sbY2,sbW2,sbH3, C.bord, 32)
            sq("ddo_sth",sbX2,tY2, sbW2,tH2,  C.acc,  33)
            self:_addDDZone(sbX2,tY2,sbW2,tH2, function()
                self.ddScrollDragging     = true
                self.ddScrollDragStartY   = my
                self.ddScrollDragStartOff = d.scrollOff
            end)
        end

        local hov = 0
        if hit(mx,my,x,y,itemW,h) then
            hov = math.floor((my-y)/d.itemH)+1
            if hov<1 or hov>d.maxShow then hov=0 end
        end
        d.hovIdx = hov

        for i=1,d.maxShow do
            local idx = i+d.scrollOff
            if idx <= #d.items then
                local iy   = y+(i-1)*d.itemH
                local isSel = d.items[idx]==d.cur
                local isHov = d.hovIdx==i
                if isSel then
                    sq("ddi_b"..i, x+1,iy,itemW-2,d.itemH-1, C.accDark, 31)
                    ln("ddi_l"..i, x+1,iy,x+1,iy+d.itemH-2, C.acc, 2, 32)
                elseif isHov then
                    sq("ddi_b"..i, x+1,iy,itemW-2,d.itemH-1, C.dropHov, 31)
                end
                tx("ddi_t"..i, d.items[idx], x+10, iy+3, 13,
                    isSel and C.accGlow or (isHov and C.txt or C.txtDim), 32)
            end
        end
    end

    endFrame()
end

-- ─── Main Loop ───────────────────────────────────────────────────────────────
function MatchaUI:_startLoop()
    local prevM1 = false
    local lastScroll = 0

    task.spawn(function()
        while not self._destroyed do
            task.wait()

            VP = workspace.CurrentCamera.ViewportSize

            local mx = mouse.X
            local my = mouse.Y
            local m1 = ismouse1pressed()
            local justClicked = m1 and not prevM1
            prevM1 = m1

            -- Toggle visibility
            if vkEdge(self.ToggleKey) then
                self.Visible = not self.Visible
                if not self.Visible then self.DD = nil end
            end

            -- Drag window
            if self.dragOn then
                if m1 then
                    self.WX = math.clamp(mx-self.dragOX, 0, VP.X-WW)
                    self.WY = math.clamp(my-self.dragOY, 0, VP.Y-WH)
                    self.DD = nil
                else
                    self.dragOn = false
                end
                justClicked = false
            end

            -- Scroll DD
            if self.ddScrollDragging then
                if m1 and self.DD then
                    local d = self.DD
                    local maxDD = math.max(0, #d.items - d.maxShow)
                    local sbH = d.h-4
                    local tH  = math.max(14, math.floor(sbH*(d.maxShow/#d.items)))
                    local trk = sbH-tH
                    if trk>0 then
                        local ratio = (my-self.ddScrollDragStartY)/trk
                        d.scrollOff = math.clamp(
                            math.floor(self.ddScrollDragStartOff + ratio*maxDD+0.5),
                            0,maxDD)
                    end
                else
                    self.ddScrollDragging = false
                end
            end

            -- Mouse scroll for content
            if self.Visible and not self.DD then
                local now2 = tick()
                if now2 - lastScroll > 0.08 then
                    local tab = self.tabs[self.activeTab]
                    if tab then
                        if iskeypressed(0x26) or iskeypressed(0x57) then
                            tab.scroll = math.max(0, (tab.scroll or 0) - 14)
                            lastScroll = now2
                        elseif iskeypressed(0x28) or iskeypressed(0x53) then
                            tab.scroll = (tab.scroll or 0) + 14
                            lastScroll = now2
                        end
                    end
                end
            end

            -- Click handling
            if justClicked and self.Visible then
                if self.DD then
                    if hit(mx,my,self.DD.x,self.DD.y,self.DD.w,self.DD.h) then
                        local hitDDZ = false
                        for _,z in ipairs(self.ddZones) do
                            if hit(mx,my,z.x,z.y,z.w,z.h) then z.fn(); hitDDZ=true; break end
                        end
                        if not hitDDZ then
                            local hasSb = math.max(0,#self.DD.items-self.DD.maxShow)>0
                            local itemW = hasSb and (self.DD.w-6) or self.DD.w
                            if hit(mx,my,self.DD.x,self.DD.y,itemW,self.DD.h) then
                                local idx = math.floor((my-self.DD.y)/self.DD.itemH)+1+self.DD.scrollOff
                                if idx>=1 and idx<=#self.DD.items then
                                    self.DD.onSelect(self.DD.items[idx])
                                end
                            end
                        end
                    else
                        self.DD = nil
                    end
                else
                    -- deactivate textboxes when clicking outside
                    for _,t in ipairs(self.tabs) do
                        for _,e in ipairs(t.elements) do
                            if e.type=="textbox" then e.active=false end
                        end
                    end
                    for _,z in ipairs(self.zones) do
                        if hit(mx,my,z.x,z.y,z.w,z.h) then z.fn(); break end
                    end
                end
            end

            local ok, err = pcall(self._render, self, mx, my)
            if not ok then
                local d = getObj("_mui_err","Text")
                d.Text     = "[MatchaUI ERROR] "..tostring(err)
                d.Position = Vector2.new(10,50)
                d.Size     = 12; d.Color = Color3.fromRGB(255,80,80)
                d.Font     = Drawing.Fonts.UI; d.Outline = false
                d.Center   = false; d.ZIndex = 99; d.Visible = true
            end
        end
    end)
end

-- ─── Return library ──────────────────────────────────────────────────────────
return MatchaUI
