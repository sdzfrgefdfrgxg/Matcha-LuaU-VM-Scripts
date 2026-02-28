local Players = game:GetService("Players")
local UIS     = game:GetService("UserInputService")
local player  = Players.LocalPlayer
local mouse   = player:GetMouse()
local VP      = workspace.CurrentCamera.ViewportSize

-- ── Palette ───────────────────────────────────────────────────────────────────
local C = {
    bg         = Color3.fromRGB(10,  12,  20),
    bgPanel    = Color3.fromRGB(14,  16,  26),
    sidebar    = Color3.fromRGB(12,  14,  22),
    card       = Color3.fromRGB(18,  20,  32),
    cardHov    = Color3.fromRGB(22,  25,  40),
    acc        = Color3.fromRGB(0,   200, 255),
    accDim     = Color3.fromRGB(0,   110, 145),
    accGlow    = Color3.fromRGB(100, 230, 255),
    accDark    = Color3.fromRGB(0,   45,  65),
    bord       = Color3.fromRGB(30,  35,  55),
    bordAcc    = Color3.fromRGB(0,   140, 180),
    txt        = Color3.fromRGB(210, 220, 235),
    txtDim     = Color3.fromRGB(110, 125, 155),
    txtMuted   = Color3.fromRGB(60,  70,  100),
    dropBg     = Color3.fromRGB(8,   10,  18),
    dropHov    = Color3.fromRGB(0,   55,  75),
    black      = Color3.fromRGB(0,   0,   0),
    white      = Color3.fromRGB(255, 255, 255),
    green      = Color3.fromRGB(0,   180, 100),
    greenDk    = Color3.fromRGB(0,   70,  40),
    red        = Color3.fromRGB(220, 50,  70),
    redDk      = Color3.fromRGB(90,  15,  25),
    orange     = Color3.fromRGB(220, 130, 0),
    orangeDk   = Color3.fromRGB(75,  40,  0),
    input      = Color3.fromRGB(8,   10,  18),
    notifBg    = Color3.fromRGB(12,  14,  24),
    toggle_on  = Color3.fromRGB(0,   200, 255),
    toggle_off = Color3.fromRGB(40,  44,  68),
    slider     = Color3.fromRGB(22,  24,  38),
}

-- ── Drawing pool ──────────────────────────────────────────────────────────────
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
local function uid(p) _uid=_uid+1; return (p or "o")..tostring(_uid) end

-- ── Draw helpers ──────────────────────────────────────────────────────────────
local function sq(key,x,y,w,h,col,zi)
    local d=getObj(key,"Square")
    d.Position=Vector2.new(x,y); d.Size=Vector2.new(w,h)
    d.Color=col; d.Filled=true; d.Thickness=1; d.ZIndex=zi or 1; d.Visible=true
end
local function sqo(key,x,y,w,h,col,zi)
    local d=getObj(key,"Square")
    d.Position=Vector2.new(x,y); d.Size=Vector2.new(w,h)
    d.Color=col; d.Filled=false; d.Thickness=1; d.ZIndex=zi or 1; d.Visible=true
end
local function tx(key,text,x,y,sz,col,zi,center)
    local d=getObj(key,"Text")
    d.Text=tostring(text); d.Position=Vector2.new(x,y); d.Size=sz or 13
    d.Color=col or C.txt; d.Font=Drawing.Fonts.UI; d.Outline=false
    d.Center=(center==true); d.ZIndex=zi or 2; d.Visible=true
end
local function ln(key,x1,y1,x2,y2,col,thick,zi)
    local d=getObj(key,"Line")
    d.From=Vector2.new(x1,y1); d.To=Vector2.new(x2,y2)
    d.Color=col; d.Thickness=thick or 1; d.ZIndex=zi or 1; d.Visible=true
end
local function hit(mx,my,x,y,w,h)
    return mx>=x and mx<=x+w and my>=y and my<=y+h
end

-- ── VK tables ─────────────────────────────────────────────────────────────────
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
    {0xBC,"Comma"},{0xBE,"Period"},{0xBF,"Slash"},
    {0x20,"Space"},{0x09,"Tab"},{0x14,"CapsLock"},
    {0x10,"Shift"},{0x11,"Ctrl"},{0x12,"Alt"},
}
local STR_TO_VK, VK_TO_NAME = {}, {}
for _,e in ipairs(VK_SCAN) do
    STR_TO_VK[e[2]]=e[1]; STR_TO_VK[e[2]:lower()]=e[1]; VK_TO_NAME[e[1]]=e[2]
