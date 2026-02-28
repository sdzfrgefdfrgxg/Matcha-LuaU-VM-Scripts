--[[
    MatchaUI Library — Fixed v1.1
    API: UI:Init, UI:Tab, tab:Section, section:Button/Toggle/Slider/Dropdown/Textbox/Keybind/Label/Divider
    UI:Notify, UI:Step (no-op, loop is internal)
]]

local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer
local mouse   = player:GetMouse()
local VP      = workspace.CurrentCamera.ViewportSize

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
-- Each object is identified by a key. Every frame we track which keys were
-- actually used; anything not used gets hidden. This ensures objects from
-- previous tabs / closed dropdowns disappear immediately.
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

local function beginFrame()
    table.clear(poolUsed)
end

local function endFrame()
    for k, d in pairs(pool) do
        if not poolUsed[k] then
            d.Visible = false
        end
    end
end

local _uid = 0
local function uid(prefix)
    _uid = _uid + 1
    return (prefix or "o") .. tostring(_uid)
end

-- ─── Drawing helpers ────────────────────────────────────────────────────────
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
local function sqo(key,x,y,w,h,col,zi) sq(key,x,y,w,h,col,zi,false) end

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
    {0x20,"Space"},
}

-- String key → VK lookup
local STR_TO_VK = {}
local VK_TO_NAME = {}
for _,entry in ipairs(VK_SCAN) do
    local vk, nm = entry[1], entry[2]
    STR_TO_VK[nm:lower()] = vk
    STR_TO_VK[nm]          = vk
    VK_TO_NAME[vk]         = nm
end

