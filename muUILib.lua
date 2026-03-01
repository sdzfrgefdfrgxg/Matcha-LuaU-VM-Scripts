--[[
    idk now
]]

MatchaUI = {}
MatchaUI.__index = MatchaUI

local function clamp(v, a, b)
    return v < a and a or (v > b and b or v)
end

local function Color3toHSV(c)
    local r, g, b = c.R, c.G, c.B
    local max = math.max(r, g, b)
    local min = math.min(r, g, b)
    local d = max - min
    local h, s, v = 0, 0, max
    if max ~= 0 then s = d / max end
    if d ~= 0 then
        if max == r then h = (g - b) / d % 6
        elseif max == g then h = (b - r) / d + 2
        else h = (r - g) / d + 4 end
        h = h / 6
    end
    return h, s, v
end

function MatchaUI:new(title)
    local inst = setmetatable({}, MatchaUI)
    inst.title      = title or "UI"
    inst.x          = 100
    inst.y          = 80
    inst.w          = 520
    inst.h          = 400
    inst._topbar_h  = 28
    inst._sidebar_w = 120
    inst._pad       = 8
    inst._elem_h    = 24
    inst._font_sz   = 13
    inst._visible   = true
    inst._pages     = {}
    inst._open_page = nil
    inst._drawings  = {}
    inst._drag      = nil

    inst.themes = {
        Background    = Color3.fromRGB(24,  24,  24),
        Accent        = Color3.fromRGB(10,  10,  10),
        LightContrast = Color3.fromRGB(40,  40,  40),
        DarkContrast  = Color3.fromRGB(14,  14,  14),
        TextColor     = Color3.fromRGB(255, 255, 255),
        Highlight     = Color3.fromRGB(60,  60,  60),
        ToggleOn      = Color3.fromRGB(80,  200, 80),
    }

    -- input: VK codes
    inst._inputs = {
        m1     = { id = 0x01, held = false, click = false },
        m2     = { id = 0x02, held = false, click = false },
        ins    = { id = 0x2D, held = false, click = false },
        f1     = { id = 0x70, held = false, click = false },
    }

    return inst
end

-- ─── Drawing helpers ───────────────────────────────────────────────
function MatchaUI:_d(id, dtype, ...)
    local d = self._drawings[id]
    if not d then
        self._drawings[id] = Drawing.new(dtype)
        d = self._drawings[id]
    end
    local a = {...}
    if dtype == "Square" then
        d.Position = a[1]; d.Size = a[2]; d.Color = a[3]
        d.Filled = a[4]; d.Thickness = a[5] or 1; d.ZIndex = a[6] or 1
        d.Transparency = 1
    elseif dtype == "Text" then
        d.Position = a[1]; d.Text = a[2] or ""; d.Color = a[3]
        d.Size = a[4] or self._font_sz; d.Font = Drawing.Fonts.UI
        d.Center = a[5] or false; d.Outline = a[6] or false
        d.ZIndex = a[7] or 2; d.Transparency = 1
    elseif dtype == "Line" then
        d.From = a[1]; d.To = a[2]; d.Color = a[3]
        d.Thickness = a[4] or 1; d.ZIndex = a[5] or 1
        d.Transparency = 1
    end
    d.Visible = true
    return d
end

function MatchaUI:_hide(id)
    local d = self._drawings[id]
    if d then d.Visible = false end
end