end

local KEYMAP = {}
do
    for _,c in ipairs({"A","B","C","D","E","F","G","H","I","J","K","L","M",
                        "N","O","P","Q","R","S","T","U","V","W","X","Y","Z"}) do
        pcall(function() KEYMAP[Enum.KeyCode[c]]=c:lower() end)
    end
    local ns={"Zero","One","Two","Three","Four","Five","Six","Seven","Eight","Nine"}
    for i,n in ipairs(ns) do pcall(function() KEYMAP[Enum.KeyCode[n]]=tostring(i-1) end) end
    pcall(function() KEYMAP[Enum.KeyCode.Period]="." end)
    pcall(function() KEYMAP[Enum.KeyCode.Space] =" " end)
end

local prevVK={}
local function vkEdge(vk)
    local now=iskeypressed(vk); local prev=prevVK[vk] or false
    prevVK[vk]=now; return now and not prev
end

-- ── Layout constants ──────────────────────────────────────────────────────────
local WW          = 600
local WH          = 500
local SIDEBAR     = 115
local TOPBAR      = 40
local CONTENT_PAD = 10
local TAB_H       = 38
local ELEM_GAP    = 5
local NOTIF_W     = 300
local NOTIF_H     = 48

-- Per-element heights
-- Dropdown & Textbox have a name row + widget row stacked = taller card
local EH = {
    section  = 22,
    divider  = 12,
    label    = 22,
    button   = 34,
    toggle   = 34,
    slider   = 52,
    dropdown = 52,
    textbox  = 52,
    keybind  = 34,
}
local function elemH(el) return EH[el.type] or 34 end

-- ── Library ───────────────────────────────────────────────────────────────────
local MatchaUI = {}
MatchaUI.__index = MatchaUI

-- ── Init ──────────────────────────────────────────────────────────────────────
function MatchaUI:Init(cfg)
    local win = setmetatable({}, MatchaUI)
    win.Name     = cfg.Title    or "MatchaUI"
    win.Subtitle = cfg.Subtitle or ""
    win.Visible  = true

    local tk = cfg.ToggleKey
    if type(tk)=="string" then
        win.ToggleKey     = STR_TO_VK[tk:upper()] or STR_TO_VK[tk] or 0x71
        win.ToggleKeyName = tk:upper()
    else
        win.ToggleKey     = tk or 0x71
        win.ToggleKeyName = VK_TO_NAME[win.ToggleKey] or "F2"
    end

    VP = workspace.CurrentCamera.ViewportSize
    win.WX = math.floor((VP.X-WW)/2)
    win.WY = math.floor((VP.Y-WH)/2)

    win.dragOn=false; win.dragOX=0; win.dragOY=0
    win.tabs={}; win.activeTab=1
    win.zones={}; win.ddZones={}

    -- Dropdown
    win.DD                   = nil
    win.ddScrollDragging     = false
    win.ddScrollDragStartY   = 0
    win.ddScrollDragStartOff = 0

    win.notifs     = {}
    win._destroyed = false
    win:_startLoop()
    return win
end

-- ── Notify ────────────────────────────────────────────────────────────────────
function MatchaUI:Notify(a, b)
    local content, duration
    if type(a)=="table" then
        content=a.Content or a.Title or ""; duration=a.Duration or 3
    else
        content=tostring(a); duration=(type(b)=="number") and b or 3
    end
    -- Replace the current notification (single-bar style like original)
    -- but keep a queue so rapid notifications don't vanish instantly
    table.insert(self.notifs, {
        content=content, duration=duration,
        expires=tick()+duration, id=uid("nf"), enterT=tick(),
    })
end

function MatchaUI:Step() end  -- no-op

function MatchaUI:Destroy()
    self._destroyed=true
    for _,d in pairs(pool) do pcall(function() d.Visible=false end) end
end

-- ── Zone helpers ──────────────────────────────────────────────────────────────
function MatchaUI:_addZone(x,y,w,h,fn)   table.insert(self.zones,  {x=x,y=y,w=w,h=h,fn=fn}) end
function MatchaUI:_addDDZone(x,y,w,h,fn) table.insert(self.ddZones,{x=x,y=y,w=w,h=h,fn=fn}) end

