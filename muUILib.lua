MatchaUI = {}
MatchaUI.__index = MatchaUI

local C_bg       = Color3.fromRGB(12,  13,  18)
local C_panel    = Color3.fromRGB(17,  18,  26)
local C_sidebar  = Color3.fromRGB(15,  15,  22)
local C_card     = Color3.fromRGB(22,  23,  33)
local C_cardHov  = Color3.fromRGB(28,  30,  42)
local C_acc      = Color3.fromRGB(0,   170, 255)
local C_accDim   = Color3.fromRGB(0,   90,  140)
local C_accDark  = Color3.fromRGB(0,   35,  58)
local C_accGlow  = Color3.fromRGB(120, 220, 255)
local C_bord     = Color3.fromRGB(35,  37,  52)
local C_txt      = Color3.fromRGB(215, 225, 240)
local C_txtDim   = Color3.fromRGB(110, 120, 150)
local C_txtMuted = Color3.fromRGB(55,  60,  90)
local C_dropBg   = Color3.fromRGB(9,   10,  15)
local C_dropHov  = Color3.fromRGB(0,   45,  70)
local C_black    = Color3.fromRGB(0,   0,   0)
local C_white    = Color3.fromRGB(255, 255, 255)
local C_red      = Color3.fromRGB(225, 55,  70)
local C_redDk    = Color3.fromRGB(80,  14,  20)
local C_togOn    = Color3.fromRGB(0,   170, 255)
local C_togOff   = Color3.fromRGB(45,  47,  68)
local C_slider   = Color3.fromRGB(25,  26,  38)
local C_input    = Color3.fromRGB(10,  11,  17)
local C_notif    = Color3.fromRGB(16,  18,  28)

local pool = {}

local function D(id, dtype)
    if not pool[id] then
        pool[id] = Drawing.new(dtype)
        pool[id].Visible = false
    end
    return pool[id]
end

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

local function RO(id, x, y, w, h, col, zi)
    local d = D(id, "Square")
    d.Position  = Vector2.new(x, y)
    d.Size      = Vector2.new(w, h)
    d.Color     = col
    d.Filled    = false
    d.Thickness = 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

local function TX(id, text, x, y, sz, col, zi, center)
    local d = D(id, "Text")
    d.Text     = tostring(text)
    d.Position = Vector2.new(x, y)
    d.Size     = sz or 13
    d.Color    = col or C_txt
    d.Font     = Drawing.Fonts.UI
    d.Outline  = false
    d.Center   = (center == true)
    d.ZIndex   = zi or 2
    d.Visible  = true
end

local function LN(id, x1, y1, x2, y2, col, zi)
    local d = D(id, "Line")
    d.From      = Vector2.new(x1, y1)
    d.To        = Vector2.new(x2, y2)
    d.Color     = col
    d.Thickness = 1
    d.ZIndex    = zi or 1
    d.Visible   = true
end

local function CL(id, cx, cy, r, col, zi)
    local d = D(id, "Circle")
    d.Position  = Vector2.new(cx, cy)
    d.Radius    = r
    d.Color     = col
    d.Filled    = true
    d.NumSides  = 20
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

local _uid = 0
local function uid()
    _uid = _uid + 1
    return "u" .. _uid .. "_"
end

local function inside(mx, my, x, y, w, h)
    return mx >= x and mx <= x + w and my >= y and my <= y + h
end

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
    return "0x" .. string.format("%X", vk)
end

local CHARMAP = {}
for vk = 0x41, 0x5A do CHARMAP[vk] = string.char(vk + 32) end
for vk = 0x30, 0x39 do CHARMAP[vk] = string.char(vk) end
CHARMAP[0x20] = " "
CHARMAP[0xBD] = "-"
CHARMAP[0xBE] = "."

local WW      = 560
local WH      = 450
local SIDE_W  = 118
local TOP_H   = 48
local PAD     = 10
local TAB_H   = 32
local ELEM_H  = 42
local ELEM_G  = 5
local NW      = 290
local NH      = 56

