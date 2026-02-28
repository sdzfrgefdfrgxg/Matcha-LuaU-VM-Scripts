MatchaUI = {}
MatchaUI.__index = MatchaUI

-- ────────────────────────────────────────────────────────────────
--  Rayfield Colour Palette  (sampled from official screenshots)
-- ────────────────────────────────────────────────────────────────
local RF_BG        = Color3.fromRGB(25,  25,  35)   -- main window bg
local RF_TOPBAR    = Color3.fromRGB(30,  30,  45)   -- topbar
local RF_SIDEBAR   = Color3.fromRGB(20,  20,  30)   -- left tab strip
local RF_CARD      = Color3.fromRGB(33,  33,  50)   -- element card
local RF_CARD_HOV  = Color3.fromRGB(40,  40,  60)   -- element card hovered
local RF_CARD_ACT  = Color3.fromRGB(28,  28,  44)   -- pressed/active card
local RF_BORDER    = Color3.fromRGB(50,  50,  72)   -- subtle border
local RF_BORDER2   = Color3.fromRGB(65,  65,  95)   -- brighter border (accent cards)

-- Rayfield uses a blue→purple gradient accent. We pick the mid-point.
local RF_ACC       = Color3.fromRGB(95,  145, 255)  -- primary accent (blue-purple)
local RF_ACC2      = Color3.fromRGB(130, 90,  255)  -- secondary accent (purple)
local RF_ACC_DIM   = Color3.fromRGB(55,  80,  160)  -- dimmed accent (inactive)
local RF_ACC_DARK  = Color3.fromRGB(28,  34,  75)   -- accent dark bg (highlight)
local RF_ACC_GLOW  = Color3.fromRGB(180, 200, 255)  -- bright accent text/glow

local RF_TXT       = Color3.fromRGB(235, 235, 255)  -- primary text
local RF_TXT_DIM   = Color3.fromRGB(145, 148, 180)  -- secondary text
local RF_TXT_MUTE  = Color3.fromRGB(80,  82,  115)  -- muted text

local RF_TOG_ON    = Color3.fromRGB(95,  145, 255)  -- toggle on colour
local RF_TOG_OFF   = Color3.fromRGB(50,  52,  75)   -- toggle off colour
local RF_KNOB      = Color3.fromRGB(230, 232, 255)  -- toggle knob
local RF_KNOB_OFF  = Color3.fromRGB(110, 112, 145)  -- toggle knob off

local RF_SLIDER_TR = Color3.fromRGB(42,  42,  62)   -- slider track
local RF_SLIDER_FL = Color3.fromRGB(95,  145, 255)  -- slider fill
local RF_SLIDER_KN = Color3.fromRGB(210, 220, 255)  -- slider knob

local RF_INPUT     = Color3.fromRGB(20,  20,  32)   -- textbox bg
local RF_DROP_BG   = Color3.fromRGB(18,  18,  28)   -- dropdown popup bg
local RF_DROP_HOV  = Color3.fromRGB(38,  45,  85)   -- dropdown item hover
local RF_DROP_SEL  = Color3.fromRGB(28,  34,  75)   -- dropdown item selected

local RF_RED       = Color3.fromRGB(240, 70,  90)
local RF_RED_DK    = Color3.fromRGB(90,  20,  28)
local RF_BLACK     = Color3.fromRGB(0,   0,   0)
local RF_WHITE     = Color3.fromRGB(255, 255, 255)

local RF_NOTIF_BG  = Color3.fromRGB(28,  28,  44)
local RF_NOTIF_BD  = Color3.fromRGB(95,  145, 255)

-- tab accent pip / active bg
local RF_TAB_ACT_BG  = Color3.fromRGB(35,  42,  80)
local RF_TAB_ACT_PIP = Color3.fromRGB(95,  145, 255)
local RF_TAB_INACT   = Color3.fromRGB(20,  20,  30)

-- ────────────────────────────────────────────────────────────────
--  Drawing pool
-- ────────────────────────────────────────────────────────────────
local pool = {}

local function D(id, dtype)
    if not pool[id] then
        pool[id] = Drawing.new(dtype)
        pool[id].Visible = false
    end
    return pool[id]
end

-- Filled square
local function R(id, x, y, w, h, col, zi)
    local d = D(id, "Square")
    d.Position  = Vector2.new(x, y)
    d.Size      = Vector2.new(w, h)
    d.Color     = col
    d.Filled    = true
    d.Thickness = 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

-- Outline square
local function RO(id, x, y, w, h, col, zi, thick)
    local d = D(id, "Square")
    d.Position  = Vector2.new(x, y)
    d.Size      = Vector2.new(w, h)
    d.Color     = col
    d.Filled    = false
    d.Thickness = thick or 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