-- ── Tab ───────────────────────────────────────────────────────────────────────
function MatchaUI:Tab(name)
    local tab={name=name, elements={}, scroll=0}
    table.insert(self.tabs, tab)

    function tab:Section(sname)
        table.insert(self.elements,{type="section",name=sname,id=uid("sec")})
        local sec={}
        local function add(el) table.insert(tab.elements,el); return el end

        function sec:Button(name_, cb)
            add({type="button",name=name_,callback=cb or function()end,id=uid("btn")})
        end

        function sec:Toggle(name_, default_, cb)
            local el={type="toggle",name=name_,value=default_ or false,
                      callback=cb or function()end,id=uid("tgl")}
            add(el)
            local obj={el=el}
            function obj:Set(v) el.value=v; pcall(el.callback,v) end
            return obj
        end

        function sec:Slider(name_, min_, max_, default_, cb)
            local el={type="slider",name=name_,min=min_ or 0,max=max_ or 100,
                      value=default_ or 0,suffix="",dragging=false,
                      callback=cb or function()end,id=uid("sld")}
            add(el)
            local obj={el=el}
            function obj:Set(v) el.value=math.clamp(v,el.min,el.max); pcall(el.callback,el.value) end
            return obj
        end

        -- sec:Dropdown(name, {default}, {options}, multi, cb)
        function sec:Dropdown(name_, defaults_, options_, _multi, cb)
            local defVal=type(defaults_)=="table" and defaults_[1] or (defaults_ or "")
            local el={type="dropdown",name=name_,
                      options=options_ or {},value=defVal,
                      callback=cb or function()end,id=uid("dd")}
            add(el)
            local obj={el=el}
            function obj:Set(v) el.value=v; pcall(el.callback,{v}) end
            function obj:Refresh(opts,newDef)
                el.options=opts; el.value=newDef or (opts and opts[1]) or ""
            end
            return obj
        end

        function sec:Textbox(name_, default_, cb)
            local el={type="textbox",name=name_,placeholder="Type here...",
                      value=default_ or "",active=false,
                      callback=cb or function()end,id=uid("tbx")}
            add(el)
            UIS.InputBegan:Connect(function(input)
                if not el.active then return end
                local kc=input.KeyCode; if not kc then return end
                if kc==Enum.KeyCode.BackSpace then
                    el.value=el.value:sub(1,-2)
                elseif kc==Enum.KeyCode.Return or kc==Enum.KeyCode.KeypadEnter then
                    el.active=false; pcall(el.callback,el.value)
                elseif kc==Enum.KeyCode.Escape then
                    el.active=false
                else
                    local ch=KEYMAP[kc]
                    if ch then
                        local shift=iskeypressed(0xA0) or iskeypressed(0xA1)
                        el.value=el.value..(shift and ch:upper() or ch)
                    end
                end
            end)
            local obj={el=el}
            function obj:Get() return el.value end
            function obj:Set(v) el.value=v end
            return obj
        end

        function sec:Keybind(name_, defaultKey_, cb)
            local vk=type(defaultKey_)=="string"
                and (STR_TO_VK[defaultKey_:upper()] or STR_TO_VK[defaultKey_] or 0x70)
                or (defaultKey_ or 0x70)
            local el={type="keybind",name=name_,vk=vk,
                      vkName=VK_TO_NAME[vk] or tostring(defaultKey_):upper(),
                      listening=false,callback=cb or function()end,id=uid("kb")}
            add(el)
            local obj={el=el}
            function obj:Set(vk_,nm_) el.vk=vk_; el.vkName=nm_ or "?" end
            return obj
        end

        function sec:Label(text_) add({type="label",text=text_,id=uid("lbl")}) end
        function sec:Divider()   add({type="divider",id=uid("div")}) end

        return sec
    end

    return tab
end

