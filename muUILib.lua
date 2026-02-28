local MatchaUI = {
    -- internal
    _drawings = {},
    _tree = {},
    _open_tab = nil,
    _tab_change_at = 0,
    _menu_open = true,
    _menu_toggled_at = 0,
    _menu_drag = nil,
    _slider_drag = nil,
    _input_ctx = nil,
    _active_dropdown = nil,
    _notifications = {},
    _notif_count = 0,
    _font = Drawing.Fonts.UI,

    -- keybinds
    _toggle_key = 'f2',

    -- layout
    title    = 'MatchaUI',
    subtitle = '',
    x = 100, y = 80,
    w = 580, h = 460,
    _tab_h   = 32,
    _pad     = 8,

    -- inputs table  (same pattern as catowice lib)
    _inputs = {
        ['m1']={id=0x01,held=false,click=false},
        ['m2']={id=0x02,held=false,click=false},
        ['unbound']={id=0x08,held=false,click=false},
        ['tab']={id=0x09,held=false,click=false},
        ['enter']={id=0x0D,held=false,click=false},
        ['shift']={id=0x10,held=false,click=false},
        ['ctrl']={id=0x11,held=false,click=false},
        ['esc']={id=0x1B,held=false,click=false},
        ['space']={id=0x20,held=false,click=false},
        ['end']={id=0x23,held=false,click=false},
        ['home']={id=0x24,held=false,click=false},
        ['left']={id=0x25,held=false,click=false},
        ['up']={id=0x26,held=false,click=false},
        ['right']={id=0x27,held=false,click=false},
        ['down']={id=0x28,held=false,click=false},
        ['insert']={id=0x2D,held=false,click=false},
        ['delete']={id=0x2E,held=false,click=false},
        ['0']={id=0x30,held=false,click=false},['1']={id=0x31,held=false,click=false},
        ['2']={id=0x32,held=false,click=false},['3']={id=0x33,held=false,click=false},
        ['4']={id=0x34,held=false,click=false},['5']={id=0x35,held=false,click=false},
        ['6']={id=0x36,held=false,click=false},['7']={id=0x37,held=false,click=false},
        ['8']={id=0x38,held=false,click=false},['9']={id=0x39,held=false,click=false},
        ['a']={id=0x41,held=false,click=false},['b']={id=0x42,held=false,click=false},
        ['c']={id=0x43,held=false,click=false},['d']={id=0x44,held=false,click=false},
        ['e']={id=0x45,held=false,click=false},['f']={id=0x46,held=false,click=false},
        ['g']={id=0x47,held=false,click=false},['h']={id=0x48,held=false,click=false},
        ['i']={id=0x49,held=false,click=false},['j']={id=0x4A,held=false,click=false},
        ['k']={id=0x4B,held=false,click=false},['l']={id=0x4C,held=false,click=false},
        ['m']={id=0x4D,held=false,click=false},['n']={id=0x4E,held=false,click=false},
        ['o']={id=0x4F,held=false,click=false},['p']={id=0x50,held=false,click=false},
        ['q']={id=0x51,held=false,click=false},['r']={id=0x52,held=false,click=false},
        ['s']={id=0x53,held=false,click=false},['t']={id=0x54,held=false,click=false},
        ['u']={id=0x55,held=false,click=false},['v']={id=0x56,held=false,click=false},
        ['w']={id=0x57,held=false,click=false},['x']={id=0x58,held=false,click=false},
        ['y']={id=0x59,held=false,click=false},['z']={id=0x5A,held=false,click=false},
        ['f1']={id=0x70,held=false,click=false},['f2']={id=0x71,held=false,click=false},
        ['f3']={id=0x72,held=false,click=false},['f4']={id=0x73,held=false,click=false},
        ['f5']={id=0x74,held=false,click=false},['f6']={id=0x75,held=false,click=false},
        ['f7']={id=0x76,held=false,click=false},['f8']={id=0x77,held=false,click=false},
        ['f9']={id=0x78,held=false,click=false},['f10']={id=0x79,held=false,click=false},
        ['f11']={id=0x7A,held=false,click=false},['f12']={id=0x7B,held=false,click=false},
        ['lshift']={id=0xA0,held=false,click=false},['rshift']={id=0xA1,held=false,click=false},
        ['lctrl']={id=0xA2,held=false,click=false},['rctrl']={id=0xA3,held=false,click=false},
        ['minus']={id=0xBD,held=false,click=false},['period']={id=0xBE,held=false,click=false},
    },

    -- ── Colour Palette (Rayfield dark-blue aesthetic) ──────────────────────
    _c = {
        bg       = Color3.fromRGB(12,  13,  18 ),
        sidebar  = Color3.fromRGB(16,  17,  24 ),
        panel    = Color3.fromRGB(20,  21,  30 ),
        card     = Color3.fromRGB(26,  27,  38 ),
        cardHov  = Color3.fromRGB(32,  33,  47 ),
        border   = Color3.fromRGB(40,  42,  60 ),
        borderAc = Color3.fromRGB(0,   130, 200),
        acc      = Color3.fromRGB(0,   170, 255),
        accDim   = Color3.fromRGB(0,   90,  145),
        accDark  = Color3.fromRGB(0,   35,  60 ),
        accGlow  = Color3.fromRGB(130, 220, 255),
        txt      = Color3.fromRGB(220, 228, 242),
        txtDim   = Color3.fromRGB(115, 125, 158),
        txtMute  = Color3.fromRGB(60,  65,  95 ),
        black    = Color3.fromRGB(0,   0,   0  ),
        white    = Color3.fromRGB(255, 255, 255),
        green    = Color3.fromRGB(0,   210, 110),
        greenDk  = Color3.fromRGB(0,   55,  32 ),
        red      = Color3.fromRGB(235, 55,  70 ),
        redDk    = Color3.fromRGB(80,  14,  20 ),
        orange   = Color3.fromRGB(235, 135, 0  ),
        input    = Color3.fromRGB(10,  11,  17 ),
        dropBg   = Color3.fromRGB(14,  15,  22 ),
        dropHov  = Color3.fromRGB(0,   45,  70 ),
        notifBg  = Color3.fromRGB(16,  18,  28 ),
        tglOn    = Color3.fromRGB(0,   170, 255),
        tglOff   = Color3.fromRGB(40,  42,  62 ),
        sliderBg = Color3.fromRGB(22,  23,  34 ),
    },
}
MatchaUI.__index = MatchaUI