function MatchaUI:Init(cfg)
    cfg = cfg or {}
    self._title   = cfg.Title    or "MatchaUI"
    self._sub     = cfg.Subtitle or ""
    local tk      = cfg.ToggleKey or "f2"
    self._tkvk    = KEY_STR[tk:lower()] or 0x71
    self._tkvname = tk:upper()
    local vp      = workspace.CurrentCamera.ViewportSize
    self._wx      = math.floor((vp.X - WW) / 2)
    self._wy      = math.floor((vp.Y - WH) / 2)
    self._visible = true
    self._tabs    = {}
    self._curtab  = 1
    self._drag    = false
    self._dox     = 0
    self._doy     = 0
    self._pm1     = false
    self._prevvk  = {}
    self._dd      = nil
    self._tbactive = nil
    self._kblisten = nil
    self._notifs  = {}
    self._scroll  = {}
    self._zones   = {}
    return self
end

function MatchaUI:Tab(name)
    local tab = {name=name, sections={}}
    table.insert(self._tabs, tab)
    if #self._tabs == 1 then self._curtab = 1 end

    function tab:Section(sname)
        local sec = {name=sname, elements={}}
        table.insert(self.sections, sec)

        function sec:Button(ename, cb)
            table.insert(self.elements, {t="btn",name=ename,id=uid(),cb=cb or function() end})
        end

        function sec:Toggle(ename, default, cb)
            local el = {t="tog",name=ename,id=uid(),val=(default==true),cb=cb or function() end}
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val=(v==true); pcall(el.cb, el.val) end
            return obj
        end

        function sec:Slider(ename, default, step, mn, mx2, suffix, cb)
            local el = {
                t="sld",name=ename,id=uid(),
                val=default or 0,step=step or 1,
                min=mn or 0,max=mx2 or 100,
                suffix=suffix or "",cb=cb or function() end,
                dragging=false
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val=math.clamp(v,el.min,el.max); pcall(el.cb,el.val) end
            return obj
        end

        function sec:Dropdown(ename, default, options, multi, cb)
            local el = {
                t="dd",name=ename,id=uid(),
                val=default or {},opts=options or {},
                multi=(multi==true),cb=cb or function() end
            }
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val=v; pcall(el.cb, el.val) end
            function obj:Refresh(opts, def) el.opts=opts or {}; el.val=def or {} end
            return obj
        end

        function sec:Textbox(ename, default, cb)
            local el = {t="tbx",name=ename,id=uid(),val=default or "",cb=cb or function() end,active=false}
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v) el.val=v end
            return obj
        end

        function sec:Keybind(ename, defaultKey, cb)
            local vk = 0x71
            local vname = "F2"
            if type(defaultKey) == "string" then
                vk = KEY_STR[defaultKey:lower()] or 0x71
                vname = defaultKey:upper()
            elseif type(defaultKey) == "number" then
                vk = defaultKey
                vname = vkToName(vk)
            end
            local el = {t="kb",name=ename,id=uid(),vk=vk,vname=vname,cb=cb or function() end,listening=false}
            table.insert(self.elements, el)
            local obj = {}
            function obj:Set(v, n) el.vk=v; el.vname=n or vkToName(v) end
            return obj
        end

        function sec:Label(text)
            table.insert(self.elements, {t="lbl",text=text,id=uid()})
        end

        function sec:Divider()
            table.insert(self.elements, {t="div",id=uid()})
        end

        return sec
    end

    return tab
end

function MatchaUI:Notify(text, duration)
    duration = duration or 3
    table.insert(self._notifs, {
        text=tostring(text),dur=duration,
        born=tick(),expires=tick()+duration,id=uid()
    })
end

function MatchaUI:Unload()
    self._dead = true
    for _, d in pairs(pool) do pcall(function() d.Visible=false end) end
end

local function EH(el)
    if el.t == "lbl" then return 22 end
    if el.t == "div" then return 12 end
    if el.t == "sld" then return 52 end
    return ELEM_H
end

function MatchaUI:_zone(x, y, w, h, fn)
    table.insert(self._zones, {x=x,y=y,w=w,h=h,fn=fn})
end

function MatchaUI:_edge(vk)
    local now  = iskeypressed(vk)
    local prev = self._prevvk[vk] or false
    self._prevvk[vk] = now
    return now and not prev
end