local KEYMAP = {}
do
    for _,c in ipairs({"A","B","C","D","E","F","G","H","I","J","K","L","M",
                        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}) do
        pcall(function() KEYMAP[Enum.KeyCode[c]]=c:lower() end)
    end
    local ns={"Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
    for i,n in ipairs(ns) do pcall(function() KEYMAP[Enum.KeyCode[n]]=tostring(i-1) end) end
    pcall(function() KEYMAP[Enum.KeyCode.BackSpace]  = nil end)
    pcall(function() KEYMAP[Enum.KeyCode.Period] = "." end)
    pcall(function() KEYMAP[Enum.KeyCode.Space]  = " " end)
end

local prevVK = {}
local function vkEdge(vk)
    local now2  = iskeypressed(vk)
    local prev  = prevVK[vk] or false
    prevVK[vk]  = now2
    return now2 and not prev
end

-- ─── Layout ──────────────────────────────────────────────────────────────────
local WW          = 560
local WH          = 460
local SIDEBAR     = 120
local TOPBAR      = 48
local CONTENT_PAD = 10
local TAB_H       = 34
local ELEM_H      = 44
local ELEM_GAP    = 6
local NOTIF_W     = 300
local NOTIF_H     = 60

-- ─── Library ─────────────────────────────────────────────────────────────────
local MatchaUI = {}
MatchaUI.__index = MatchaUI

local function elemH(el)
    if el.type == "section" then return 26 end
    if el.type == "divider" then return 14 end
    if el.type == "label"   then return 24 end
    if el.type == "slider"  then return 54 end
    return ELEM_H
end

-- ─── Init (entry point matching your script's API) ───────────────────────────
function MatchaUI:Init(cfg)
    local win       = setmetatable({}, MatchaUI)
    win.Name        = cfg.Title    or "MatchaUI"
    win.Subtitle    = cfg.Subtitle or ""
    win.Visible     = true

    -- toggle key: accept string like 'f2' or a vk int
    local tk = cfg.ToggleKey
    if type(tk) == "string" then
        win.ToggleKey     = STR_TO_VK[tk:upper()] or STR_TO_VK[tk] or 0x71
        win.ToggleKeyName = tk:upper()
    else
        win.ToggleKey     = tk or 0x71
        win.ToggleKeyName = VK_TO_NAME[win.ToggleKey] or "F2"
    end

    VP = workspace.CurrentCamera.ViewportSize
    win.WX = math.floor((VP.X - WW) / 2)
    win.WY = math.floor((VP.Y - WH) / 2)

    win.dragOn  = false
    win.dragOX  = 0
    win.dragOY  = 0

    win.tabs       = {}
    win.activeTab  = 1
    win.prevTab    = 0   -- track tab changes to force full redraw

    win.zones   = {}
    win.ddZones = {}

    -- dropdown state: nil when closed
    win.DD                  = nil
    win.ddScrollDragging    = false
    win.ddScrollDragStartY  = 0
    win.ddScrollDragStartOff= 0

    win.notifs   = {}
    win._destroyed = false

    win:_startLoop()
    return win
end

-- ─── Notify ──────────────────────────────────────────────────────────────────
-- Supports both:
--   UI:Notify("message", duration)
--   UI:Notify({Title=..., Content=..., Duration=...})
function MatchaUI:Notify(a, b)
    local title, content, duration
    if type(a) == "table" then
        title    = a.Title   or "Notice"
        content  = a.Content or ""
        duration = a.Duration or 3
    else
        title    = self.Name or "Notice"
        content  = tostring(a)
        duration = (type(b)=="number") and b or 3
    end
    table.insert(self.notifs, {
        title    = title,
        content  = content,
        duration = duration,
        expires  = tick() + duration,
        id       = uid("nf"),
        enterT   = tick(),
    })
end

-- ─── Step (no-op, loop is internal) ─────────────────────────────────────────
function MatchaUI:Step() end

-- ─── Destroy ─────────────────────────────────────────────────────────────────
function MatchaUI:Destroy()
    self._destroyed = true
    for _,d in pairs(pool) do
        pcall(function() d.Visible = false end)
    end
end

-- ─── Tab factory ─────────────────────────────────────────────────────────────
function MatchaUI:Tab(name)
    local tab = {
        name     = name,
        elements = {},
        scroll   = 0,
    }
    table.insert(self.tabs, tab)
    local win = self

    -- Section returns an object with element-creation methods
    function tab:Section(sname)
        -- Insert a section header element
        local secEl = {type="section", name=sname, id=uid("sec")}
        table.insert(self.elements, secEl)

        local sec = {}

        local function addEl(el)
            table.insert(tab.elements, el)
            return el
        end

        function sec:Button(name_, cb)
            addEl({type="button", name=name_, desc="", callback=cb or function() end, id=uid("btn")})
        end

        function sec:Toggle(name_, default_, cb)
            local el = {type="toggle", name=name_, desc="", value=default_ or false,
                        callback=cb or function() end, id=uid("tgl")}
            addEl(el)
            local obj = {}
            function obj:Set(v) el.value=v; pcall(el.callback,v) end
            return obj
        end

        function sec:Slider(name_, min_, max_, default_, cb)
            local el = {type="slider", name=name_, desc="", min=min_ or 0, max=max_ or 100,
                        value=default_ or 0, suffix="", dragging=false,
                        callback=cb or function() end, id=uid("sld")}
            addEl(el)
            local obj = {}
            function obj:Set(v) el.value=math.clamp(v,el.min,el.max); pcall(el.callback,el.value) end
            return obj
        end

        -- Dropdown: sec:Dropdown(name, defaults_table, options_table, multiselect, callback)
        -- defaults_table is a table like {"Standard"}, we use [1] as default value
        function sec:Dropdown(name_, defaults_, options_, multi_, cb)
            local defVal = (type(defaults_)=="table" and defaults_[1]) or defaults_ or ""
            local el = {
                type     = "dropdown",
                name     = name_,
                desc     = "",
                options  = options_ or {},
                value    = defVal,
                multi    = multi_ or false,
                callback = cb or function() end,
                id       = uid("dd"),
            }
            addEl(el)
            local obj = {}
            function obj:Set(v) el.value=v; pcall(el.callback,{v}) end
            function obj:Refresh(opts, newDef)
                el.options = opts
                el.value   = newDef or (opts and opts[1]) or ""
            end
            return obj
        end

        function sec:Textbox(name_, default_, cb)
            local el = {
                type        = "textbox",
                name        = name_,
                desc        = "",
                placeholder = "Type here...",
                value       = default_ or "",
                active      = false,
                callback    = cb or function() end,
                id          = uid("tbx"),
            }
            addEl(el)
            UIS.InputBegan:Connect(function(input)
                if not el.active then return end
                local kc = input.KeyCode
                if not kc then return end
                if kc == Enum.KeyCode.BackSpace then
                    el.value = el.value:sub(1,-2)
                elseif kc == Enum.KeyCode.Return or kc == Enum.KeyCode.KeypadEnter then
                    el.active = false; pcall(el.callback, el.value)
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
            function obj:Get() return el.value end
            function obj:Set(v) el.value=v end
            return obj
        end

        -- Keybind: sec:Keybind(name, defaultKeyStr, cb)
        function sec:Keybind(name_, defaultKey_, cb)
            local vk   = (type(defaultKey_)=="string") and (STR_TO_VK[defaultKey_:upper()] or STR_TO_VK[defaultKey_]) or (defaultKey_ or 0x70)
            local vkNm = VK_TO_NAME[vk] or tostring(defaultKey_):upper()
            local el = {
                type      = "keybind",
                name      = name_,
                desc      = "",
                vk        = vk,
                vkName    = vkNm,
                listening = false,
                callback  = cb or function() end,
                id        = uid("kb"),
            }
            addEl(el)
            local obj = {}
            function obj:Set(vk_, nm_) el.vk=vk_; el.vkName=nm_ or "?" end
            return obj
        end

        function sec:Label(text_)
            addEl({type="label", text=text_, id=uid("lbl")})
        end

        function sec:Divider()
            addEl({type="divider", id=uid("div")})
        end

        return sec
    end

    return tab
end

-- ─── Element Rendering ───────────────────────────────────────────────────────
function MatchaUI:_renderElement(el, ex, ey, ew, mx, my, zi)
    local p = el.id.."_"

    if el.type == "section" then
        tx(p.."lbl", el.name:upper(), ex, ey+6, 10, C.acc, zi+1)
        local lblW = #el.name * 6 + 6
        ln(p.."ln", ex+lblW, ey+11, ex+ew, ey+11, C.accDim, 1, zi)
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

    local eH  = elemH(el)
    local hov = hit(mx,my,ex,ey,ew,eH)
    sq(p.."bg",  ex, ey, ew, eH, hov and C.cardHov or C.card, zi)
    sqo(p.."bd", ex, ey, ew, eH, C.bord, zi+1)
    if hov then sq(p.."pip", ex, ey, 2, eH, C.acc, zi+2) end

    if el.type ~= "slider" then
        tx(p.."nm", el.name, ex+12, ey+15, 13, C.txt, zi+2)
    else
        tx(p.."nm", el.name, ex+12, ey+8, 13, C.txt, zi+2)
    end

    -- ── Button ──
    if el.type == "button" then
        local bw=70; local bx=ex+ew-bw-10; local by_=ey+10
        sq(p.."cbg",  bx, by_, bw, 24, C.accDim, zi+3)
        sqo(p.."cbd", bx, by_, bw, 24, C.acc,    zi+4)
        tx(p.."ctx",  "Execute", bx+bw/2, by_+6, 11, C.white, zi+5, true)
        self:_addZone(ex,ey,ew,eH, function() pcall(el.callback) end)

    -- ── Toggle ──
    elseif el.type == "toggle" then
        local pw=38; local ph=18
        local px=ex+ew-pw-10; local py_=ey+13
        local on=el.value
        sq(p.."pbg",  px, py_, pw, ph, on and C.toggle_on or C.toggle_off, zi+3)
        sqo(p.."pbd", px, py_, pw, ph, on and C.acc or C.bord, zi+4)
        local kx = on and (px+pw-ph+2) or (px+2)
        sq(p.."knb",  kx, py_+2, ph-4, ph-4, on and C.white or C.txtMuted, zi+5)
        tx(p.."ptx",  on and "ON" or "OFF", px+pw/2, py_+4, 9,
            on and C.white or C.txtMuted, zi+5, true)
        self:_addZone(ex,ey,ew,eH, function()
            el.value = not el.value; pcall(el.callback, el.value)
        end)

    -- ── Slider ──
    elseif el.type == "slider" then
        local sw=ew-24; local sx=ex+12; local sy_=ey+30; local sh=6
        local pct = (el.value-el.min)/(el.max-el.min)
        local fillW = math.floor(pct*sw)
        sq(p.."tr",  sx,     sy_, sw, sh, C.slider, zi+3)
        sq(p.."fl",  sx,     sy_, math.max(4,fillW), sh, C.acc, zi+4)
        circ(p.."kn",sx+fillW, sy_+sh/2, 6, C.accGlow, zi+5)
        sqo(p.."trd",sx, sy_, sw, sh, C.bord, zi+3)
        tx(p.."val", tostring(math.floor(el.value))..el.suffix, ex+ew-14, ey+8, 12, C.accGlow, zi+3)
        if el.dragging then
            if ismouse1pressed() then
                local rx  = math.clamp(mx-sx, 0, sw)
                el.value  = math.clamp(math.floor(el.min + (rx/sw)*(el.max-el.min)+0.5), el.min, el.max)
                pcall(el.callback, el.value)
            else
                el.dragging = false
            end
        end
        self:_addZone(sx, sy_-6, sw, sh+12, function() el.dragging=true end)

    -- ── Dropdown ──
    elseif el.type == "dropdown" then
        local dw=130; local dx=ex+ew-dw-10; local dy_=ey+10; local dh=22
        local ddOpen = self.DD ~= nil and self.DD.tag == p.."dd"
        sq(p.."dbg",  dx, dy_, dw, dh, C.dropBg, zi+3)
        sqo(p.."dbd", dx, dy_, dw, dh, ddOpen and C.acc or C.bord, zi+4)
        tx(p.."dtx",  tostring(el.value), dx+8, dy_+5, 12,
            ddOpen and C.accGlow or C.txtDim, zi+5)
        tx(p.."dar",  "v", dx+dw-12, dy_+5, 12, C.txtMuted, zi+5)

        self:_addZone(dx, dy_, dw, dh, function()
            if self.DD and self.DD.tag == p.."dd" then self.DD=nil; return end
            local iH  = 20; local ms = math.min(8, #el.options)
            local popH= ms*iH+4
            local popY= dy_+dh+1
            if popY+popH > self.WY+WH-4 then popY=dy_-popH-1 end
            local so=0
            for idx,v in ipairs(el.options) do
                if v==el.value then so=math.max(0,idx-math.floor(ms/2)); break end
            end
            self.DD = {
                x=dx, y=popY, w=dw, h=popH,
                items=el.options, cur=el.value,
                scrollOff=so, maxShow=ms, itemH=iH,
                tag=p.."dd", hovIdx=0,
                -- Use a unique per-dropdown frame prefix so pool keys don't collide
                frameKey = p.."dd_frame_",
                onSelect=function(c)
                    el.value=c
                    pcall(el.callback, {c})
                    self.DD=nil
                end
            }
        end)

    -- ── Textbox ──
    elseif el.type == "textbox" then
        local tw2=140; local tx2=ex+ew-tw2-10; local ty2=ey+10; local th2=24
        sq(p.."tbg",  tx2, ty2, tw2, th2, C.input, zi+3)
        sqo(p.."tbd", tx2, ty2, tw2, th2, el.active and C.acc or C.bord, zi+4)
        local disp = el.active and (el.value..(tick()%1>0.5 and "|" or ""))
                      or (el.value~="" and el.value or el.placeholder)
        tx(p.."ttx", disp, tx2+6, ty2+6, 12,
            el.active and C.txt or (el.value~="" and C.txt or C.txtMuted), zi+5)
        self:_addZone(tx2,ty2,tw2,th2, function()
            for _,t in ipairs(self.tabs) do
                for _,e in ipairs(t.elements) do
                    if e.type=="textbox" then e.active=false end
                end
            end
            el.active=true
        end)

    -- ── Keybind ──
    elseif el.type == "keybind" then
        local kbW=math.max(52, #el.vkName*8+16)
        local kbX=ex+ew-kbW-10; local kbY=ey+12; local kbH=20
        if el.listening then
            sq(p.."kbg",  kbX,kbY,kbW,kbH, C.redDk, zi+3)
            sqo(p.."kbd", kbX,kbY,kbW,kbH, C.red,   zi+4)
            tx(p.."ktx","...", kbX+kbW/2,kbY+4, 11, C.red, zi+5, true)
        else
            sq(p.."kbg",  kbX,kbY,kbW,kbH, C.accDark, zi+3)
            sqo(p.."kbd", kbX,kbY,kbW,kbH, C.acc,     zi+4)
            tx(p.."ktx", el.vkName, kbX+kbW/2,kbY+4, 11, C.accGlow, zi+5, true)
        end
        self:_addZone(kbX,kbY,kbW,kbH, function()
            for _,t in ipairs(self.tabs) do
                for _,e in ipairs(t.elements) do
                    if e.type=="keybind" then e.listening=false end
                end
            end
            el.listening=true
        end)
        if el.listening then
            if vkEdge(0x1B) then
                el.listening=false
            else
                for _,entry in ipairs(VK_SCAN) do
                    local vk2,nm2 = entry[1],entry[2]
                    if vkEdge(vk2) then
                        el.vk=vk2; el.vkName=nm2; el.listening=false
                        pcall(el.callback, nm2)
                        break
                    end
                end
            end
        end
    end
end

-- ─── Dropdown overlay ────────────────────────────────────────────────────────
-- Uses a stable per-frame key prefix so old items from prior frames
-- are hidden by the beginFrame/endFrame mechanism.
function MatchaUI:_renderDD(mx, my)
    if not self.DD then return end
    local d = self.DD
    local x,y,w,h = d.x, d.y, d.w, d.h
    local fk = d.frameKey  -- unique prefix for this dropdown's items

    local maxSc = math.max(0, #d.items - d.maxShow)
    d.scrollOff = math.clamp(d.scrollOff, 0, maxSc)
    local hasSb = maxSc > 0
    local sbW2  = 5
    local itemW = hasSb and (w-sbW2-1) or w

    sq("ddo_sh",  x+3, y+3, w, h, C.black,  28)
    sq("ddo_bg",  x,   y,   w, h, C.dropBg, 29)
    sqo("ddo_bd", x,   y,   w, h, C.acc,    30)
    sq("ddo_tl",  x,   y,   w, 2, C.acc,    31)

    if hasSb then
        local sbX2=x+w-sbW2; local sbY2=y+2; local sbH3=h-4
        local tH2=math.max(14, math.floor(sbH3*(d.maxShow/#d.items)))
        local tY2=sbY2+math.floor((sbH3-tH2)*(d.scrollOff/maxSc))
        sq("ddo_str",sbX2,sbY2,sbW2,sbH3, C.bord, 32)
        sq("ddo_sth",sbX2,tY2, sbW2,tH2,  C.acc,  33)
        self:_addDDZone(sbX2,tY2,sbW2,tH2, function()
            self.ddScrollDragging      = true
            self.ddScrollDragStartY    = my
            self.ddScrollDragStartOff  = d.scrollOff
        end)
    end

    local hovI = 0
    if hit(mx,my,x,y,itemW,h) then
        hovI = math.floor((my-y)/d.itemH)+1
        if hovI<1 or hovI>d.maxShow then hovI=0 end
    end
    d.hovIdx = hovI

    for i=1,d.maxShow do
        local idx = i + d.scrollOff
        if idx <= #d.items then
            local iy_   = y+(i-1)*d.itemH
            local isSel = d.items[idx]==d.cur
            local isHov = d.hovIdx==i
            -- KEY FIX: use fk (unique per dropdown instance) so items from
            -- different dropdowns never share pool keys and get correctly hidden
            local bk = fk.."b"..i
            local tk2= fk.."t"..i
            if isSel then
                sq(bk,  x+1, iy_, itemW-2, d.itemH-1, C.accDark, 31)
                ln(fk.."l"..i, x+1,iy_,x+1,iy_+d.itemH-2, C.acc, 2, 32)
            elseif isHov then
                sq(bk,  x+1, iy_, itemW-2, d.itemH-1, C.dropHov, 31)
            end
            tx(tk2, d.items[idx], x+10, iy_+3, 13,
                isSel and C.accGlow or (isHov and C.txt or C.txtDim), 32)
        end
    end
end

-- ─── Notifications ────────────────────────────────────────────────────────────
function MatchaUI:_renderNotifs()
    local now = tick()
    for i=#self.notifs,1,-1 do
        if now > self.notifs[i].expires then table.remove(self.notifs,i) end
    end
    local baseX = VP.X - NOTIF_W - 14
    local baseY = VP.Y - 14
    for i,n in ipairs(self.notifs) do
        local ny   = baseY - i*(NOTIF_H+8)
        local p    = n.id.."_"
        local age  = now - n.enterT
        local slide= math.min(1, age/0.25)
        local nx   = baseX + NOTIF_W*(1-slide)
        sq(p.."sh",  nx+3, ny+3, NOTIF_W, NOTIF_H, C.black,   44)
        sq(p.."bg",  nx,   ny,   NOTIF_W, NOTIF_H, C.notifBg, 45)
        sqo(p.."bd", nx,   ny,   NOTIF_W, NOTIF_H, C.acc,     46)
        sq(p.."tl",  nx,   ny,   4,       NOTIF_H, C.acc,     47)
        sq(p.."lt",  nx,   ny,   NOTIF_W, 1,       C.acc,     47)
        tx(p.."tt",  n.title,   nx+14, ny+10, 14, C.acc,    48)
        tx(p.."ct",  n.content, nx+14, ny+28, 12, C.txtDim, 48)
        local pct  = math.max(0,(n.expires-now)/n.duration)
        local barW = math.floor(pct*(NOTIF_W-8))
        sq(p.."tbr", nx+4, ny+NOTIF_H-4, NOTIF_W-8, 2, C.bord, 48)
        if barW>0 then sq(p.."tbl", nx+4, ny+NOTIF_H-4, barW, 2, C.acc, 49) end
    end
end

-- ─── Zone helpers ────────────────────────────────────────────────────────────
function MatchaUI:_addZone(x,y,w,h,fn)
    table.insert(self.zones,{x=x,y=y,w=w,h=h,fn=fn})
end
function MatchaUI:_addDDZone(x,y,w,h,fn)
    table.insert(self.ddZones,{x=x,y=y,w=w,h=h,fn=fn})
end

-- ─── Main Render ─────────────────────────────────────────────────────────────
function MatchaUI:_render(mx, my)
    beginFrame()
    table.clear(self.zones)
    table.clear(self.ddZones)

    self:_renderNotifs()

    if not self.Visible then endFrame(); return end

    local WX=self.WX; local WY=self.WY

    -- Window shell
    sq("w_sh",  WX+4, WY+4, WW,    WH,    C.black,  0)
    sq("w_bg",  WX,   WY,   WW,    WH,    C.bg,     1)
    sqo("w_bd", WX,   WY,   WW,    WH,    C.bord,   2)
    sq("w_el",  WX,   WY,   2,     WH,    C.acc,    3)
    sq("w_et",  WX,   WY,   WW,    1,     C.acc,    3)

    -- Topbar
    sq("tb_bg", WX, WY, WW, TOPBAR, C.sidebar, 2)
    sq("tb_ln", WX, WY+TOPBAR-1, WW, 1, C.acc, 3)
    tx("tb_nm", self.Name,     WX+16, WY+10, 15, C.txt,    4)
    tx("tb_sb", self.Subtitle, WX+16, WY+28, 11, C.txtDim, 4)
    tx("tb_hnt",self.ToggleKeyName.." toggle", WX+WW-90, WY+19, 11, C.txtMuted, 4)

    sq("tb_cx",  WX+WW-28, WY+12, 16, 16, C.redDk, 4)
    sqo("tb_cxd",WX+WW-28, WY+12, 16, 16, C.red,   5)
    tx("tb_cxt","X", WX+WW-20, WY+15, 11, C.red, 6, true)
    self:_addZone(WX+WW-28, WY+12, 16, 16, function() self.Visible=false end)
    self:_addZone(WX, WY, WW-34, TOPBAR, function()
        self.dragOn=true; self.dragOX=mx-WX; self.dragOY=my-WY
    end)

    -- Sidebar
    sq("sb_bg",  WX,           WY+TOPBAR, SIDEBAR, WH-TOPBAR, C.sidebar, 2)
    sq("sb_sep", WX+SIDEBAR-1, WY+TOPBAR, 1,       WH-TOPBAR, C.bord,   3)

    for i,tab in ipairs(self.tabs) do
        local ty_  = WY+TOPBAR + (i-1)*TAB_H
        local isA  = (i==self.activeTab)
        local p    = "stb"..i.."_"
        sq(p.."bg",  WX, ty_, SIDEBAR, TAB_H, isA and C.accDark or C.sidebar, 4)
        sq(p.."pip", WX, ty_, 3, TAB_H, isA and C.acc or C.bord, 5)
        sq(p.."bot", WX, ty_+TAB_H-1, SIDEBAR, 1, C.bord, 4)
        tx(p.."lb",  tab.name, WX+14, ty_+math.floor((TAB_H-13)/2), 13,
            isA and C.acc or C.txtDim, 5)
        local ci=i
        self:_addZone(WX,ty_,SIDEBAR,TAB_H, function()
            if self.activeTab~=ci then
                self.activeTab=ci
                self.DD=nil  -- close any open dropdown on tab switch
            end
        end)
    end

    -- Content area
    local cx=WX+SIDEBAR; local cy=WY+TOPBAR
    local cw=WW-SIDEBAR; local ch=WH-TOPBAR
    sq("ct_bg", cx, cy, cw, ch, C.bgPanel, 2)

    local tab = self.tabs[self.activeTab]
    if not tab then endFrame(); return end

    local totalH = CONTENT_PAD
    for _,el in ipairs(tab.elements) do
        totalH = totalH + elemH(el) + ELEM_GAP
    end

    local maxScroll = math.max(0, totalH - ch + CONTENT_PAD)
    tab.scroll = math.clamp(tab.scroll or 0, 0, maxScroll)

    if maxScroll > 0 then
        local sbX=cx+cw-5; local sbY=cy+2; local sbH2=ch-4
        sq("ctsb_t",sbX,sbY,4,sbH2, C.bord, 5)
        local tH=math.max(20, math.floor(sbH2*(ch/totalH)))
        local tY=sbY + math.floor((sbH2-tH)*(tab.scroll/maxScroll))
        sq("ctsb_h",sbX,tY,4,tH, C.acc, 6)
    end

    local elemW = cw - CONTENT_PAD*2 - (maxScroll>0 and 8 or 0)
    local ey0   = cy + CONTENT_PAD - tab.scroll

    for _,el in ipairs(tab.elements) do
        local eH_ = elemH(el)
        if ey0+eH_ >= cy and ey0 <= cy+ch then
            self:_renderElement(el, cx+CONTENT_PAD, ey0, elemW, mx, my, 5)
        end
        ey0 = ey0 + eH_ + ELEM_GAP
    end

    -- Dropdown overlay rendered last so it's always on top
    self:_renderDD(mx, my)

    endFrame()
end

-- ─── Main Loop ───────────────────────────────────────────────────────────────
function MatchaUI:_startLoop()
    local prevM1    = false
    local lastScroll= 0

    task.spawn(function()
        while not self._destroyed do
            task.wait()

            VP = workspace.CurrentCamera.ViewportSize
            local mx = mouse.X
            local my = mouse.Y
            local m1 = ismouse1pressed()
            local justClicked = m1 and not prevM1
            prevM1 = m1

            -- Toggle
            if vkEdge(self.ToggleKey) then
                self.Visible = not self.Visible
                if not self.Visible then self.DD=nil end
            end

            -- Drag
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

            -- Dropdown scrollbar drag
            if self.ddScrollDragging then
                if m1 and self.DD then
                    local d = self.DD
                    local maxDD = math.max(0, #d.items-d.maxShow)
                    local sbH_  = d.h-4
                    local tH_   = math.max(14, math.floor(sbH_*(d.maxShow/#d.items)))
                    local trk   = sbH_-tH_
                    if trk>0 then
                        local ratio = (my-self.ddScrollDragStartY)/trk
                        d.scrollOff = math.clamp(
                            math.floor(self.ddScrollDragStartOff + ratio*maxDD+0.5),
                            0, maxDD)
                    end
                else
                    self.ddScrollDragging=false
                end
            end

            -- Content scroll (arrow keys / W-S)
            if self.Visible and not self.DD then
                local now2 = tick()
                if now2-lastScroll > 0.08 then
                    local tab = self.tabs[self.activeTab]
                    if tab then
                        if iskeypressed(0x26) or iskeypressed(0x57) then
                            tab.scroll = math.max(0,(tab.scroll or 0)-14); lastScroll=now2
                        elseif iskeypressed(0x28) or iskeypressed(0x53) then
                            tab.scroll = (tab.scroll or 0)+14; lastScroll=now2
                        end
                    end
                end
            end

            -- Click
            if justClicked and self.Visible then
                if self.DD then
                    local d = self.DD
                    if hit(mx,my,d.x,d.y,d.w,d.h) then
                        local hitDDZ=false
                        for _,z in ipairs(self.ddZones) do
                            if hit(mx,my,z.x,z.y,z.w,z.h) then z.fn(); hitDDZ=true; break end
                        end
                        if not hitDDZ then
                            local hasSb= math.max(0,#d.items-d.maxShow)>0
                            local itemW= hasSb and (d.w-6) or d.w
                            if hit(mx,my,d.x,d.y,itemW,d.h) then
                                local idx = math.floor((my-d.y)/d.itemH)+1+d.scrollOff
                                if idx>=1 and idx<=#d.items then
                                    d.onSelect(d.items[idx])
                                end
                            end
                        end
                    else
                        self.DD=nil
                    end
                else
                    -- deactivate textboxes
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
                d.Text     = "[MatchaUI] "..tostring(err)
                d.Position = Vector2.new(10,50)
                d.Size=12; d.Color=Color3.fromRGB(255,80,80)
                d.Font=Drawing.Fonts.UI; d.Outline=false
                d.Center=false; d.ZIndex=99; d.Visible=true
            end
        end
    end)
end

return MatchaUI