-- ── Helpers ────────────────────────────────────────────────────────────────
local function clamp(x,a,b) return x<a and a or x>b and b or x end

local function lerp(a,b,t) return a+(b-a)*t end

local function smooth(t)  -- smoothstep
    t = clamp(t,0,1)
    return t*t*(3-2*t)
end

function MatchaUI:_vp()
    return workspace.CurrentCamera.ViewportSize
end

function MatchaUI:_mouse()
    local p = game:GetService('Players').LocalPlayer
    local m = p and p:GetMouse()
    if m then return Vector2.new(m.X, m.Y) end
    return Vector2.new(0,0)
end

function MatchaUI:_inBounds(origin, size)
    local mp = self:_mouse()
    return mp.X >= origin.X and mp.X <= origin.X+size.X
       and mp.Y >= origin.Y and mp.Y <= origin.Y+size.Y
end

function MatchaUI:_pressed(key)   return self._inputs[key] and self._inputs[key].click end
function MatchaUI:_held(key)      return self._inputs[key] and self._inputs[key].held  end

function MatchaUI:_textW(text, size)
    size = size or 13
    return #text * size * 0.54
end

-- ── Raw draw helpers ────────────────────────────────────────────────────────
function MatchaUI:_D(id, dtype, col, zi, ...)
    local d = self._drawings[id]
    if not d then
        self._drawings[id] = Drawing.new(dtype)
        d = self._drawings[id]
    end

    local args = {...}
    if dtype == 'Square' then
        d.Position  = args[1]
        d.Size      = args[2]
        d.Filled    = args[3]
        d.Thickness = 1
    elseif dtype == 'Text' then
        d.Text    = tostring(args[1])
        d.Font    = self._font
        d.Size    = args[2] or 13
        d.Outline = false
        d.Center  = args[3] or false
        if args[3] then
            d.Position = args[4]
        else
            d.Position = args[4]
        end
    elseif dtype == 'Line' then
        d.From      = args[1]
        d.To        = args[2]
        d.Thickness = args[3] or 1
    elseif dtype == 'Circle' then
        d.Position  = args[1]
        d.Radius    = args[2]
        d.Filled    = true
        d.NumSides  = args[3] or 24
        d.Thickness = 1
    end

    if col then d.Color = col end
    d.ZIndex  = zi or 1
    d.Visible = true
    return d
end

-- shorthand wrappers
local function R(ui,id,x,y,w,h, col,zi, filled)
    return ui:_D(id,'Square',col,zi, Vector2.new(x,y), Vector2.new(w,h), filled~=false)