function MatchaUI:_hidePrefix(p)
    for k, d in pairs(self._drawings) do
        if k:sub(1, #p) == p then d.Visible = false end
    end
end

function MatchaUI:_removePrefix(p)
    for k, d in pairs(self._drawings) do
        if k:sub(1, #p) == p then d:Remove(); self._drawings[k] = nil end
    end
end

-- ─── Input ─────────────────────────────────────────────────────────
function MatchaUI:_poll()
    for name, inp in pairs(self._inputs) do
        local pressed = iskeypressed(inp.id)
        if isrbxactive() and pressed then
            self._inputs[name].click = not inp.held
            self._inputs[name].held  = true
        else
            self._inputs[name].click = false
            self._inputs[name].held  = false
        end
    end
end

function MatchaUI:_mouse()
    local p = game.Players.LocalPlayer
    if p then
        local m = p:GetMouse()
        if m then return m.X, m.Y end
    end
    return 0, 0
end

function MatchaUI:_over(rx, ry, rw, rh)
    local mx, my = self:_mouse()
    return mx >= rx and mx <= rx + rw and my >= ry and my <= ry + rh
end

-- ─── Public helpers ────────────────────────────────────────────────
function MatchaUI:toggle()
    self._visible = not self._visible
    if not self._visible then self:_hidePrefix("") end
end

function MatchaUI:setTheme(name, c)
    self.themes[name] = c
end

function MatchaUI:Notify(title, text, dur)
    notify(text or "", title or "Notice", dur or 5)
end

-- ─── addPage ───────────────────────────────────────────────────────
function MatchaUI:addPage(title)
    local page = { title = title, sections = {} }
    table.insert(self._pages, page)
    if not self._open_page then self._open_page = page end

    function page:addSection(stitle)
        local sec = { title = stitle, modules = {} }
        table.insert(self.sections, sec)

        local function nextRelY(s)
            local y = 0
            for _, m in ipairs(s.modules) do y = y + m._h + 4 end
            return y
        end

        function sec:addButton(label, cb)
            local m = { _type="button", _h=24, _label=label, _cb=cb, _ry=nextRelY(self) }
            table.insert(self.modules, m); return m
        end

        function sec:addToggle(label, default, cb)
            local m = { _type="toggle", _h=24, _label=label, _value=default or false, _cb=cb, _ry=nextRelY(self) }
            table.insert(self.modules, m)
            m.setValue = function(v) m._value = v; if cb then cb(v) end end
            return m
        end

        function sec:addSlider(label, default, min, max, cb)
            local m = { _type="slider", _h=38, _label=label,
                        _value=default or min, _min=min, _max=max,
                        _cb=cb, _drag=false, _ry=nextRelY(self) }
            table.insert(self.modules, m)
            m.setValue = function(v) m._value = clamp(v, min, max) end
            return m
        end

        function sec:addKeybind(label, default, cb, changedCb)
            local m = { _type="keybind", _h=24, _label=label,
                        _key=default, _cb=cb, _changedCb=changedCb,
                        _listening=false, _ry=nextRelY(self) }
            table.insert(self.modules, m)
            return m
        end

        function sec:addColorPicker(label, default, cb)
            local col = default or Color3.fromRGB(255,255,255)
            local h, s, v = Color3toHSV(col)
            local m = { _type="colorpicker", _h=24, _label=label,
                        _value=col, _cb=cb, _open=false,
                        _h2=h, _s=s, _v=v, _ry=nextRelY(self) }
            table.insert(self.modules, m)
            m.setValue = function(c)
                m._value = c
                m._h2, m._s, m._v = Color3toHSV(c)
                if cb then cb(c) end
            end
            return m
        end

        function sec:addDropdown(label, list, cb)
            local m = { _type="dropdown", _h=24, _label=label,
                        _list=list or {}, _selected=nil,
                        _cb=cb, _open=false, _ry=nextRelY(self) }
            table.insert(self.modules, m)
            return m
        end

        return sec
    end

    return page
end

-- ─── Step ──────────────────────────────────────────────────────────
function MatchaUI:Step()
    self:_poll()

    -- INSERT to toggle
    if self._inputs.ins.click then
        self._visible = not self._visible
    end

    if not self._visible then
        self:_hidePrefix("")
        return
    end

    local click = self._inputs.m1.click
    local held  = self._inputs.m1.held
    local mx, my = self:_mouse()
    local x, y, w, h = self.x, self.y, self.w, self.h
    local T, SW, P = self._topbar_h, self._sidebar_w, self._pad
    local t = self.themes
    local fs = self._font_sz

    -- drag
    if held and self._drag then
        self.x = mx - self._drag.x
        self.y = my - self._drag.y
        x, y = self.x, self.y
    end
    if not held then self._drag = nil end
    if click and self:_over(x, y, w, T) and not self._drag then
        self._drag = { x = mx - x, y = my - y }
    end

    -- shadow
    local s = self._d("_shadow","Square",Vector2.new(x-4,y-4),Vector2.new(w+8,h+8),Color3.fromRGB(0,0,0),true,1,0)
    s.Transparency = 0.5

    -- bg / topbar / sidebar / divider
    self:_d("_bg",   "Square", Vector2.new(x,y),      Vector2.new(w,h),     t.Background,    true, 1, 1)
    self:_d("_top",  "Square", Vector2.new(x,y),      Vector2.new(w,T),     t.Accent,        true, 1, 2)
    self:_d("_titl", "Text",   Vector2.new(x+P, y+7), self.title,           t.TextColor,     fs+1, false, false, 3)
    self:_d("_side", "Square", Vector2.new(x,y+T),    Vector2.new(SW,h-T),  t.DarkContrast,  true, 1, 2)
    self:_d("_div",  "Line",   Vector2.new(x+SW,y+T), Vector2.new(x+SW,y+h),t.LightContrast, 1, 3)

    -- page buttons
    for i, pg in ipairs(self._pages) do
        local by = y + T + P + (i-1)*28
        local isOpen = self._open_page == pg
        self:_d("pb"..i.."b","Square", Vector2.new(x+4,by), Vector2.new(SW-8,22),
            isOpen and t.Highlight or t.DarkContrast, true, 1, 3)
        self:_d("pb"..i.."t","Text",   Vector2.new(x+8,by+5), pg.title,
            t.TextColor, fs, false, false, 4)
        if click and self:_over(x+4, by, SW-8, 22) then
            self._open_page = pg
        end
    end

    -- content
    if not self._open_page then return end

    local cX = x + SW + P
    local cW = w - SW - P*2
    local secY = y + T + P

    for si, sec in ipairs(self._open_page.sections) do
        local sid = "s"..si

        self:_d(sid.."h","Square", Vector2.new(cX,secY),   Vector2.new(cW,20),   t.Accent,    true, 1, 3)
        self:_d(sid.."t","Text",   Vector2.new(cX+6,secY+4), sec.title,           t.TextColor, fs-1, false, false, 4)

        local mY = secY + 24

        for mi, m in ipairs(sec.modules) do
            local mid = sid.."m"..mi
            local mX, mW, mH = cX, cW, m._h

            if m._type == "button" then
                local hov = self:_over(mX,mY,mW,mH)
                self:_d(mid.."b","Square",Vector2.new(mX,mY),Vector2.new(mW,mH),
                    hov and t.Highlight or t.DarkContrast, true, 1, 4)
                self:_d(mid.."t","Text",Vector2.new(mX+mW/2,mY+5),m._label,
                    t.TextColor, fs, true, false, 5)
                if click and hov and m._cb then m._cb() end

            elseif m._type == "toggle" then
                self:_d(mid.."b","Square",Vector2.new(mX,mY),Vector2.new(mW,mH),t.DarkContrast,true,1,4)
                self:_d(mid.."t","Text",Vector2.new(mX+8,mY+5),m._label,t.TextColor,fs,false,false,5)
                local pX = mX+mW-38; local pY = mY+5
                self:_d(mid.."pb","Square",Vector2.new(pX,pY),Vector2.new(30,14),
                    m._value and t.ToggleOn or t.LightContrast, true,1,5)
                self:_d(mid.."pd","Square",
                    Vector2.new(m._value and pX+18 or pX+2, pY+2),
                    Vector2.new(10,10), t.TextColor, true, 1, 6)
                if click and self:_over(mX,mY,mW,mH) then
                    m._value = not m._value
                    if m._cb then m._cb(m._value) end
                end

            elseif m._type == "slider" then
                self:_d(mid.."b","Square",Vector2.new(mX,mY),Vector2.new(mW,mH),t.DarkContrast,true,1,4)
                self:_d(mid.."l","Text",Vector2.new(mX+8,mY+5),m._label,t.TextColor,fs,false,false,5)
                self:_d(mid.."v","Text",Vector2.new(mX+mW-32,mY+5),
                    tostring(math.floor(m._value)),t.TextColor,fs,false,false,5)
                local tX,tY,tW = mX+8, mY+mH-10, mW-16
                self:_d(mid.."tr","Square",Vector2.new(tX,tY),Vector2.new(tW,4),t.LightContrast,true,1,5)
                local pct = (m._value-m._min)/(m._max-m._min)
                self:_d(mid.."fl","Square",Vector2.new(tX,tY),Vector2.new(tW*pct,4),t.TextColor,true,1,6)
                self:_d(mid.."kn","Square",Vector2.new(tX+tW*pct-5,tY-3),Vector2.new(10,10),t.TextColor,true,1,7)
                if held and self:_over(mX,mY,mW,mH) then m._drag = true end
                if not held then m._drag = false end
                if m._drag then
                    local p = clamp((mx-tX)/tW,0,1)
                    m._value = math.floor(m._min + (m._max-m._min)*p)
                    if m._cb then m._cb(m._value) end
                end

            elseif m._type == "keybind" then
                self:_d(mid.."b","Square",Vector2.new(mX,mY),Vector2.new(mW,mH),t.DarkContrast,true,1,4)
                self:_d(mid.."t","Text",Vector2.new(mX+8,mY+5),m._label,t.TextColor,fs,false,false,5)
                local kl = m._listening and "..." or (m._key and ("VK "..m._key) or "None")
                self:_d(mid.."kb","Square",Vector2.new(mX+mW-74,mY+3),Vector2.new(68,mH-6),t.LightContrast,true,1,4)
                self:_d(mid.."kt","Text",Vector2.new(mX+mW-40,mY+5),kl,t.TextColor,fs-1,true,false,5)
                if click and self:_over(mX,mY,mW,mH) then
                    if m._key then m._key = nil
                    else m._listening = true end
                end
                if m._listening then
                    -- scan common VK range
                    for vk = 0x01, 0xFE do
                        if vk ~= 0x01 and iskeypressed(vk) then
                            m._key = vk; m._listening = false
                            if m._changedCb then m._changedCb(vk) end
                            break
                        end
                    end
                end
                if m._key and not m._listening and iskeypressed(m._key) and m._cb then
                    m._cb()
                end

            elseif m._type == "colorpicker" then
                self:_d(mid.."b","Square",Vector2.new(mX,mY),Vector2.new(mW,mH),t.DarkContrast,true,1,4)
                self:_d(mid.."t","Text",Vector2.new(mX+8,mY+5),m._label,t.TextColor,fs,false,false,5)
                self:_d(mid.."sw","Square",Vector2.new(mX+mW-38,mY+4),Vector2.new(30,16),m._value,true,1,5)
                self:_d(mid.."sb","Square",Vector2.new(mX+mW-39,mY+3),Vector2.new(32,18),t.LightContrast,false,1,5)
                if click and self:_over(mX,mY,mW,mH) then m._open = not m._open end
                if m._open then
                    local PW,PH = 160,130
                    local px,py = mX+mW+4, mY
                    self:_d(mid.."pb","Square",Vector2.new(px,py),Vector2.new(PW,PH),t.Background,true,1,10)
                    self:_d(mid.."ph","Square",Vector2.new(px,py),Vector2.new(PW,18),t.Accent,true,1,11)
                    self:_d(mid.."pt","Text",Vector2.new(px+5,py+3),m._label,t.TextColor,fs-1,false,false,12)
                    self:_d(mid.."px","Text",Vector2.new(px+PW-14,py+3),"x",t.TextColor,fs,false,false,12)
                    local svX,svY,svW,svH = px+6,py+22,PW-12,PH-48
                    self:_d(mid.."sv","Square",Vector2.new(svX,svY),Vector2.new(svW,svH),
                        Color3.fromHSV(m._h2,1,1),true,1,11)
                    self:_d(mid.."sc","Square",
                        Vector2.new(svX+m._s*svW-4, svY+(1-m._v)*svH-4),
                        Vector2.new(8,8),t.TextColor,false,1,13)
                    local hY = py+PH-20
                    local hues={Color3.fromRGB(255,0,0),Color3.fromRGB(255,128,0),
                        Color3.fromRGB(255,255,0),Color3.fromRGB(0,255,0),
                        Color3.fromRGB(0,255,255),Color3.fromRGB(0,0,255),
                        Color3.fromRGB(255,0,255),Color3.fromRGB(255,0,0)}
                    local sw2=math.floor(PW/#hues)
                    for hi,hc in ipairs(hues) do
                        self:_d(mid.."hs"..hi,"Square",Vector2.new(px+(hi-1)*sw2,hY),Vector2.new(sw2,12),hc,true,1,11)
                    end
                    self:_d(mid.."hsl","Square",Vector2.new(px+m._h2*PW-2,hY),Vector2.new(4,12),t.TextColor,true,1,12)
                    if held and self:_over(svX,svY,svW,svH) then
                        m._s = clamp((mx-svX)/svW,0,1)
                        m._v = 1-clamp((my-svY)/svH,0,1)
                        m._value = Color3.fromHSV(m._h2,m._s,m._v)
                        if m._cb then m._cb(m._value) end
                    end
                    if held and self:_over(px,hY,PW,12) then
                        m._h2 = clamp((mx-px)/PW,0,1)
                        m._value = Color3.fromHSV(m._h2,m._s,m._v)
                        if m._cb then m._cb(m._value) end
                    end
                    if click and self:_over(px+PW-18,py,18,18) then m._open=false end
                else
                    self:_hidePrefix(mid.."p")
                    self:_hidePrefix(mid.."sv")
                    self:_hidePrefix(mid.."sc")
                    self:_hidePrefix(mid.."hs")
                end

            elseif m._type == "dropdown" then
                local lbl = m._selected and tostring(m._selected) or m._label
                self:_d(mid.."b","Square",Vector2.new(mX,mY),Vector2.new(mW,mH),t.DarkContrast,true,1,4)
                self:_d(mid.."t","Text",Vector2.new(mX+8,mY+5),lbl,t.TextColor,fs,false,false,5)
                self:_d(mid.."a","Text",Vector2.new(mX+mW-16,mY+5),m._open and"^"or"v",t.TextColor,fs,false,false,5)
                if click and self:_over(mX,mY,mW,mH) then m._open=not m._open end
                if m._open then
                    for ii,val in ipairs(m._list) do
                        local iy = mY+mH+(ii-1)*(mH+2)
                        local hov = self:_over(mX,iy,mW,mH)
                        self:_d(mid.."ib"..ii,"Square",Vector2.new(mX,iy),Vector2.new(mW,mH),
                            hov and t.Highlight or t.Background,true,1,7)
                        self:_d(mid.."it"..ii,"Text",Vector2.new(mX+8,iy+5),tostring(val),t.TextColor,fs,false,false,8)
                        if click and hov then
                            m._selected=val; m._open=false
                            if m._cb then m._cb(val) end
                        end
                    end
                else
                    self:_removePrefix(mid.."ib")
                    self:_removePrefix(mid.."it")
                end
            end

            mY = mY + mH + 4
        end

        secY = mY + P
    end
end