-- ── Render element ────────────────────────────────────────────────────────────
function MatchaUI:_renderElement(el, ex, ey, ew, mx, my, zi)
    local p = el.id.."_"
    local eH = elemH(el)

    if el.type=="section" then
        tx(p.."lbl", el.name:upper(), ex, ey+4, 10, C.acc, zi+1)
        local lx=ex+math.min(#el.name*6+6, ew-4)
        ln(p.."ln", lx, ey+9, ex+ew, ey+9, C.accDim, 1, zi)
        return
    end
    if el.type=="divider" then
        ln(p.."ln", ex, ey+6, ex+ew, ey+6, C.bord, 1, zi); return
    end
    if el.type=="label" then
        tx(p.."tx", el.text, ex, ey+4, 12, C.txtDim, zi+1); return
    end

    -- Card (shared by all interactive elements)
    local hov=hit(mx,my,ex,ey,ew,eH)
    sq(p.."bg",  ex, ey, ew, eH, hov and C.cardHov or C.card, zi)
    sqo(p.."bd", ex, ey, ew, eH, C.bord, zi+1)
    sq(p.."pip", ex, ey, 2,  eH, hov and C.acc or C.accDim,   zi+2)

    -- vertical centre offset for single-row elements
    local midY = ey + math.floor((eH-13)/2)

    -- ── Button ──────────────────────────────────────────────────────────────
    if el.type=="button" then
        tx(p.."nm", el.name, ex+12, midY, 13, C.txt, zi+2)
        local bw=72; local bx=ex+ew-bw-8
        local by_=ey+math.floor((eH-22)/2)
        sq(p.."cbg",  bx,by_,bw,22, C.accDim,  zi+3)
        sqo(p.."cbd", bx,by_,bw,22, C.acc,     zi+4)
        sq(p.."ctl",  bx,by_,bw,2,  C.acc,     zi+5)
        tx(p.."ctx","Execute", bx+bw/2, by_+5, 11, C.white, zi+5, true)
        self:_addZone(ex,ey,ew,eH, function() pcall(el.callback) end)

    -- ── Toggle ──────────────────────────────────────────────────────────────
    elseif el.type=="toggle" then
        tx(p.."nm", el.name, ex+12, midY, 13, C.txt, zi+2)
        local pillW=44; local pillH=20
        local pillX=ex+ew-pillW-8
        local pillY=ey+math.floor((eH-pillH)/2)
        local on=el.value
        sq(p.."pbg",  pillX,pillY,pillW,pillH, on and C.toggle_on or C.toggle_off, zi+3)
        sqo(p.."pbd", pillX,pillY,pillW,pillH, on and C.acc or C.bord,            zi+4)
        local knobX=on and (pillX+pillW-pillH+2) or (pillX+2)
        sq(p.."knb",  knobX,pillY+2,pillH-4,pillH-4, on and C.white or C.txtMuted, zi+5)
        tx(p.."ptx",  on and "ON" or "OFF", pillX+pillW/2, pillY+4, 9,
            on and C.white or C.txtMuted, zi+5, true)
        self:_addZone(ex,ey,ew,eH, function()
            el.value=not el.value; pcall(el.callback,el.value)
        end)

    -- ── Slider ──────────────────────────────────────────────────────────────
    elseif el.type=="slider" then
        tx(p.."nm",  el.name, ex+12, ey+8, 13, C.txt, zi+2)
        tx(p.."val", tostring(math.floor(el.value))..el.suffix,
            ex+ew-10, ey+8, 12, C.accGlow, zi+2)
        local sw=ew-24; local sx=ex+12; local sy_=ey+30; local sh=6
        local pct=(el.value-el.min)/(el.max-el.min)
        local fillW=math.floor(pct*sw)
        sq(p.."tr",  sx, sy_, sw, sh, C.slider, zi+3)
        sq(p.."fl",  sx, sy_, math.max(4,fillW), sh, C.acc, zi+4)
        sqo(p.."trd",sx, sy_, sw, sh, C.bord, zi+3)
        -- knob as a small vertical bar
        sq(p.."kn", sx+fillW-3, sy_-3, 6, sh+6, C.accGlow, zi+5)
        if el.dragging then
            if ismouse1pressed() then
                local rx=math.clamp(mx-sx,0,sw)
                el.value=math.clamp(math.floor(el.min+(rx/sw)*(el.max-el.min)+0.5),el.min,el.max)
                pcall(el.callback,el.value)
            else el.dragging=false end
        end
        self:_addZone(sx,sy_-6,sw,sh+12,function() el.dragging=true end)

    -- ── Dropdown ─────────────────────────────────────────────────────────────
    -- Two-row card: name on top-left, full-width bar on bottom row
    elseif el.type=="dropdown" then
        local topH=22
        tx(p.."nm", el.name, ex+12, ey+math.floor((topH-13)/2)+1, 13, C.txt, zi+2)
        -- option count hint right-aligned on top row
        tx(p.."ct", #el.options.." skins",
            ex+ew-8, ey+math.floor((topH-11)/2)+1, 10, C.txtMuted, zi+2)

        -- Bar
        local dY=ey+topH; local dH=eH-topH
        local ddOpen=self.DD~=nil and self.DD.tag==p.."dd"
        sq(p.."ddbg",  ex+2,dY,ew-4,dH, C.dropBg, zi+3)
        sqo(p.."ddbd", ex+2,dY,ew-4,dH, ddOpen and C.acc or C.bord, zi+4)
        if el.value~="Standard" and el.value~="" then
            sq(p.."ddpip", ex+2,dY,2,dH, C.acc, zi+5)
        end
        local dispVal = (el.value=="" and "Select...") or el.value
        tx(p.."ddtx", dispVal,
            ex+10, dY+math.floor((dH-13)/2), 13,
            ddOpen and C.accGlow or (el.value~="" and C.txtDim or C.txtMuted), zi+5)
        tx(p.."ddar","v", ex+ew-14, dY+math.floor((dH-13)/2), 12, C.txtMuted, zi+5)

        local zx,zy,zw,zh=ex+2,dY,ew-4,dH
        self:_addZone(zx,zy,zw,zh,function()
            if self.DD and self.DD.tag==p.."dd" then self.DD=nil; return end
            local iH=20; local ms=math.min(9,#el.options)
            local popH=ms*iH+4
            local popY=zy+zh+1
            if popY+popH > self.WY+WH-4 then popY=zy-popH-1 end
            local so=0
            for idx,v in ipairs(el.options) do
                if v==el.value then so=math.max(0,idx-math.floor(ms/2)); break end
            end
            self.DD={
                x=zx,y=popY,w=zw,h=popH,
                items=el.options,cur=el.value,
                scrollOff=so,maxShow=ms,itemH=iH,
                tag=p.."dd",
                fk=p.."ddf_",   -- unique key prefix per dropdown instance
                hovIdx=0,
                onSelect=function(c)
                    el.value=c; pcall(el.callback,{c}); self.DD=nil
                end,
            }
        end)

    -- ── Textbox ──────────────────────────────────────────────────────────────
    elseif el.type=="textbox" then
        local topH=22
        tx(p.."nm", el.name, ex+12, ey+math.floor((topH-13)/2)+1, 13, C.txt, zi+2)
        local tw=ew-4; local tx2=ex+2; local ty2=ey+topH; local th=eH-topH
        sq(p.."tbg",  tx2,ty2,tw,th, C.input, zi+3)
        sqo(p.."tbd", tx2,ty2,tw,th, el.active and C.acc or C.bord, zi+4)
        local cursor=tick()%1>0.5 and "|" or ""
        local disp = el.active and (el.value..cursor)
            or (el.value~="" and el.value or el.placeholder)
        tx(p.."ttx", disp, tx2+8, ty2+math.floor((th-13)/2), 13,
            (el.active or el.value~="") and C.txt or C.txtMuted, zi+5)
        self:_addZone(tx2,ty2,tw,th,function()
            for _,t in ipairs(self.tabs) do
                for _,e in ipairs(t.elements) do
                    if e.type=="textbox" then e.active=false end
                end
            end
            el.active=true
        end)

    -- ── Keybind ──────────────────────────────────────────────────────────────
    elseif el.type=="keybind" then
        tx(p.."nm", el.name, ex+12, midY, 13, C.txt, zi+2)
        local kbW=math.max(56,#el.vkName*8+16)
        local kbX=ex+ew-kbW-8
        local kbY=ey+math.floor((eH-20)/2); local kbH=20
        if el.listening then
            sq(p.."kbg",  kbX,kbY,kbW,kbH, C.redDk, zi+3)
            sqo(p.."kbd", kbX,kbY,kbW,kbH, C.red,   zi+4)
            tx(p.."ktx","...", kbX+kbW/2,kbY+4,11,C.red,zi+5,true)
        else
            sq(p.."kbg",  kbX,kbY,kbW,kbH, C.accDark, zi+3)
            sqo(p.."kbd", kbX,kbY,kbW,kbH, C.acc,     zi+4)
            tx(p.."ktx", el.vkName, kbX+kbW/2,kbY+4,11,C.accGlow,zi+5,true)
        end
        self:_addZone(kbX,kbY,kbW,kbH,function()
            for _,t in ipairs(self.tabs) do
                for _,e in ipairs(t.elements) do
                    if e.type=="keybind" then e.listening=false end
                end
            end
            el.listening=true
        end)
        if el.listening then
            if vkEdge(0x1B) then el.listening=false
            else
                for _,entry in ipairs(VK_SCAN) do
                    if vkEdge(entry[1]) then
                        el.vk=entry[1]; el.vkName=entry[2]
                        el.listening=false; pcall(el.callback,entry[2]); break
                    end
                end
            end
        end
    end
end

-- ── Dropdown overlay (full scrollbar, from Rivals SC v5.4) ───────────────────
function MatchaUI:_renderDD(mx, my)
    if not self.DD then return end
    local d=self.DD
    local x,y,w,h=d.x,d.y,d.w,d.h
    local fk=d.fk

    local maxSc=math.max(0,#d.items-d.maxShow)
    d.scrollOff=math.clamp(d.scrollOff,0,maxSc)

    local hasSb=maxSc>0
    local sbW=5; local sbX=x+w-sbW
    local sbY=y+2; local sbH=h-4
    local tH=hasSb and math.max(14,math.floor(sbH*(d.maxShow/#d.items))) or 0
    local tY=hasSb and (sbY+math.floor((sbH-tH)*(d.scrollOff/maxSc))) or sbY
    local itemW=hasSb and (w-sbW-1) or w

    sq("ddo_sh",  x+3,y+3,w,h, C.black,  28)
    sq("ddo_bg",  x,  y,  w,h, C.dropBg, 29)
    sqo("ddo_bd", x,  y,  w,h, C.acc,    30)
    sq("ddo_tl",  x,  y,  w,2, C.acc,    31)

    if hasSb then
        sq("ddo_str",sbX,sbY,sbW,sbH, C.bord,32)
        sq("ddo_sth",sbX,tY, sbW,tH,  C.acc, 33)
        self:_addDDZone(sbX,tY,sbW,tH,function()
            self.ddScrollDragging    =true
            self.ddScrollDragStartY  =my
            self.ddScrollDragStartOff=d.scrollOff
        end)
    end

    local hovI=0
    if hit(mx,my,x,y,itemW,h) then
        hovI=math.floor((my-y)/d.itemH)+1
        if hovI<1 or hovI>d.maxShow then hovI=0 end
    end
    d.hovIdx=hovI

    for i=1,d.maxShow do
        local idx=i+d.scrollOff
        if idx<=#d.items then
            local iy_=y+(i-1)*d.itemH
            local isSel=d.items[idx]==d.cur
            local isHov=d.hovIdx==i
            if isSel then
                sq(fk.."b"..i,     x+1,iy_,itemW-2,d.itemH-1, C.accDark,31)
                ln(fk.."l"..i,     x+1,iy_,x+1,iy_+d.itemH-2, C.acc,2,32)
            elseif isHov then
                sq(fk.."b"..i,     x+1,iy_,itemW-2,d.itemH-1, C.dropHov,31)
            end
            tx(fk.."t"..i, d.items[idx], x+10, iy_+3, 13,
                isSel and C.accGlow or (isHov and C.txt or C.txtDim), 32)
        end
    end
end

-- ── Notifications ─────────────────────────────────────────────────────────────
function MatchaUI:_renderNotifs()
    local now=tick()
    for i=#self.notifs,1,-1 do
        if now>self.notifs[i].expires then table.remove(self.notifs,i) end
    end
    if #self.notifs==0 then return end
    -- Show only latest notification (single bar, like original script)
    local n=self.notifs[#self.notifs]
    local p=n.id.."_"
    local nw=NOTIF_W
    local nx=self.WX+math.floor((WW-nw)/2)
    local ny=self.WY+WH-NOTIF_H-8
    -- slide up on enter
    local age=now-n.enterT
    local slide=math.min(1,age/0.2)
    local ady=ny+math.floor((1-slide)*16)
    local pct=math.max(0,(n.expires-now)/n.duration)
    local barW=math.floor(pct*(nw-8))
    sq(p.."sh",  nx+2,ady+2,nw,NOTIF_H, C.black,   44)
    sq(p.."bg",  nx,  ady,  nw,NOTIF_H, C.notifBg, 45)
    sqo(p.."bd", nx,  ady,  nw,NOTIF_H, C.acc,     46)
    sq(p.."tl",  nx,  ady,  nw,2,       C.acc,     47)
    tx(p.."ct",  n.content, nx+nw/2, ady+math.floor((NOTIF_H-13)/2), 13, C.txt, 48, true)
    sq(p.."tbr", nx+4, ady+NOTIF_H-4, nw-8, 2, C.bord,48)
    if barW>0 then sq(p.."tbl", nx+4, ady+NOTIF_H-4, barW, 2, C.acc, 49) end
end

-- ── Main render ───────────────────────────────────────────────────────────────
function MatchaUI:_render(mx, my)
    beginFrame()
    table.clear(self.zones)
    table.clear(self.ddZones)

    self:_renderNotifs()

    if not self.Visible then endFrame(); return end

    local WX=self.WX; local WY=self.WY

    -- Window
    sq("w_sh",  WX+4,WY+4,WW,WH, C.black, 0)
    sq("w_bg",  WX,  WY,  WW,WH, C.bg,    1)
    sqo("w_bd", WX,  WY,  WW,WH, C.bord,  2)
    sq("w_el",  WX,  WY,  2, WH, C.acc,   3)
    sq("w_et",  WX,  WY,  WW,1,  C.acc,   3)

    -- Topbar
    sq("t_bg",  WX,WY,WW,TOPBAR, C.sidebar,2)
    sq("t_ln",  WX,WY+TOPBAR-1,WW,1, C.acc,3)
    tx("t_ttl", self.Name,     WX+14, WY+13, 14, C.txt,    4)
    tx("t_sub", self.Subtitle, WX+14+#self.Name*8+4, WY+15, 11, C.txtMuted,4)
    tx("t_hnt", self.ToggleKeyName.." to toggle", WX+WW-116, WY+14, 12, C.txtMuted,4)
    self:_addZone(WX,WY,WW,TOPBAR,function()
        self.dragOn=true; self.dragOX=mx-WX; self.dragOY=my-WY
    end)

    -- Sidebar
    local cy=WY+TOPBAR
    sq("s_bg",  WX,       cy,SIDEBAR,WH-TOPBAR, C.sidebar,2)
    sq("s_sep", WX+SIDEBAR-1,cy,1,WH-TOPBAR,   C.bord,   3)

    for i,tab in ipairs(self.tabs) do
        local ty_=cy+(i-1)*TAB_H
        local isA=(i==self.activeTab)
        local p="stb"..i.."_"
        sq(p.."bg",  WX,ty_,SIDEBAR,TAB_H, isA and C.accDark or C.sidebar,4)
        sq(p.."pip", WX,ty_,3,TAB_H, isA and C.acc or C.bord,5)
        sq(p.."bot", WX,ty_+TAB_H-1,SIDEBAR,1, C.bord,4)
        tx(p.."lb",  tab.name, WX+14, ty_+math.floor((TAB_H-13)/2), 13,
            isA and C.acc or C.txtDim,5)
        local ci=i
        self:_addZone(WX,ty_,SIDEBAR,TAB_H,function()
            if self.activeTab~=ci then self.activeTab=ci; self.DD=nil end
        end)
    end

    -- Content area
    local cx=WX+SIDEBAR; local cw=WW-SIDEBAR; local ch=WH-TOPBAR
    sq("c_bg", cx,cy,cw,ch, C.bgPanel,2)

    local tab=self.tabs[self.activeTab]
    if not tab then endFrame(); return end

    -- Total content height
    local totalH=CONTENT_PAD
    for _,el in ipairs(tab.elements) do totalH=totalH+elemH(el)+ELEM_GAP end

    local maxScroll=math.max(0,totalH-ch+CONTENT_PAD)
    tab.scroll=math.clamp(tab.scroll or 0,0,maxScroll)

    -- Scrollbar
    if maxScroll>0 then
        local sbX=cx+cw-5; local sbY=cy+2; local sbH2=ch-4
        sq("ctsb_t",sbX,sbY,4,sbH2, C.bord,5)
        local tH2=math.max(20,math.floor(sbH2*(ch/totalH)))
        local tY2=sbY+math.floor((sbH2-tH2)*(tab.scroll/maxScroll))
        sq("ctsb_h",sbX,tY2,4,tH2, C.acc,6)
    end

    local elemW=cw-CONTENT_PAD*2-(maxScroll>0 and 8 or 0)
    local ey0=cy+CONTENT_PAD-tab.scroll

    for _,el in ipairs(tab.elements) do
        local eH_=elemH(el)
        if ey0+eH_>=cy and ey0<=cy+ch then
            self:_renderElement(el,cx+CONTENT_PAD,ey0,elemW,mx,my,5)
        end
        ey0=ey0+eH_+ELEM_GAP
    end

    -- Dropdown always on top
    self:_renderDD(mx,my)

    endFrame()
end

-- ── Main loop ─────────────────────────────────────────────────────────────────
function MatchaUI:_startLoop()
    local prevM1=false; local lastScroll=0
    task.spawn(function()
        while not self._destroyed do
            task.wait()
            VP=workspace.CurrentCamera.ViewportSize
            local mx=mouse.X; local my=mouse.Y
            local m1=ismouse1pressed()
            local justClicked=m1 and not prevM1
            prevM1=m1

            -- Toggle
            if vkEdge(self.ToggleKey) then
                self.Visible=not self.Visible
                if not self.Visible then self.DD=nil end
            end

            -- Drag
            if self.dragOn then
                if m1 then
                    self.WX=math.clamp(mx-self.dragOX,0,VP.X-WW)
                    self.WY=math.clamp(my-self.dragOY,0,VP.Y-WH)
                    self.DD=nil
                else self.dragOn=false end
                justClicked=false
            end

            -- DD scrollbar drag
            if self.ddScrollDragging then
                if m1 and self.DD then
                    local d=self.DD
                    local maxDD=math.max(0,#d.items-d.maxShow)
                    local sbH_=d.h-4
                    local tH_=math.max(14,math.floor(sbH_*(d.maxShow/#d.items)))
                    local trk=sbH_-tH_
                    if trk>0 then
                        local ratio=(my-self.ddScrollDragStartY)/trk
                        d.scrollOff=math.clamp(
                            math.floor(self.ddScrollDragStartOff+ratio*maxDD+0.5),0,maxDD)
                    end
                else self.ddScrollDragging=false end
            end

            -- Content scroll
            if self.Visible and not self.DD then
                local now2=tick()
                if now2-lastScroll>0.08 then
                    local t=self.tabs[self.activeTab]
                    if t then
                        if iskeypressed(0x26) or iskeypressed(0x57) then
                            t.scroll=math.max(0,(t.scroll or 0)-16); lastScroll=now2
                        elseif iskeypressed(0x28) or iskeypressed(0x53) then
                            t.scroll=(t.scroll or 0)+16; lastScroll=now2
                        end
                    end
                end
            end

            -- Click
            if justClicked and self.Visible then
                if self.DD then
                    local d=self.DD
                    if hit(mx,my,d.x,d.y,d.w,d.h) then
                        local hitDDZ=false
                        for _,z in ipairs(self.ddZones) do
                            if hit(mx,my,z.x,z.y,z.w,z.h) then z.fn(); hitDDZ=true; break end
                        end
                        if not hitDDZ then
                            local hasSb=math.max(0,#d.items-d.maxShow)>0
                            local itemW=hasSb and (d.w-6) or d.w
                            if hit(mx,my,d.x,d.y,itemW,d.h) then
                                local idx=math.floor((my-d.y)/d.itemH)+1+d.scrollOff
                                if idx>=1 and idx<=#d.items then d.onSelect(d.items[idx]) end
                            end
                        end
                    else
                        self.DD=nil
                    end
                else
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

            local ok,err=pcall(self._render,self,mx,my)
            if not ok then
                local d=getObj("_mui_err","Text")
                d.Text="[MatchaUI] "..tostring(err)
                d.Position=Vector2.new(10,50); d.Size=12
                d.Color=Color3.fromRGB(255,80,80); d.Font=Drawing.Fonts.UI
                d.Outline=false; d.Center=false; d.ZIndex=99; d.Visible=true
            end
        end
    end)
end

return MatchaUI