end
local function RO(ui,id,x,y,w,h, col,zi)
    return ui:_D(id,'Square',col,zi, Vector2.new(x,y), Vector2.new(w,h), false)
end
local function TX(ui,id,text,x,y, sz,col,zi, center)
    return ui:_D(id,'Text',col,zi, text, sz, center, Vector2.new(x,y))
end
local function LN(ui,id,x1,y1,x2,y2, col,thick,zi)
    return ui:_D(id,'Line',col,zi, Vector2.new(x1,y1), Vector2.new(x2,y2), thick)
end

function MatchaUI:_hide(id)
    local d = self._drawings[id]
    if d then d.Visible = false end
end

function MatchaUI:_hidePrefix(prefix)
    for k,d in pairs(self._drawings) do
        if k:sub(1,#prefix) == prefix then d.Visible = false end
    end
end

function MatchaUI:_remove(id)
    local d = self._drawings[id]
    if d then d:Remove(); self._drawings[id] = nil end
end

function MatchaUI:_removePrefix(prefix)
    for k,d in pairs(self._drawings) do
        if k:sub(1,#prefix) == prefix then d:Remove(); self._drawings[k]=nil end
    end
end

function MatchaUI:_alpha(id, a)
    local d = self._drawings[id]
    if d then d.Transparency = clamp(a,0,1) end
end

function MatchaUI:_alphaPrefix(prefix, a)
    for k,d in pairs(self._drawings) do
        if k:sub(1,#prefix) == prefix then d.Transparency = clamp(a,0,1) end
    end
end

-- ── Dropdown ───────────────────────────────────────────────────────────────
function MatchaUI:_openDropdown(pos, width, value, choices, multi, cb)
    self:_closeDropdown()
    self._active_dropdown = {
        pos=pos, w=width, value=value, choices=choices,
        multi=multi, cb=cb, born=os.clock()
    }
end

function MatchaUI:_closeDropdown()
    self._active_dropdown = nil
    self:_hidePrefix('mdd_')
end

-- ── Public API ─────────────────────────────────────────────────────────────
function MatchaUI:Init(cfg)
    cfg = cfg or {}
    self.title       = cfg.Title    or 'MatchaUI'
    self.subtitle    = cfg.Subtitle or ''
    self._toggle_key = cfg.ToggleKey or 'f2'

    local vp = self:_vp()
    self.x = math.floor(vp.X/2 - self.w/2)
    self.y = math.floor(vp.Y/2 - self.h/2)
    return self
end

function MatchaUI:Notify(text, duration)
    duration = duration or 3
    table.insert(self._notifications, {
        text=text, dur=duration,
        born=os.clock(), id=self._notif_count
    })
    self._notif_count = self._notif_count + 1
end

function MatchaUI:Unload()
    self:_removePrefix('')
    setrobloxinput(true)
end

-- ── Tab / Section builders ─────────────────────────────────────────────────
function MatchaUI:Tab(name)
    self._tree[name] = { _sections = {} }
    if not self._open_tab then self._open_tab = name end

    local ui = self
    return {
        Section = function(_, sname)
            ui._tree[name]._sections[sname] = { _items = {} }
            local sec = {}

            local function addItem(t)
                table.insert(ui._tree[name]._sections[sname]._items, t)
                local idx = #ui._tree[name]._sections[sname]._items

                local obj = {}
                function obj:Set(v)
                    ui._tree[name]._sections[sname]._items[idx].value = v
                    local cb = ui._tree[name]._sections[sname]._items[idx].cb
                    if cb then pcall(cb, v) end
                end
                function obj:UpdateChoices(c)
                    ui._tree[name]._sections[sname]._items[idx].choices = c
                end
                return obj
            end

            function sec:Toggle(label, default, cb)
                return addItem({type='toggle',label=label,value=default or false,cb=cb})
            end
            function sec:Slider(label, default, step, min, max, suffix, cb)
                return addItem({type='slider',label=label,value=default or min or 0,
                    step=step or 1,min=min or 0,max=max or 100,suffix=suffix or '',cb=cb})
            end
            function sec:Dropdown(label, value, choices, multi, cb)
                -- value should be a table for consistency with catowice pattern
                local v = type(value)=='table' and value or {value}
                return addItem({type='dropdown',label=label,value=v,choices=choices or {},multi=multi,cb=cb})
            end
            function sec:Button(label, cb)
                return addItem({type='button',label=label,cb=cb})
            end
            function sec:Textbox(label, default, cb)
                return addItem({type='textbox',label=label,value=default or '',cb=cb})
            end
            function sec:Keybind(label, default, cb)
                return addItem({type='keybind',label=label,value=default or nil,
                    _listening=false,_listen_start=0,cb=cb})
            end
            function sec:Label(text)
                return addItem({type='label',label=text})
            end
            function sec:Divider()
                return addItem({type='divider'})
            end

            return sec
        end
    }
end

-- ── Step (call every frame) ────────────────────────────────────────────────
function MatchaUI:Step()
    local C = self._c

    -- ── input processing (identical to catowice pattern) ──
    setrobloxinput(not self._menu_open)
    for key, data in pairs(self._inputs) do
        local held = isrbxactive() and iskeypressed(data.id)
        if held then
            self._inputs[key].click = not data.held
            self._inputs[key].held  = true
        else
            self._inputs[key].click = false
            self._inputs[key].held  = false
        end
    end

    local clickF  = self:_pressed('m1')
    local heldM1  = self:_held('m1')
    local ctxF    = self:_pressed('m2')
    local mp      = self:_mouse()

    -- toggle menu
    if self:_pressed(self._toggle_key) then
        self._menu_open = not self._menu_open
        self._menu_toggled_at = os.clock()
        if not self._menu_open then
            self:_closeDropdown()
        end
    end

    -- ── notifications ──────────────────────────────────────────────────────
    local vp = self:_vp()
    local nw, nh = 280, 54
    local nx0 = vp.X - nw - 12
    local totalNH = 0

    for i=#self._notifications,1,-1 do
        local n = self._notifications[i]
        local age    = os.clock() - n.born
        local fadeIn = smooth(math.min(age/0.2, 1))
        local shouldFade = age > n.dur
        local fadeOut = shouldFade and smooth(math.max(0,1-(age-n.dur)/0.3)) or 1
        local fade = fadeIn * fadeOut

        local ny = vp.Y - nh - 12 - totalNH
        local nx = nx0 + nw*(1-fade)

        local pid = 'notif_'..n.id..'_'
        R(self,pid..'sh', nx+3, ny+3, nw, nh, C.black, 44)
        R(self,pid..'bg', nx,   ny,   nw, nh, C.notifBg, 45)
        RO(self,pid..'bd',nx,   ny,   nw, nh, C.acc,   46)
        R(self,pid..'el', nx,   ny,   3,  nh, C.acc,   47)
        R(self,pid..'et', nx,   ny,   nw, 1,  C.acc,   47)
        TX(self,pid..'tx', n.text, nx+14, ny+nh/2-7, 13, C.txt, 48)

        -- progress bar
        local pct = clamp(1 - (age/n.dur), 0, 1)
        R(self,pid..'pbg', nx+3, ny+nh-4, nw-6, 2, C.border, 48)
        if pct > 0 then
            R(self,pid..'pfl', nx+3, ny+nh-4, math.max(2,(nw-6)*pct), 2, C.acc, 49)
        end

        self:_alphaPrefix(pid, fade)
        totalNH = totalNH + (nh+6)*fade

        if age > n.dur + 0.35 then
            self:_removePrefix(pid)
            table.remove(self._notifications, i)
        end
    end

    if not self._menu_open then
        -- fade out menu drawings
        local mf = smooth(clamp(1-(os.clock()-self._menu_toggled_at)/0.2,0,1))
        self:_alphaPrefix('mu_', mf)
        if mf <= 0 then self:_hidePrefix('mu_') end
        return
    end

    -- ── menu fade in ──
    local menuFade = smooth(clamp((os.clock()-self._menu_toggled_at)/0.2,0,1))
    self:_alphaPrefix('mu_', menuFade)

    -- ── drag ──
    if heldM1 and self._menu_drag then
        self.x = mp.X - self._menu_drag.X
        self.y = mp.Y - self._menu_drag.Y
    elseif not heldM1 then
        self._menu_drag = nil
    end

    -- layout vars
    local mx, my = self.x, self.y
    local mw, mh = self.w, self.h
    local pad     = self._pad
    local sideW   = 115
    local topH    = 50
    local contX   = mx + sideW
    local contY   = my + topH
    local contW   = mw - sideW
    local contH   = mh - topH

    -- ── Window shell ──
    R(self,'mu_sh',  mx+4, my+4, mw,   mh,   C.black,  1)
    R(self,'mu_bg',  mx,   my,   mw,   mh,   C.bg,     2)
    RO(self,'mu_bd', mx,   my,   mw,   mh,   C.border, 3)
    R(self,'mu_acel',mx,   my,   2,    mh,   C.acc,    4)  -- left accent strip
    R(self,'mu_acet',mx,   my,   mw,   1,    C.acc,    4)  -- top accent strip

    -- ── Topbar ──
    R(self,'mu_tbarbg', mx, my, mw, topH, C.sidebar, 3)
    R(self,'mu_tbarsep',mx, my+topH-1, mw, 1, C.acc, 4)
    TX(self,'mu_title',   self.title,    mx+16, my+10, 15, C.txt,    5)
    TX(self,'mu_subtitle',self.subtitle, mx+16, my+28, 11, C.txtDim, 5)
    TX(self,'mu_thint', self._toggle_key:upper()..' to toggle',
        mx+mw-100, my+20, 11, C.txtMute, 5)

    -- close btn
    R(self,'mu_closebg',  mx+mw-26, my+13, 14, 14, C.redDk, 5)
    RO(self,'mu_closebd', mx+mw-26, my+13, 14, 14, C.red,   6)
    TX(self,'mu_closetx', 'X', mx+mw-19, my+16, 11, C.red, 7, true)
    if clickF and self:_inBounds(Vector2.new(mx+mw-26,my+13), Vector2.new(14,14)) then
        self._menu_open = false
        self._menu_toggled_at = os.clock()
        clickF = false
    end

    -- drag zone (topbar, excluding close btn)
    if clickF and self:_inBounds(Vector2.new(mx,my), Vector2.new(mw-32,topH)) then
        self._menu_drag = Vector2.new(mp.X-mx, mp.Y-my)
        clickF = false
    end

    -- ── Sidebar ──
    R(self,'mu_sidebg',  mx, contY, sideW, contH, C.sidebar, 3)
    R(self,'mu_sidesep', mx+sideW-1, contY, 1, contH, C.border, 4)

    local tabIdx = 0
    for tabName, _ in pairs(self._tree) do
        local ty   = contY + tabIdx * self._tab_h
        local isA  = self._open_tab == tabName
        local pid  = 'mu_tab_'..tabIdx..'_'

        R(self,pid..'bg',  mx,   ty, sideW, self._tab_h, isA and C.accDark or C.sidebar, 4)
        R(self,pid..'pip', mx,   ty, 3, self._tab_h, isA and C.acc or C.border, 5)
        R(self,pid..'sep', mx,   ty+self._tab_h-1, sideW, 1, C.border, 4)
        TX(self,pid..'lb', tabName, mx+16, ty + math.floor((self._tab_h-13)/2), 13, isA and C.acc or C.txtDim, 5)

        if not isA and clickF and self:_inBounds(Vector2.new(mx,ty), Vector2.new(sideW,self._tab_h)) then
            self._open_tab = tabName
            self._tab_change_at = os.clock()
            self:_closeDropdown()
            self._input_ctx = nil
            clickF = false
        end

        tabIdx = tabIdx + 1
    end

    -- ── Content area ──
    R(self,'mu_ctbg', contX, contY, contW, contH, C.panel, 3)

    -- tab content fade
    local tabFade = smooth(clamp((os.clock()-self._tab_change_at)/0.15,0,1))
    self:_alphaPrefix('mu_sec_', tabFade)

    local tabData = self._tree[self._open_tab]
    if not tabData then goto _dropdownStep end

    do
        -- two-column layout for sections
        local secIdx  = 0
        local secCount = 0
        for _ in pairs(tabData._sections) do secCount=secCount+1 end

        local colW   = math.floor((contW - pad*3) / 2)
        local colLX  = contX + pad
        local colRX  = contX + pad + colW + pad
        local colLY  = contY + self._tab_h + pad
        local colRY  = contY + self._tab_h + pad

        for secName, secData in pairs(tabData._sections) do
            local isRight = secIdx % 2 == 1
            local sx = isRight and colRX or colLX
            local sy = isRight and colRY or colLY
            local sw = colW
            local pid = 'mu_sec_'..secIdx..'_'

            -- measure section height
            local sH = pad + 18 -- title
            for _, item in ipairs(secData._items) do
                if item.type == 'toggle'   then sH = sH + 13 + pad
                elseif item.type == 'slider'   then sH = sH + 13 + 6 + pad*2 + 6
                elseif item.type == 'dropdown' then sH = sH + 13 + 13 + pad*2 + 2
                elseif item.type == 'button'   then sH = sH + 13 + pad*2
                elseif item.type == 'textbox'  then sH = sH + 13 + pad
                elseif item.type == 'keybind'  then sH = sH + 13 + pad
                elseif item.type == 'label'    then sH = sH + 13 + 4
                elseif item.type == 'divider'  then sH = sH + 8
                end
            end
            sH = sH + pad

            -- draw section card
            R(self,pid..'bg',  sx,   sy, sw, sH, C.card,   5)
            RO(self,pid..'bd', sx,   sy, sw, sH, C.border, 6)
            -- section title
            TX(self,pid..'ttl', secName:upper(), sx+pad, sy+pad, 10, C.acc, 7)
            LN(self,pid..'tln', sx+pad + self:_textW(secName:upper(),10)+4,
                sy+pad+7, sx+sw-pad, sy+pad+7, C.accDim, 1, 6)

            -- items
            local iy = sy + pad + 18
            for itemIdx, item in ipairs(secData._items) do
                local iid = pid..'i_'..itemIdx..'_'
                local iW  = sw - pad*2

                -- ── Divider ──
                if item.type == 'divider' then
                    LN(self,iid..'ln', sx+pad, iy+4, sx+sw-pad, iy+4, C.border, 1, 7)
                    iy = iy + 8

                -- ── Label ──
                elseif item.type == 'label' then
                    TX(self,iid..'tx', item.label, sx+pad, iy, 12, C.txtDim, 7)
                    iy = iy + 13 + 4

                -- ── Toggle ──
                elseif item.type == 'toggle' then
                    local on   = item.value
                    local hov  = self:_inBounds(Vector2.new(sx+pad,iy), Vector2.new(iW,13))
                    local lblC = on and C.txt or C.txtDim
                    if hov then lblC = C.txt end

                    -- toggle pill  (right side)
                    local pillW,pillH = 32,14
                    local pillX = sx+sw-pad-pillW
                    local pillY = iy
                    R(self,iid..'pbg',  pillX, pillY, pillW, pillH, on and C.tglOn or C.tglOff, 8)
                    RO(self,iid..'pbd', pillX, pillY, pillW, pillH, on and C.acc or C.border, 9)
                    local knobX = on and (pillX+pillW-13) or (pillX+1)
                    R(self,iid..'knob', knobX, pillY+1, 12, 12, on and C.white or C.txtMute, 10)
                    TX(self,iid..'ptx', on and 'ON' or 'OFF',
                        pillX+pillW/2, pillY+2, 9, on and C.white or C.txtMute, 10, true)

                    TX(self,iid..'lbl', item.label, sx+pad, iy, 13, lblC, 7)

                    if hov and clickF then
                        item.value = not item.value
                        pcall(item.cb, item.value)
                        clickF = false
                    end
                    iy = iy + 13 + pad

                -- ── Slider ──
                elseif item.type == 'slider' then
                    local slH   = 6
                    local slX   = sx + pad
                    local slY   = iy + 13 + pad
                    local slW   = iW
                    local pct   = clamp((item.value-item.min)/(item.max-item.min),0,1)
                    local fillW = math.max(3, math.floor(pct*slW))

                    TX(self,iid..'lbl', item.label, sx+pad, iy, 13, C.txt, 7)
                    local valTx = tostring(math.floor(item.value))..item.suffix
                    TX(self,iid..'val', valTx, sx+sw-pad, iy, 12, C.accGlow, 7)

                    R(self,iid..'trk',  slX, slY, slW, slH, C.sliderBg, 8)
                    R(self,iid..'fl',   slX, slY, fillW, slH, C.acc, 9)
                    RO(self,iid..'trd', slX, slY, slW, slH, C.border, 8)
                    -- thumb circle
                    self:_D(iid..'th','Circle',C.accGlow,10,
                        Vector2.new(slX+fillW, slY+slH/2), 5, 20)

                    -- drag
                    local hov = self:_inBounds(Vector2.new(slX,slY-5), Vector2.new(slW,slH+10))
                    if hov and clickF then
                        self._slider_drag = iid
                        clickF = false
                    end
                    if heldM1 and self._slider_drag == iid then
                        local rx  = clamp(mp.X - slX, 0, slW)
                        local pct2 = rx / slW
                        local raw = item.min + pct2*(item.max-item.min)
                        local stepped = math.floor(raw/item.step+0.5)*item.step
                        item.value = clamp(stepped, item.min, item.max)
                        pcall(item.cb, item.value)
                    elseif not heldM1 and self._slider_drag == iid then
                        self._slider_drag = nil
                    end

                    iy = iy + 13 + slH + pad*2 + 6

                -- ── Dropdown ──
                elseif item.type == 'dropdown' then
                    local ddH  = 13 + pad
                    local ddX  = sx+pad
                    local ddY  = iy + 13 + pad
                    local ddW  = iW
                    local isOpen = self._active_dropdown ~= nil
                        and self._active_dropdown._ownerId == iid

                    local displayV = table.concat(item.value, ', ')
                    if self:_textW(displayV,13) > ddW-16 then
                        displayV = tostring(#item.value)..' item'..(#item.value==1 and '' or 's')
                    end

                    TX(self,iid..'lbl', item.label, sx+pad, iy, 13, C.txt, 7)
                    R(self,iid..'dbg',  ddX, ddY, ddW, ddH, C.input, 8)
                    RO(self,iid..'dbd', ddX, ddY, ddW, ddH, isOpen and C.acc or C.border, 9)
                    TX(self,iid..'dtx', displayV, ddX+6, ddY+3, 12, isOpen and C.accGlow or C.txtDim, 9)
                    TX(self,iid..'dar', 'v', ddX+ddW-12, ddY+3, 11, C.txtMute, 9)

                    if clickF and self:_inBounds(Vector2.new(ddX,ddY), Vector2.new(ddW,ddH)) then
                        if isOpen then
                            self:_closeDropdown()
                        else
                            self:_openDropdown(
                                Vector2.new(ddX, ddY+ddH),
                                ddW,
                                item.value,
                                item.choices,
                                item.multi,
                                function(newVal)
                                    item.value = newVal
                                    pcall(item.cb, newVal)
                                end
                            )
                            self._active_dropdown._ownerId = iid
                        end
                        clickF = false
                    end

                    iy = iy + 13 + ddH + pad*2 + 2

                -- ── Button ──
                elseif item.type == 'button' then
                    local bH  = 13 + pad
                    local bX  = sx+pad
                    local bY  = iy
                    local bW  = iW
                    local hov = self:_inBounds(Vector2.new(bX,bY), Vector2.new(bW,bH))
                    local act = heldM1 and self._slider_drag == iid

                    R(self,iid..'bg',  bX, bY, bW, bH, act and C.accDark or (hov and C.cardHov or C.card), 8)
                    RO(self,iid..'bd', bX, bY, bW, bH, hov and C.acc or C.border, 9)
                    if hov then
                        R(self,iid..'el',bX,bY,2,bH, C.acc, 10)
                    else
                        self:_hide(iid..'el')
                    end
                    TX(self,iid..'tx', item.label, bX+bW/2, bY+3, 13, C.txt, 9, true)

                    if hov and clickF then
                        self._slider_drag = iid
                        clickF = false
                        pcall(item.cb)
                    end
                    if not heldM1 then self._slider_drag = nil end

                    iy = iy + bH + pad*2

                -- ── Textbox ──
                elseif item.type == 'textbox' then
                    local tbH  = 13 + pad
                    local tbX  = sx+pad
                    local tbY  = iy
                    local tbW  = iW
                    local isTyping = self._input_ctx == iid

                    local cursor = math.floor(os.clock()*2)%2==0 and '|' or ' '
                    local disp = isTyping and ((item.value or '')..cursor)
                        or (item.value ~= '' and item.value or item.label..' ')
                    local dispC = (isTyping or (item.value and item.value~=''))
                        and C.txt or C.txtDim

                    R(self,iid..'bg',  tbX, tbY, tbW, tbH, C.input, 8)
                    RO(self,iid..'bd', tbX, tbY, tbW, tbH, isTyping and C.acc or C.border, 9)
                    TX(self,iid..'tx', disp, tbX+5, tbY+3, 12, dispC, 9)

                    if self:_pressed('m1') then
                        if self:_inBounds(Vector2.new(tbX,tbY), Vector2.new(tbW,tbH)) then
                            self._input_ctx = iid
                            clickF = false
                        elseif isTyping then
                            self._input_ctx = nil
                        end
                    end

                    if isTyping then
                        local shiftHeld = self:_held('lshift') or self:_held('rshift')
                        local charMap = {space=' ',minus='-',period='.'}
                        for char,_ in pairs(self._inputs) do
                            if self:_pressed(char) then
                                local mapped = charMap[char] or char
                                if mapped == 'enter' then
                                    self._input_ctx = nil
                                    pcall(item.cb, item.value)
                                elseif mapped == 'unbound' then
                                    item.value = (item.value or ''):sub(1,-2)
                                elseif #mapped == 1 then
                                    item.value = (item.value or '')
                                        .. (shiftHeld and mapped:upper() or mapped)
                                end
                            end
                        end
                    end

                    iy = iy + tbH + pad

                -- ── Keybind ──
                elseif item.type == 'keybind' then
                    local kbName = item.value and item.value:upper() or 'NONE'
                    local kbW2 = math.max(40, self:_textW('['..kbName..']',11)+10)
                    local kbX  = sx+sw-pad-kbW2
                    local kbY  = iy
                    local kbH  = 13

                    TX(self,iid..'lbl', item.label, sx+pad, iy, 13, C.txt, 7)

                    if item._listening then
                        R(self,iid..'kbg',  kbX,kbY,kbW2,kbH, C.redDk,  8)
                        RO(self,iid..'kbd', kbX,kbY,kbW2,kbH, C.red,    9)
                        TX(self,iid..'ktx','[...]',kbX+kbW2/2,kbY+1,10,C.red,10,true)

                        for keyName,_ in pairs(self._inputs) do
                            if self:_pressed(keyName) then
                                if keyName ~= 'm1' or os.clock()-item._listen_start > 0.2 then
                                    if keyName == 'esc' then
                                        item.value = nil
                                    else
                                        item.value = keyName ~= 'unbound' and keyName or nil
                                    end
                                    item._listening = false
                                    pcall(item.cb, item.value)
                                end
                            end
                        end
                    else
                        R(self,iid..'kbg',  kbX,kbY,kbW2,kbH, C.accDark, 8)
                        RO(self,iid..'kbd', kbX,kbY,kbW2,kbH, C.acc,     9)
                        TX(self,iid..'ktx','['..kbName..']',
                            kbX+kbW2/2,kbY+1,10,C.accGlow,10,true)

                        if clickF and self:_inBounds(Vector2.new(kbX,kbY), Vector2.new(kbW2,kbH)) then
                            item._listening = true
                            item._listen_start = os.clock()
                            clickF = false
                        end
                    end

                    iy = iy + kbH + pad
                end
            end

            if isRight then
                colRY = colRY + sH + pad
            else
                colLY = colLY + sH + pad
            end

            secIdx = secIdx + 1
        end
    end

    ::_dropdownStep::

    -- ── Dropdown overlay ──
    local dd = self._active_dropdown
    if dd then
        local fade2 = smooth(clamp((os.clock()-dd.born)/0.15,0,1))
        local itemH = 13 + self._pad
        local ddH2  = #dd.choices * itemH + self._pad
        local dx,dy = dd.pos.X, dd.pos.Y
        local dw    = dd.w

        R(self,'mdd_sh',  dx+3, dy+3, dw, ddH2, C.black,  50)
        R(self,'mdd_bg',  dx,   dy,   dw, ddH2, C.dropBg, 51)
        RO(self,'mdd_bd', dx,   dy,   dw, ddH2, C.acc,    52)
        R(self,'mdd_tl',  dx,   dy,   dw, 1,    C.acc,    53)

        local cancelDrop = true
        for ci, choice in ipairs(dd.choices) do
            local cy2   = dy + self._pad + (ci-1)*itemH
            local found = table.find(dd.value, choice)
            local hov2  = self:_inBounds(Vector2.new(dx+2,cy2), Vector2.new(dw-4,itemH))

            if found then
                R(self,'mdd_selbg'..ci, dx+1, cy2, dw-2, itemH-1, C.accDark, 53)
                LN(self,'mdd_selln'..ci, dx+1,cy2,dx+1,cy2+itemH-2, C.acc,2,54)
            elseif hov2 then
                R(self,'mdd_hovbg'..ci, dx+1, cy2, dw-2, itemH-1, C.dropHov, 53)
            end

            TX(self,'mdd_txt'..ci, choice, dx+8, cy2+2, 13, found and C.accGlow or (hov2 and C.txt or C.txtDim), 54)

            if hov2 and clickF then
                cancelDrop = not dd.multi
                if dd.multi then
                    if found then
                        table.remove(dd.value, found)
                    else
                        table.insert(dd.value, choice)
                    end
                else
                    dd.value = {choice}
                end
                pcall(dd.cb, dd.value)
                clickF = false
            end
        end

        self:_alphaPrefix('mdd_', fade2)

        if clickF and cancelDrop then
            self:_closeDropdown()
        end

        -- don't let clicks through to menu when dropdown open
        if self:_inBounds(Vector2.new(dx,dy), Vector2.new(dw,ddH2)) then
            clickF = false
        end
    end
end

return MatchaUI