-- Text
local function TX(id, text, x, y, sz, col, zi, center)
    local d = D(id, "Text")
    d.Text     = tostring(text)
    d.Position = Vector2.new(x, y)
    d.Size     = sz or 13
    d.Color    = col or RF_TXT
    d.Font     = Drawing.Fonts.UI
    d.Outline  = false
    d.Center   = (center == true)
    d.ZIndex   = zi or 2
    d.Visible  = true
end

-- Line
local function LN(id, x1, y1, x2, y2, col, zi, thick)
    local d = D(id, "Line")
    d.From      = Vector2.new(x1, y1)
    d.To        = Vector2.new(x2, y2)
    d.Color     = col
    d.Thickness = thick or 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

-- Circle
local function CL(id, cx, cy, r, col, zi)
    local d = D(id, "Circle")
    d.Position  = Vector2.new(cx, cy)
    d.Radius    = r
    d.Color     = col
    d.Filled    = true
    d.NumSides  = 24
    d.Thickness = 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

local function HID(id)
    if pool[id] then pool[id].Visible = false end
end

local function HIDPFX(pfx)
    for k, d in pairs(pool) do
        if k:sub(1, #pfx) == pfx then d.Visible = false end
    end
end

-- ────────────────────────────────────────────────────────────────
--  Helpers
-- ────────────────────────────────────────────────────────────────
local _uid = 0
local function uid()
    _uid = _uid + 1
    return "q" .. _uid .. "_"
end

local function inside(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

-- Fake "gradient" horizontal bar by blending two colours in segments
local function GRAD_H(id, x, y, w, h, c1, c2, zi, segs)
    segs = segs or 20
    local sw = math.max(1, math.floor(w / segs))
    for i = 0, segs - 1 do
        local t  = i / (segs - 1)
        local r2 = c1.R + (c2.R - c1.R) * t
        local g2 = c1.G + (c2.G - c1.G) * t
        local b2 = c1.B + (c2.B - c1.B) * t
        R(id .. "g" .. i, x + i * sw, y, sw + 1, h, Color3.new(r2, g2, b2), zi)
    end
end

-- ────────────────────────────────────────────────────────────────
--  VK / Key tables
-- ────────────────────────────────────────────────────────────────
local VKS = {
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
    {0x2D,"Ins"},{0x2E,"Del"},{0x24,"Home"},{0x23,"End"},
    {0x21,"PgUp"},{0x22,"PgDn"},
    {0x26,"Up"},{0x28,"Down"},{0x25,"Left"},{0x27,"Right"},
    {0x20,"Space"},{0x10,"Shift"},{0x11,"Ctrl"},
}

local KEY_STR = {
    f1=0x70,f2=0x71,f3=0x72,f4=0x73,f5=0x74,
    f6=0x75,f7=0x76,f8=0x77,f9=0x78,f10=0x79,
    f11=0x7A,f12=0x7B,
    home=0x24,["end"]=0x23,ins=0x2D,del=0x2E,
    pgup=0x21,pgdn=0x22,
    up=0x26,down=0x28,left=0x25,right=0x27,
    space=0x20,shift=0x10,ctrl=0x11,
}
for _, pair in ipairs(VKS) do
    KEY_STR[pair[2]:lower()] = pair[1]
end

local function vkToName(vk)
    for _, pair in ipairs(VKS) do
        if pair[1] == vk then return pair[2] end
    end
    return string.format("0x%X", vk)
end

local CHARMAP = {}
for vk = 0x41, 0x5A do CHARMAP[vk] = string.char(vk + 32) end
for vk = 0x30, 0x39 do CHARMAP[vk] = string.char(vk) end
CHARMAP[0x20] = " "
CHARMAP[0xBD] = "-"
CHARMAP[0xBE] = "."
CHARMAP[0xBF] = "/"

-- ────────────────────────────────────────────────────────────────
--  Layout  (matching Rayfield proportions from screenshots)
-- ────────────────────────────────────────────────────────────────
local WW       = 580     -- window width
local WH       = 460     -- window height
local SIDE_W   = 140     -- sidebar (tab list) width
local TOP_H    = 55      -- topbar height
local PAD      = 12      -- content padding
local TAB_H    = 38      -- height per tab entry
local ELEM_H   = 46      -- default element card height
local ELEM_G   = 6       -- gap between elements
local SEC_H    = 28      -- section header height
local NW       = 300     -- notification width
local NH       = 64      -- notification height

-- ────────────────────────────────────────────────────────────────
--  Init
-- ────────────────────────────────────────────────────────────────
function MatchaUI:Init(cfg)
    cfg = cfg or {}
    self._title   = cfg.Title    or "Script"
    self._sub     = cfg.Subtitle or "by author"
    local tk      = cfg.ToggleKey or "f2"
    self._tkvk    = KEY_STR[tk:lower()] or 0x71
    self._tkvname = tk:upper()

    local vp      = workspace.CurrentCamera.ViewportSize
    self._wx      = math.floor((vp.X - WW) / 2)
    self._wy      = math.floor((vp.Y - WH) / 2)

    self._visible  = true
    self._tabs     = {}
    self._curtab   = 1
    self._drag     = false
    self._dox      = 0
    self._doy      = 0
    self._pm1      = false
    self._prevvk   = {}
    self._dd       = nil
    self._tbactive = nil
    self._kblisten = nil
    self._notifs   = {}
    self._scroll   = {}
    self._zones    = {}
    return self
end

-- ────────────────────────────────────────────────────────────────
--  Tab / Section builder
-- ────────────────────────────────────────────────────────────────
function MatchaUI:Tab(name)
    local tab = {name = name, sections = {}}
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self._curtab = 1 end

    function tab:Section(sname)
        local sec = {name = sname, elements = {}}
        table.insert(self.sections, sec)

        function sec:Button(ename, cb)
            table.insert(self.elements, {
                t="btn", name=ename, id=uid(), cb=cb or function() end
            })
        end

        function sec:Toggle(ename, default, cb)
            local el = {
                t="tog", name=ename, id=uid(),
                val=(default == true), cb=cb or function() end
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val = (v == true); pcall(el.cb, el.val) end
            return obj
        end

        function sec:Slider(ename, default, step, mn, mx2, suffix, cb)
            local el = {
                t="sld", name=ename, id=uid(),
                val=default or 0, step=step or 1,
                min=mn or 0, max=mx2 or 100,
                suffix=suffix or "", cb=cb or function() end,
                dragging=false
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v)
                el.val = math.clamp(v, el.min, el.max)
                pcall(el.cb, el.val)
            end
            return obj
        end

        function sec:Dropdown(ename, default, options, multi, cb)
            local el = {
                t="dd", name=ename, id=uid(),
                val=default or {}, opts=options or {},
                multi=(multi == true), cb=cb or function() end
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val = v; pcall(el.cb, el.val) end
            function obj:Refresh(opts, def)
                el.opts = opts or {}
                el.val  = def  or {}
            end
            return obj
        end

        function sec:Textbox(ename, default, cb)
            local el = {
                t="tbx", name=ename, id=uid(),
                val=default or "", cb=cb or function() end,
                active=false
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val = v end
            return obj
        end

        function sec:Keybind(ename, defaultKey, cb)
            local vk    = 0x71
            local vname = "F2"
            if type(defaultKey) == "string" then
                vk    = KEY_STR[defaultKey:lower()] or 0x71
                vname = defaultKey:upper()
            elseif type(defaultKey) == "number" then
                vk    = defaultKey
                vname = vkToName(vk)
            end
            local el = {
                t="kb", name=ename, id=uid(),
                vk=vk, vname=vname,
                cb=cb or function() end,
                listening=false
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v, n)
                el.vk    = v
                el.vname = n or vkToName(v)
            end
            return obj
        end

        function sec:Label(text)
            table.insert(self.elements, {t="lbl", text=text, id=uid()})
        end

        function sec:Divider()
            table.insert(self.elements, {t="div", id=uid()})
        end

        return sec
    end

    return tab
end

-- ────────────────────────────────────────────────────────────────
--  Notify
-- ────────────────────────────────────────────────────────────────
function MatchaUI:Notify(text, duration)
    duration = duration or 3
    table.insert(self._notifs, {
        text    = tostring(text),
        dur     = duration,
        born    = tick(),
        expires = tick() + duration,
        id      = uid()
    })
end

-- ────────────────────────────────────────────────────────────────
--  Unload
-- ────────────────────────────────────────────────────────────────
function MatchaUI:Unload()
    self._dead = true
    for _, d in pairs(pool) do
        pcall(function() d.Visible = false end)
    end
end

-- ────────────────────────────────────────────────────────────────
--  Element height
-- ────────────────────────────────────────────────────────────────
local function EH(el)
    if el.t == "lbl" then return 24 end
    if el.t == "div" then return 14 end
    if el.t == "sld" then return 56 end
    return ELEM_H
end

-- ────────────────────────────────────────────────────────────────
--  Zone registration
-- ────────────────────────────────────────────────────────────────
function MatchaUI:_zone(x, y, w, h, fn)
    table.insert(self._zones, {x=x, y=y, w=w, h=h, fn=fn})
end

-- ────────────────────────────────────────────────────────────────
--  VK edge detection
-- ────────────────────────────────────────────────────────────────
function MatchaUI:_edge(vk)
    local now  = iskeypressed(vk)
    local prev = self._prevvk[vk] or false
    self._prevvk[vk] = now
    return now and not prev
end

-- ────────────────────────────────────────────────────────────────
--  Draw single element  (Rayfield look)
-- ────────────────────────────────────────────────────────────────
function MatchaUI:_drawElem(el, ex, ey, ew, mx, my, zi)
    local p  = el.id
    local eh = EH(el)

    -- ── Label ──────────────────────────────────────────────────
    if el.t == "lbl" then
        TX(p.."tx", el.text, ex + 6, ey + 5, 12, RF_TXT_DIM, zi)
        return
    end

    -- ── Divider ────────────────────────────────────────────────
    if el.t == "div" then
        LN(p.."ln", ex, ey + 7, ex + ew, ey + 7, RF_BORDER, zi)
        return
    end

    -- Card background
    local hov = inside(mx, my, ex, ey, ew, eh)
    local bgc = RF_CARD
    if hov then bgc = RF_CARD_HOV end
    R(p.."bg",  ex,   ey,   ew, eh, bgc,       zi)
    RO(p.."bd", ex,   ey,   ew, eh, RF_BORDER2, zi + 1)

    -- Rayfield left-side gradient accent bar (3px wide, full element height)
    GRAD_H(p.."acc", ex, ey, 3, eh, RF_ACC, RF_ACC2, zi + 2, 6)

    -- ── Button ─────────────────────────────────────────────────
    if el.t == "btn" then
        TX(p.."nm", el.name, ex + 14, ey + math.floor((eh - 13) / 2), 13, RF_TXT, zi + 2)
        -- Rayfield-style right-aligned pill button
        local bw = 76
        local bh = 26
        local bx = ex + ew - bw - 10
        local by = ey + math.floor((eh - bh) / 2)
        GRAD_H(p.."bbg", bx, by, bw, bh, RF_ACC, RF_ACC2, zi + 3, 12)
        RO(p.."bbd", bx, by, bw, bh, RF_ACC_GLOW, zi + 4)
        TX(p.."btx", "Execute", bx + bw / 2, by + 6, 11, RF_WHITE, zi + 5, true)
        self:_zone(ex, ey, ew, eh, function() pcall(el.cb) end)

    -- ── Toggle ─────────────────────────────────────────────────
    elseif el.t == "tog" then
        TX(p.."nm", el.name, ex + 14, ey + math.floor((eh - 13) / 2), 13, RF_TXT, zi + 2)

        local pw  = 40
        local ph  = 20
        local px  = ex + ew - pw - 10
        local py  = ey + math.floor((eh - ph) / 2)
        local on  = el.val

        local tbgc = RF_TOG_OFF
        local knxv = px + 2
        local kncc = RF_KNOB_OFF
        if on then
            tbgc = RF_TOG_ON
            knxv = px + pw - ph + 2
            kncc = RF_KNOB
        end

        R(p.."tbg",  px,  py,  pw, ph, tbgc, zi + 3)
        RO(p.."tbd", px,  py,  pw, ph, RF_BORDER2, zi + 4)
        -- knob is a filled square (we can't do true circles in the pill, squares look fine)
        local ksize = ph - 4
        R(p.."knb",  knxv, py + 2, ksize, ksize, kncc, zi + 5)

        self:_zone(ex, ey, ew, eh, function()
            el.val = not el.val
            pcall(el.cb, el.val)
        end)

    -- ── Slider ─────────────────────────────────────────────────
    elseif el.t == "sld" then
        TX(p.."nm", el.name, ex + 14, ey + 8, 13, RF_TXT, zi + 2)

        local sw  = ew - 28
        local sx  = ex + 14
        local sy  = ey + 32
        local sh  = 5
        local rng = math.max(1, el.max - el.min)
        local pct = (el.val - el.min) / rng
        local fw  = math.max(sh, math.floor(pct * sw))

        -- track
        R(p.."tr",  sx,      sy, sw, sh, RF_SLIDER_TR, zi + 3)
        -- fill (gradient)
        GRAD_H(p.."fl", sx, sy, fw, sh, RF_ACC, RF_ACC2, zi + 4, 10)
        -- knob circle
        CL(p.."kn", sx + fw, sy + math.floor(sh / 2), 7, RF_SLIDER_KN, zi + 5)
        RO(p.."trd", sx, sy, sw, sh, RF_BORDER, zi + 3)

        local valStr = tostring(math.floor(el.val)) .. el.suffix
        TX(p.."vl", valStr, ex + ew - 10, ey + 8, 12, RF_ACC_GLOW, zi + 3)

        if el.dragging then
            if ismouse1pressed() then
                local rx  = math.clamp(mx - sx, 0, sw)
                local raw = el.min + (rx / sw) * rng
                local snp = math.floor(raw / el.step + 0.5) * el.step
                el.val = math.clamp(snp, el.min, el.max)
                pcall(el.cb, el.val)
            else
                el.dragging = false
            end
        end
        self:_zone(sx, sy - 8, sw, sh + 16, function() el.dragging = true end)

    -- ── Dropdown ───────────────────────────────────────────────
    elseif el.t == "dd" then
        TX(p.."nm", el.name, ex + 14, ey + math.floor((eh - 13) / 2), 13, RF_TXT, zi + 2)

        local dw  = 148
        local dh  = 26
        local dx  = ex + ew - dw - 10
        local dy  = ey + math.floor((eh - dh) / 2)
        local isO = (self._dd ~= nil and self._dd.eid == el.id)

        local disp = "None"
        if type(el.val) == "table" then
            if #el.val == 1 then
                disp = el.val[1]
            elseif #el.val > 1 then
                disp = el.val[1] .. " (+" .. (#el.val - 1) .. ")"
            end
        elseif type(el.val) == "string" and el.val ~= "" then
            disp = el.val
        end

        local dbd = RF_BORDER2
        local dtc = RF_TXT_DIM
        if isO then dbd = RF_ACC; dtc = RF_ACC_GLOW end

        R(p.."dbg",  dx, dy, dw, dh, RF_INPUT,  zi + 3)
        RO(p.."dbd", dx, dy, dw, dh, dbd,        zi + 4)
        TX(p.."dtx", disp, dx + 8, dy + 6, 12, dtc, zi + 5)
        TX(p.."dar", "v",  dx + dw - 14, dy + 6, 12, RF_TXT_MUTE, zi + 5)

        local eref = el
        local uiref = self
        self:_zone(dx, dy, dw, dh, function()
            if isO then uiref._dd = nil; return end
            local ms   = math.min(8, #eref.opts)
            local popH = ms * 22 + 6
            local iy   = dy + dh + 2
            local vp2  = workspace.CurrentCamera.ViewportSize
            if iy + popH > uiref._wy + WH - 6 then iy = dy - popH - 2 end
            uiref._dd = {
                eid    = eref.id,
                x      = dx,
                y      = iy,
                w      = dw,
                h      = popH,
                opts   = eref.opts,
                sel    = eref.val,
                ms     = ms,
                iH     = 22,
                sc     = 0,
                multi  = eref.multi,
                onpick = function(v)
                    if eref.multi then
                        local s = eref.val
                        if type(s) ~= "table" then s = {} end
                        local found = false
                        for i2, sv in ipairs(s) do
                            if sv == v then table.remove(s, i2); found = true; break end
                        end
                        if not found then table.insert(s, v) end
                        eref.val = s
                        pcall(eref.cb, eref.val)
                    else
                        eref.val = {v}
                        pcall(eref.cb, eref.val)
                        uiref._dd = nil
                    end
                end
            }
        end)

    -- ── Textbox ────────────────────────────────────────────────
    elseif el.t == "tbx" then
        TX(p.."nm", el.name, ex + 14, ey + math.floor((eh - 13) / 2), 13, RF_TXT, zi + 2)

        local tw  = 148
        local th  = 26
        local tx2 = ex + ew - tw - 10
        local ty2 = ey + math.floor((eh - th) / 2)

        local active = (self._tbactive == el)
        local disp2  = el.val
        if active then
            local blink = (math.floor(tick() * 2) % 2 == 0)
            if blink then disp2 = el.val .. "|" end
        end

        local tbd = RF_BORDER2
        local ttc = RF_TXT_DIM
        if active then tbd = RF_ACC; ttc = RF_TXT end

        R(p.."tbg",  tx2, ty2, tw, th, RF_INPUT, zi + 3)
        RO(p.."tbd", tx2, ty2, tw, th, tbd,      zi + 4)
        TX(p.."ttx", disp2, tx2 + 7, ty2 + 6, 12, ttc, zi + 5)

        local eref2 = el
        self:_zone(tx2, ty2, tw, th, function() self._tbactive = eref2 end)

    -- ── Keybind ────────────────────────────────────────────────
    elseif el.t == "kb" then
        TX(p.."nm", el.name, ex + 14, ey + math.floor((eh - 13) / 2), 13, RF_TXT, zi + 2)

        local kw  = math.max(54, #el.vname * 8 + 16)
        local kh  = 24
        local kx  = ex + ew - kw - 10
        local ky  = ey + math.floor((eh - kh) / 2)

        if el.listening then
            R(p.."kbg",  kx, ky, kw, kh, RF_RED_DK, zi + 3)
            RO(p.."kbd", kx, ky, kw, kh, RF_RED,    zi + 4)
            TX(p.."ktx", "...", kx + kw / 2, ky + 5, 11, RF_RED, zi + 5, true)
            if self:_edge(0x1B) then
                el.listening   = false
                self._kblisten = nil
            else
                for _, pair in ipairs(VKS) do
                    if self:_edge(pair[1]) then
                        el.vk        = pair[1]
                        el.vname     = pair[2]
                        el.listening = false
                        self._kblisten = nil
                        pcall(el.cb, el.vk, el.vname)
                        break
                    end
                end
            end
        else
            R(p.."kbg",  kx, ky, kw, kh, RF_ACC_DARK,  zi + 3)
            RO(p.."kbd", kx, ky, kw, kh, RF_ACC,        zi + 4)
            TX(p.."ktx", el.vname, kx + kw / 2, ky + 5, 11, RF_ACC_GLOW, zi + 5, true)

            local eref3 = el
            local uiref3 = self
            self:_zone(kx, ky, kw, kh, function()
                if uiref3._kblisten then uiref3._kblisten.listening = false end
                eref3.listening  = true
                uiref3._kblisten = eref3
            end)
        end
    end
end

-- ────────────────────────────────────────────────────────────────
--  Draw dropdown overlay
-- ────────────────────────────────────────────────────────────────
function MatchaUI:_drawDD(mx, my)
    local dd = self._dd
    if not dd then
        HIDPFX("_dd_")
        return
    end

    R("_dd_sh",  dd.x + 4, dd.y + 4, dd.w, dd.h, RF_BLACK,   28)
    R("_dd_bg",  dd.x,     dd.y,     dd.w, dd.h, RF_DROP_BG, 29)
    RO("_dd_bd", dd.x,     dd.y,     dd.w, dd.h, RF_ACC,     30, 1)
    -- accent top line (Rayfield style)
    GRAD_H("_dd_tl", dd.x, dd.y, dd.w, 2, RF_ACC, RF_ACC2, 31, 14)

    for i = 1, dd.ms do
        local idx = i + dd.sc
        if idx <= #dd.opts then
            local iy  = dd.y + (i - 1) * dd.iH + 3
            local val = dd.opts[idx]
            local sel = false
            if type(dd.sel) == "table" then
                for _, sv in ipairs(dd.sel) do
                    if sv == val then sel = true; break end
                end
            else
                sel = (dd.sel == val)
            end
            local hov = inside(mx, my, dd.x + 1, iy, dd.w - 2, dd.iH)

            if sel then
                R("_ddi_b" .. i,  dd.x + 1, iy, dd.w - 2, dd.iH - 1, RF_DROP_SEL, 31)
                -- left accent pip for selected
                GRAD_H("_ddi_p" .. i, dd.x + 1, iy, 3, dd.iH - 1, RF_ACC, RF_ACC2, 32, 4)
            elseif hov then
                R("_ddi_b" .. i, dd.x + 1, iy, dd.w - 2, dd.iH - 1, RF_DROP_HOV, 31)
                HID("_ddi_p" .. i)
            else
                HID("_ddi_b" .. i)
                HID("_ddi_p" .. i)
            end

            local itc = RF_TXT_DIM
            if sel then itc = RF_ACC_GLOW elseif hov then itc = RF_TXT end
            TX("_ddi_t" .. i, val, dd.x + 10, iy + 4, 13, itc, 32)
        end
    end
end

-- ────────────────────────────────────────────────────────────────
--  Draw notifications  (Rayfield style: bottom-right slide-in)
-- ────────────────────────────────────────────────────────────────
function MatchaUI:_drawNotifs()
    local now = tick()
    for i = #self._notifs, 1, -1 do
        if now >= self._notifs[i].expires then
            HIDPFX(self._notifs[i].id)
            table.remove(self._notifs, i)
        end
    end

    local vp  = workspace.CurrentCamera.ViewportSize
    local bx  = vp.X - NW - 16
    local by  = vp.Y - 16

    for i, n in ipairs(self._notifs) do
        local ny  = by - i * (NH + 10)
        local age = now - n.born
        local sl  = math.min(1, age / 0.22)
        local nx  = bx + NW * (1 - sl)
        local p   = n.id

        -- shadow
        R(p.."sh",   nx + 4,  ny + 4, NW,   NH,   RF_BLACK,    44)
        -- body
        R(p.."bg",   nx,      ny,     NW,   NH,   RF_NOTIF_BG, 45)
        RO(p.."bd",  nx,      ny,     NW,   NH,   RF_BORDER2,  46)
        -- top gradient bar (Rayfield signature)
        GRAD_H(p.."tbar", nx, ny, NW, 3, RF_ACC, RF_ACC2, 47, 15)
        -- left accent bar
        GRAD_H(p.."lbar", nx, ny, 3, NH, RF_ACC, RF_ACC2, 47, 6)
        -- text
        TX(p.."tx", n.text, nx + 14, ny + math.floor((NH - 13) / 2), 13, RF_TXT, 48)
        -- progress bar
        local pct = math.max(0, (n.expires - now) / n.dur)
        local bw  = math.floor(pct * (NW - 8))
        R(p.."pt",  nx + 4,  ny + NH - 5, NW - 8, 3, RF_BORDER, 48)
        if bw > 0 then
            GRAD_H(p.."pf", nx + 4, ny + NH - 5, bw, 3, RF_ACC, RF_ACC2, 49, 10)
        end
    end
end

-- ────────────────────────────────────────────────────────────────
--  Main render
-- ────────────────────────────────────────────────────────────────
function MatchaUI:_render(mx, my)
    self:_drawNotifs()

    if not self._visible then
        HIDPFX("_w_")
        HIDPFX("_tb_")
        HIDPFX("_sb_")
        HIDPFX("_si")
        HIDPFX("_ct")
        HIDPFX("_sh_")
        HIDPFX("_sl_")
        HIDPFX("_dd_")
        return
    end

    local wx = self._wx
    local wy = self._wy

    -- ── Window drop-shadow ──────────────────────────────────────
    R("_w_sh",  wx + 6, wy + 6, WW,    WH,    RF_BLACK,  0)

    -- ── Window body ────────────────────────────────────────────
    R("_w_bg",  wx,     wy,     WW,    WH,    RF_BG,     1)
    RO("_w_bd", wx,     wy,     WW,    WH,    RF_BORDER, 2)

    -- ── Top gradient accent line (Rayfield signature 3px bar) ──
    GRAD_H("_w_tl", wx, wy, WW, 3, RF_ACC, RF_ACC2, 3, 20)

    -- ── Topbar ─────────────────────────────────────────────────
    R("_tb_bg",  wx,  wy,         WW,  TOP_H, RF_TOPBAR, 2)
    LN("_tb_sp", wx,  wy+TOP_H-1, wx+WW, wy+TOP_H-1, RF_BORDER, 3)

    -- Title + subtitle
    TX("_tb_nm", self._title,  wx + 18, wy + 10, 16, RF_TXT,     4)
    TX("_tb_sb", self._sub,    wx + 18, wy + 30, 11, RF_TXT_DIM, 4)

    -- Toggle hint (right side, small)
    local hkStr = "[" .. self._tkvname .. "] toggle"
    TX("_tb_hk", hkStr, wx + WW - 90, wy + 22, 10, RF_TXT_MUTE, 4)

    -- Close X button
    local cxX = wx + WW - 28
    local cxY = wy + 16
    R("_tb_cx",  cxX, cxY, 16, 16, RF_RED_DK, 4)
    RO("_tb_cxd",cxX, cxY, 16, 16, RF_RED,    5)
    TX("_tb_cxt","X", cxX + 8,  cxY + 2, 11, RF_RED, 6, true)
    self:_zone(cxX, cxY, 16, 16, function() self._visible = false end)

    -- Drag zone (topbar minus close button)
    self:_zone(wx, wy, WW - 36, TOP_H, function()
        self._drag = true
        self._dox  = mx - wx
        self._doy  = my - wy
    end)

    -- ── Sidebar ────────────────────────────────────────────────
    R("_sb_bg",  wx,           wy + TOP_H, SIDE_W, WH - TOP_H, RF_SIDEBAR, 2)
    LN("_sb_sp", wx + SIDE_W - 1, wy + TOP_H, wx + SIDE_W - 1, wy + WH, RF_BORDER, 3)

    for i, tab in ipairs(self._tabs) do
        local ty  = wy + TOP_H + (i - 1) * TAB_H + 8
        local isA = (i == self._curtab)
        local p   = "_si" .. i .. "_"

        local sbgc  = RF_TAB_INACT
        local spipc = RF_BORDER
        local stc   = RF_TXT_DIM
        if isA then
            sbgc  = RF_TAB_ACT_BG
            spipc = RF_TAB_ACT_PIP
            stc   = RF_ACC_GLOW
        end

        R(p.."bg", wx + 6, ty, SIDE_W - 12, TAB_H, sbgc, 4)
        RO(p.."bd",wx + 6, ty, SIDE_W - 12, TAB_H, isA and RF_ACC or RF_BORDER, 4)

        -- left pip for active tab
        if isA then
            GRAD_H(p.."pip", wx + 6, ty, 3, TAB_H, RF_ACC, RF_ACC2, 5, 4)
        else
            HIDPFX(p.."pip")
        end

        TX(p.."lb", tab.name, wx + 20, ty + math.floor((TAB_H - 13) / 2), 13, stc, 5)

        local ci = i
        self:_zone(wx + 6, ty, SIDE_W - 12, TAB_H, function()
            if self._curtab ~= ci then
                self._curtab = ci
                self._dd     = nil
            end
        end)
    end

    -- ── Content area ───────────────────────────────────────────
    local cx = wx + SIDE_W
    local cy = wy + TOP_H
    local cw = WW - SIDE_W
    local ch = WH - TOP_H

    R("_ct_bg", cx, cy, cw, ch, RF_BG, 2)

    local tab = self._tabs[self._curtab]
    if not tab then return end

    -- measure total content height
    local totalH = PAD
    for _, sec in ipairs(tab.sections) do
        totalH = totalH + SEC_H
        for _, el in ipairs(sec.elements) do
            totalH = totalH + EH(el) + ELEM_G
        end
        totalH = totalH + PAD
    end

    -- scroll state
    local maxSc = math.max(0, totalH - ch + PAD)
    if not self._scroll[self._curtab] then self._scroll[self._curtab] = 0 end
    self._scroll[self._curtab] = math.clamp(self._scroll[self._curtab], 0, maxSc)
    local sc = self._scroll[self._curtab]

    -- scrollbar (thin, Rayfield style)
    if maxSc > 0 then
        local sbx = cx + cw - 4
        local sby = cy + 2
        local sbh = ch - 4
        local tH  = math.max(20, math.floor(sbh * (ch / totalH)))
        local tY  = sby + math.floor((sbh - tH) * (sc / maxSc))
        R("_ct_sbt", sbx, sby, 3, sbh, RF_BORDER, 5)
        GRAD_H("_ct_sbh", sbx, tY, 3, tH, RF_ACC, RF_ACC2, 6, 4)
    end

    local ew  = cw - PAD * 2 - (maxSc > 0 and 6 or 0)
    local cur = cy + PAD - sc

    for _, sec in ipairs(tab.sections) do
        -- Section header
        if cur + SEC_H >= cy and cur <= cy + ch then
            TX("_sh_" .. sec.name, sec.name:upper(), cx + PAD, cur + 6, 10, RF_ACC, 5)
            -- accent underline
            GRAD_H("_sl_" .. sec.name, cx + PAD, cur + SEC_H - 3, ew, 1, RF_ACC, RF_ACC2, 5, 14)
        end
        cur = cur + SEC_H

        for _, el in ipairs(sec.elements) do
            local eh = EH(el)
            if cur + eh >= cy and cur <= cy + ch then
                self:_drawElem(el, cx + PAD, cur, ew, mx, my, 5)
            else
                HIDPFX(el.id)
            end
            cur = cur + eh + ELEM_G
        end
        cur = cur + PAD
    end

    -- dropdown overlay drawn on top
    self:_drawDD(mx, my)
end

-- ────────────────────────────────────────────────────────────────
--  Step  (call every game loop frame)
-- ────────────────────────────────────────────────────────────────
function MatchaUI:Step()
    if self._dead then return end

    local vp  = workspace.CurrentCamera.ViewportSize
    local mx  = 0
    local my  = 0

    local plr = game:GetService("Players").LocalPlayer
    if plr then
        local ms = plr:GetMouse()
        if ms then mx = ms.X; my = ms.Y end
    end

    local m1      = ismouse1pressed()
    local clicked = m1 and not self._pm1
    self._pm1     = m1

    -- Toggle menu visibility
    if self:_edge(self._tkvk) then
        self._visible = not self._visible
        if not self._visible then self._dd = nil end
    end

    -- Window drag
    if self._drag then
        if m1 then
            self._wx = math.clamp(mx - self._dox, 0, vp.X - WW)
            self._wy = math.clamp(my - self._doy, 0, vp.Y - WH)
            self._dd = nil
        else
            self._drag = false
        end
        clicked = false
    end

    -- Scroll with arrow keys
    if self._visible and not self._dd then
        local cti = self._curtab
        if not self._scroll[cti] then self._scroll[cti] = 0 end
        if iskeypressed(0x26) then self._scroll[cti] = math.max(0, self._scroll[cti] - 16) end
        if iskeypressed(0x28) then self._scroll[cti] = self._scroll[cti] + 16 end
    end

    -- Textbox key input
    if self._tbactive then
        local el = self._tbactive
        for vk, ch in pairs(CHARMAP) do
            if self:_edge(vk) then
                local shift = iskeypressed(0xA0) or iskeypressed(0xA1)
                if shift then
                    el.val = el.val .. ch:upper()
                else
                    el.val = el.val .. ch
                end
            end
        end
        if self:_edge(0x08) then el.val = el.val:sub(1, -2) end
        if self:_edge(0x0D) then self._tbactive = nil; pcall(el.cb, el.val) end
        if self:_edge(0x1B) then self._tbactive = nil end
    end

    -- Click handling
    if clicked and self._visible then
        local hitDd = false
        if self._dd then
            local dd = self._dd
            if inside(mx, my, dd.x, dd.y, dd.w, dd.h) then
                hitDd = true
                local i   = math.floor((my - dd.y) / dd.iH) + 1
                local idx = i + dd.sc
                if idx >= 1 and idx <= #dd.opts then
                    dd.onpick(dd.opts[idx])
                end
            else
                self._dd = nil
                hitDd    = true
            end
        end

        if not hitDd then
            if self._tbactive then
                local prev = self._tbactive
                self._tbactive = nil
                pcall(prev.cb, prev.val)
            end
            for _, z in ipairs(self._zones) do
                if inside(mx, my, z.x, z.y, z.w, z.h) then
                    z.fn()
                    break
                end
            end
        end
    end

    -- Rebuild zones each frame
    self._zones = {}

    -- Render
    local ok, err = pcall(self._render, self, mx, my)
    if not ok then
        TX("_err_", "MatchaUI ERR: " .. tostring(err), 8, 50, 12, RF_RED, 99)
    end
end

return MatchaUI