function MatchaUI:_drawElem(el, ex, ey, ew, mx, my, zi)
    local p = el.id

    if el.t == "lbl" then
        TX(p.."tx", el.text, ex+4, ey+4, 12, C_txtDim, zi)
        return
    end

    if el.t == "div" then
        LN(p.."ln", ex, ey+6, ex+ew, ey+6, C_bord, zi)
        return
    end

    local eh  = EH(el)
    local hov = inside(mx, my, ex, ey, ew, eh)

    local bgc = C_card
    if hov then bgc = C_cardHov end
    R(p.."bg",  ex,   ey,   ew, eh, bgc,   zi)
    RO(p.."bd", ex,   ey,   ew, eh, C_bord, zi+1)
    if hov then R(p.."pip", ex, ey, 2, eh, C_acc, zi+2) end

    local nameY = ey + 14
    if el.t == "sld" then nameY = ey + 8 end
    TX(p.."nm", el.name, ex+10, nameY, 13, C_txt, zi+2)

    if el.t == "btn" then
        local bw = 64
        local bx = ex + ew - bw - 8
        local by = ey + 10
        R(p.."cbg",  bx, by, bw, 22, C_accDim, zi+3)
        RO(p.."cbd", bx, by, bw, 22, C_acc,    zi+4)
        TX(p.."ctx", "Run", bx+bw/2, by+5, 11, C_white, zi+5, true)
        self:_zone(ex, ey, ew, eh, function() pcall(el.cb) end)

    elseif el.t == "tog" then
        local pw  = 36
        local ph  = 16
        local px  = ex + ew - pw - 8
        local py  = ey + math.floor((eh - ph) / 2)
        local on  = el.val
        local bgc2  = C_togOff
        local bdc  = C_bord
        local knx  = px + 2
        local knc  = C_txtDim
        local lbl  = "OFF"
        local lblc = C_txtDim
        if on then
            bgc2  = C_togOn
            bdc  = C_acc
            knx  = px + pw - ph + 2
            knc  = C_white
            lbl  = "ON"
            lblc = C_white
        end
        R(p.."tbg",  px,  py,  pw, ph, bgc2, zi+3)
        RO(p.."tbd", px,  py,  pw, ph, bdc,  zi+4)
        R(p.."knb",  knx, py+2, ph-4, ph-4, knc, zi+5)
        TX(p.."ttx", lbl, px+pw/2, py+3, 9, lblc, zi+5, true)
        self:_zone(ex, ey, ew, eh, function()
            el.val = not el.val
            pcall(el.cb, el.val)
        end)

    elseif el.t == "sld" then
        local sw  = ew - 20
        local sx  = ex + 10
        local sy  = ey + 30
        local sh  = 6
        local rng = math.max(1, el.max - el.min)
        local pct = (el.val - el.min) / rng
        local fw  = math.max(4, math.floor(pct * sw))
        R(p.."tr",  sx,      sy, sw, sh, C_slider,   zi+3)
        R(p.."fl",  sx,      sy, fw, sh, C_acc,       zi+4)
        CL(p.."kn", sx+fw, sy+sh/2, 5, C_accGlow,    zi+5)
        RO(p.."trd",sx,      sy, sw, sh, C_bord,      zi+3)
        TX(p.."vl", tostring(math.floor(el.val))..el.suffix, ex+ew-10, ey+8, 12, C_accGlow, zi+3)
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
        self:_zone(sx, sy-6, sw, sh+12, function() el.dragging=true end)

    elseif el.t == "dd" then
        local dw  = 130
        local dx  = ex + ew - dw - 8
        local dy  = ey + 10
        local dh  = 22
        local isO = (self._dd ~= nil and self._dd.eid == el.id)
        local disp = "None"
        if type(el.val) == "table" then
            if #el.val == 1 then
                disp = el.val[1]
            elseif #el.val > 1 then
                disp = el.val[1] .. " (+" .. (#el.val-1) .. ")"
            end
        elseif type(el.val) == "string" and el.val ~= "" then
            disp = el.val
        end
        local dbd = C_bord
        local dtc = C_txtDim
        if isO then dbd = C_acc; dtc = C_accGlow end
        R(p.."dbg",  dx, dy, dw, dh, C_dropBg, zi+3)
        RO(p.."dbd", dx, dy, dw, dh, dbd,       zi+4)
        TX(p.."dtx", disp, dx+7, dy+5, 12, dtc, zi+5)
        TX(p.."dar", "v",  dx+dw-12, dy+5, 12, C_txtMuted, zi+5)
        local eid = el.id
        local eref = el
        self:_zone(dx, dy, dw, dh, function()
            if isO then self._dd=nil; return end
            local ms   = math.min(7, #eref.opts)
            local popH = ms * 20 + 4
            local iy   = dy + dh + 1
            local vp2  = workspace.CurrentCamera.ViewportSize
            if iy + popH > self._wy + WH - 4 then iy = dy - popH - 1 end
            local uiref = self
            self._dd = {
                eid=eid, x=dx, y=iy, w=dw, h=popH,
                opts=eref.opts, sel=eref.val,
                ms=ms, iH=20, sc=0, multi=eref.multi,
                onpick=function(v)
                    if eref.multi then
                        local sel = eref.val
                        if type(sel) ~= "table" then sel={} end
                        local found = false
                        for i, s in ipairs(sel) do
                            if s == v then table.remove(sel,i); found=true; break end
                        end
                        if not found then table.insert(sel, v) end
                        eref.val = sel
                        pcall(eref.cb, eref.val)
                    else
                        eref.val = {v}
                        pcall(eref.cb, eref.val)
                        uiref._dd = nil
                    end
                end
            }
        end)

    elseif el.t == "tbx" then
        local tw  = 130
        local tx2 = ex + ew - tw - 8
        local ty2 = ey + 10
        local th  = 24
        local active = (self._tbactive == el)
        local disp2 = el.val
        if active then
            local blink = (math.floor(tick() * 2) % 2 == 0)
            if blink then disp2 = el.val .. "|" end
        end
        local tbd = C_bord
        local ttc = C_txtDim
        if active then tbd=C_acc; ttc=C_txt end
        R(p.."tbg",  tx2, ty2, tw, th, C_input, zi+3)
        RO(p.."tbd", tx2, ty2, tw, th, tbd,     zi+4)
        TX(p.."ttx", disp2, tx2+6, ty2+6, 12, ttc, zi+5)
        local eref2 = el
        self:_zone(tx2, ty2, tw, th, function() self._tbactive=eref2 end)

    elseif el.t == "kb" then
        local kw  = math.max(50, #el.vname * 7 + 14)
        local kx  = ex + ew - kw - 8
        local ky  = ey + 11
        local kh  = 20
        if el.listening then
            R(p.."kbg",  kx, ky, kw, kh, C_redDk, zi+3)
            RO(p.."kbd", kx, ky, kw, kh, C_red,   zi+4)
            TX(p.."ktx", "...", kx+kw/2, ky+4, 11, C_red, zi+5, true)
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
            R(p.."kbg",  kx, ky, kw, kh, C_accDark, zi+3)
            RO(p.."kbd", kx, ky, kw, kh, C_acc,     zi+4)
            TX(p.."ktx", el.vname, kx+kw/2, ky+4, 11, C_accGlow, zi+5, true)
            local eref3 = el
            local uiref2 = self
            self:_zone(kx, ky, kw, kh, function()
                if uiref2._kblisten then uiref2._kblisten.listening=false end
                eref3.listening   = true
                uiref2._kblisten  = eref3
            end)
        end
    end
end

function MatchaUI:_drawNotifs()
    local now = tick()
    for i = #self._notifs, 1, -1 do
        if now >= self._notifs[i].expires then
            HIDPFX(self._notifs[i].id)
            table.remove(self._notifs, i)
        end
    end
    local vp  = workspace.CurrentCamera.ViewportSize
    local bx  = vp.X - NW - 12
    local by  = vp.Y - 12
    for i, n in ipairs(self._notifs) do
        local ny  = by - i * (NH + 8)
        local age = now - n.born
        local sl  = math.min(1, age / 0.2)
        local nx  = bx + NW * (1 - sl)
        local p   = n.id
        R(p.."sh",  nx+3, ny+3, NW,   NH,   C_black, 44)
        R(p.."bg",  nx,   ny,   NW,   NH,   C_notif, 45)
        RO(p.."bd", nx,   ny,   NW,   NH,   C_acc,   46)
        R(p.."ac",  nx,   ny,   3,    NH,   C_acc,   47)
        TX(p.."tx", n.text, nx+12, ny+math.floor((NH-13)/2), 13, C_txt, 48)
        local pct = math.max(0, (n.expires - now) / n.dur)
        local bw  = math.floor(pct * (NW - 6))
        R(p.."bt",  nx+3, ny+NH-4, NW-6, 2, C_bord, 48)
        if bw > 0 then R(p.."bf", nx+3, ny+NH-4, bw, 2, C_acc, 49) end
    end
end

function MatchaUI:_drawDD(mx, my)
    local dd = self._dd
    if not dd then return end
    R("_dd_sh",  dd.x+3, dd.y+3, dd.w, dd.h, C_black,  28)
    R("_dd_bg",  dd.x,   dd.y,   dd.w, dd.h, C_dropBg, 29)
    RO("_dd_bd", dd.x,   dd.y,   dd.w, dd.h, C_acc,    30)
    R("_dd_tl",  dd.x,   dd.y,   dd.w, 2,    C_acc,    31)
    for i = 1, dd.ms do
        local idx  = i + dd.sc
        if idx <= #dd.opts then
            local iy  = dd.y + (i-1) * dd.iH
            local val = dd.opts[idx]
            local sel = false
            if type(dd.sel) == "table" then
                for _, s in ipairs(dd.sel) do
                    if s == val then sel=true; break end
                end
            else
                sel = (dd.sel == val)
            end
            local hov = inside(mx, my, dd.x+1, iy, dd.w-2, dd.iH)
            if sel then
                R("_ddi_b"..i,  dd.x+1, iy, dd.w-2, dd.iH-1, C_accDark, 31)
                LN("_ddi_l"..i, dd.x+1, iy, dd.x+1, iy+dd.iH-2, C_acc, 32)
            elseif hov then
                R("_ddi_b"..i, dd.x+1, iy, dd.w-2, dd.iH-1, C_dropHov, 31)
            else
                HID("_ddi_b"..i)
                HID("_ddi_l"..i)
            end
            local itc = C_txtDim
            if sel then itc = C_accGlow elseif hov then itc = C_txt end
            TX("_ddi_t"..i, val, dd.x+9, iy+4, 13, itc, 32)
        end
    end
end

function MatchaUI:_render(mx, my)
    self:_drawNotifs()

    if not self._visible then
        HIDPFX("_w")
        HIDPFX("_tb")
        HIDPFX("_sb")
        HIDPFX("_ct")
        HIDPFX("_dd")
        HIDPFX("_si")
        return
    end

    local wx = self._wx
    local wy = self._wy

    R("_w_sh",  wx+4, wy+4, WW,   WH,   C_black,  0)
    R("_w_bg",  wx,   wy,   WW,   WH,   C_bg,     1)
    RO("_w_bd", wx,   wy,   WW,   WH,   C_bord,   2)
    R("_w_el",  wx,   wy,   2,    WH,   C_acc,    3)
    R("_w_et",  wx,   wy,   WW,   1,    C_acc,    3)

    R("_tb_bg",  wx,   wy,           WW,  TOP_H, C_sidebar, 2)
    R("_tb_sep", wx,   wy+TOP_H-1,   WW,  1,     C_acc,     3)
    TX("_tb_nm", self._title,  wx+14, wy+9,  15, C_txt,    4)
    TX("_tb_sb", self._sub,    wx+14, wy+27, 11, C_txtDim, 4)
    TX("_tb_hk", "["..self._tkvname.."]", wx+WW-52, wy+18, 11, C_txtMuted, 4)

    R("_tb_cx",  wx+WW-26, wy+13, 14, 14, C_redDk, 4)
    RO("_tb_cxd",wx+WW-26, wy+13, 14, 14, C_red,   5)
    TX("_tb_cxt","X", wx+WW-19, wy+15, 10, C_red, 6, true)
    self:_zone(wx+WW-26, wy+13, 14, 14, function() self._visible=false end)
    self:_zone(wx, wy, WW-34, TOP_H, function()
        self._drag=true; self._dox=mx-wx; self._doy=my-wy
    end)

    R("_sb_bg",  wx,          wy+TOP_H, SIDE_W, WH-TOP_H, C_sidebar, 2)
    R("_sb_sep", wx+SIDE_W-1, wy+TOP_H, 1,      WH-TOP_H, C_bord,   3)

    for i, tab in ipairs(self._tabs) do
        local ty  = wy + TOP_H + (i-1) * TAB_H
        local isA = (i == self._curtab)
        local p   = "_si"..i.."_"
        local sbgc = C_sidebar
        local spipc = C_bord
        local stc   = C_txtDim
        if isA then sbgc=C_accDark; spipc=C_acc; stc=C_acc end
        R(p.."bg",  wx,   ty,          SIDE_W, TAB_H,  sbgc,  4)
        R(p.."pip", wx,   ty,          3,      TAB_H,  spipc, 5)
        R(p.."bot", wx,   ty+TAB_H-1,  SIDE_W, 1,      C_bord, 4)
        TX(p.."lb", tab.name, wx+12, ty+math.floor((TAB_H-13)/2), 13, stc, 5)
        local ci = i
        self:_zone(wx, ty, SIDE_W, TAB_H, function()
            if self._curtab ~= ci then self._curtab=ci; self._dd=nil end
        end)
    end

    local cx = wx + SIDE_W
    local cy = wy + TOP_H
    local cw = WW - SIDE_W
    local ch = WH - TOP_H

    R("_ct_bg", cx, cy, cw, ch, C_panel, 2)

    local tab = self._tabs[self._curtab]
    if not tab then return end

    local totalH = PAD
    for _, sec in ipairs(tab.sections) do
        totalH = totalH + 24
        for _, el in ipairs(sec.elements) do
            totalH = totalH + EH(el) + ELEM_G
        end
        totalH = totalH + PAD
    end

    local maxSc = math.max(0, totalH - ch + PAD)
    if not self._scroll[self._curtab] then self._scroll[self._curtab]=0 end
    self._scroll[self._curtab] = math.clamp(self._scroll[self._curtab], 0, maxSc)
    local sc = self._scroll[self._curtab]

    if maxSc > 0 then
        local sbx = cx + cw - 5
        local sby = cy + 2
        local sbh = ch - 4
        local tH  = math.max(18, math.floor(sbh * (ch / totalH)))
        local tY  = sby + math.floor((sbh - tH) * (sc / maxSc))
        R("_ct_sbt", sbx, sby, 4, sbh, C_bord, 5)
        R("_ct_sbh", sbx, tY,  4, tH,  C_acc,  6)
    end

    local ew  = cw - PAD*2 - (maxSc > 0 and 8 or 0)
    local cur = cy + PAD - sc

    for _, sec in ipairs(tab.sections) do
        if cur + 20 >= cy and cur <= cy+ch then
            TX("_sh_"..sec.name, sec.name, cx+PAD, cur+4, 10, C_acc, 5)
            LN("_sl_"..sec.name, cx+PAD+#sec.name*6+4, cur+9, cx+PAD+ew, cur+9, C_accDim, 5)
        end
        cur = cur + 24
        for _, el in ipairs(sec.elements) do
            local eh = EH(el)
            if cur + eh >= cy and cur <= cy+ch then
                self:_drawElem(el, cx+PAD, cur, ew, mx, my, 5)
            else
                HIDPFX(el.id)
            end
            cur = cur + eh + ELEM_G
        end
        cur = cur + PAD
    end

    self:_drawDD(mx, my)
end

function MatchaUI:Step()
    if self._dead then return end

    local vp  = workspace.CurrentCamera.ViewportSize
    local mx  = 0
    local my  = 0
    local plr = game:GetService("Players").LocalPlayer
    if plr then
        local ms = plr:GetMouse()
        if ms then mx=ms.X; my=ms.Y end
    end

    local m1      = ismouse1pressed()
    local clicked = m1 and not self._pm1
    self._pm1     = m1

    if self:_edge(self._tkvk) then
        self._visible = not self._visible
        if not self._visible then self._dd=nil end
    end

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

    if self._visible and not self._dd then
        local cti = self._curtab
        if not self._scroll[cti] then self._scroll[cti]=0 end
        if iskeypressed(0x26) then self._scroll[cti]=math.max(0,self._scroll[cti]-16) end
        if iskeypressed(0x28) then self._scroll[cti]=self._scroll[cti]+16 end
    end

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
        if self:_edge(0x08) then el.val=el.val:sub(1,-2) end
        if self:_edge(0x0D) then self._tbactive=nil; pcall(el.cb, el.val) end
        if self:_edge(0x1B) then self._tbactive=nil end
    end

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

    self._zones = {}

    local ok, err = pcall(self._render, self, mx, my)
    if not ok then
        TX("_err", "MatchaUI ERR: "..tostring(err), 8, 50, 12, C_red, 99)
    end
end

return MatchaUI
