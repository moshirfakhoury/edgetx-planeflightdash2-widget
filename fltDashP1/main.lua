---------------------------------------------------------------------------
-- FlightDash For Planes Widget
-- EdgeTX 2.11+
---------------------------------------------------------------------------

local name = "fltDashP1"

---------------------------------------------------------------------------
-- VARIABLES
---------------------------------------------------------------------------

local PURPLE    = lcd.RGB(149, 66, 245)
local BROWN     = lcd.RGB(79, 54, 39)
local PINK      = lcd.RGB(206, 126, 252)
local CYAN      = lcd.RGB(58, 242, 242)
local LIGHTBLUE = lcd.RGB(25, 175, 255)

local tlmColor = ORANGE
local maxAlt = 0

local img = bitmap.open("/WIDGETS/fltDashP1/Picon.png")

local img5R = bitmap.open("/WIDGETS/fltDashP1/Picon5R.png")
local img10R = bitmap.open("/WIDGETS/fltDashP1/Picon10R.png")
local img15R = bitmap.open("/WIDGETS/fltDashP1/Picon15R.png")
local img20R = bitmap.open("/WIDGETS/fltDashP1/Picon20R.png")
local img25R = bitmap.open("/WIDGETS/fltDashP1/Picon25R.png")

local img5L = bitmap.open("/WIDGETS/fltDashP1/Picon5L.png")
local img10L = bitmap.open("/WIDGETS/fltDashP1/Picon10L.png")
local img15L = bitmap.open("/WIDGETS/fltDashP1/Picon15L.png")
local img20L = bitmap.open("/WIDGETS/fltDashP1/Picon20L.png")
local img25L = bitmap.open("/WIDGETS/fltDashP1/Picon25L.png")

print("img5R", img5R)
print("img10R", img10R)
print("img15R", img15R)
print("img20R", img20R)
print("img25R", img25R)

print("img5L", img5L)
print("img10L", img10L)
print("img15L", img15L)
print("img20L", img20L)
print("img25L", img25L)


---------------------------------------------------------------------------
-- OPTIONS
---------------------------------------------------------------------------

local options = {
  { "Motor Switch", SWITCH, 0 },
  { "Rx Signal", SOURCE, 0 },
  { "Rx Qty", SOURCE, 0 },
  { "Rx Batt", SOURCE, 0 },
  { "Cells", VALUE, 6, 1, 14 },
  { "Altitude", SOURCE, 0 }
}

---------------------------------------------------------------------------
-- CREATE
---------------------------------------------------------------------------

local function create(zone, opts)
  return {
    zone = zone,
    options = opts or {}
  }
end

---------------------------------------------------------------------------
-- UPDATE
---------------------------------------------------------------------------

local function update(widget, opts)
  widget.options = opts
end

---------------------------------------------------------------------------
-- SOURCE LABEL
---------------------------------------------------------------------------

local function sourceLabel(src, fallback)
  if src ~= 0 then
    local info = getSourceInfo(src)
    if info and info.name then
      return info.name
    end
  end
  return fallback
end

---------------------------------------------------------------------------
-- DRAW TRIM BAR
---------------------------------------------------------------------------

local function drawTrimBar(x, y, w, h, value, vertical)

  x = math.floor(x + 0.5)
  y = math.floor(y + 0.5)
  w = math.floor(w + 0.5)
  h = math.floor(h + 0.5)

  lcd.drawRectangle(x, y, w, h, ORANGE)

  local percent = math.max(0, math.min(1, (value + 1000) / 2000))

  if vertical then

    local markerH = 8
    local centerY = math.floor(y + (h - markerH) / 2 + 0.5)
    local markerY = math.floor(y + (h - markerH) * (1 - percent) + 0.5)

    lcd.drawFilledRectangle(x + 1, centerY, w - 2, markerH, ORANGE)
    lcd.drawFilledRectangle(x + 1, markerY, w - 2, markerH, CYAN)

  else

    local markerW = 8
    local centerX = math.floor(x + (w - markerW) / 2 + 0.5)
    local markerX = math.floor(x + (w - markerW) * percent + 0.5)

    lcd.drawFilledRectangle(centerX, y + 1, markerW, h - 2, ORANGE)
    lcd.drawFilledRectangle(markerX, y + 1, markerW, h - 2, CYAN)

  end
end

---------------------------------------------------------------------------
-- REFRESH
---------------------------------------------------------------------------

local function refresh(widget)

  local z = widget.zone
  local opt = widget.options

  lcd.drawFilledRectangle(z.x, z.y, z.w, z.h, BLACK)

  -------------------------------------------------------------------------
  -- LAYOUT
  -------------------------------------------------------------------------

  local centerX = math.floor(z.x + z.w / 2 + 0.5)
  local centerY = math.floor(z.y + z.h / 2 + 10 + 0.5)

  local battCX = centerX + 100
  local battCY = centerY + 10

  local rBigScaled = 98
  local radius = 92

  local rMed = 45

  local text1X = centerX
  local text1Y = z.y + z.h - 32

  local medCX = centerX - 120
  local rqtyCY = centerY

  -------------------------------------------------------------------------
  -- TELEMETRY
  -------------------------------------------------------------------------

  local rssVal = (opt["Rx Signal"] ~= 0 and getValue(opt["Rx Signal"])) or 0
  local rqtyVal = (opt["Rx Qty"] ~= 0 and getValue(opt["Rx Qty"])) or 0
  local battVal = (opt["Rx Batt"] ~= 0 and getValue(opt["Rx Batt"])) or 0
  local altVal = (opt["Altitude"] ~= 0 and getValue(opt["Altitude"])) or 0
  local cells = opt["Cells"] or 6
  local thrVal = getValue("thr") or -1024
  local ailVal = getValue("ail") or 0

  -------------------------------------------------------------------------
  -- TRIMS
  -------------------------------------------------------------------------

  local trim1 = getValue("trim-ail") or 0
  local trim2 = getValue("trim-ele") or 0
  local trim3 = getValue("trim-thr") or 0
  local trim4 = getValue("trim-rud") or 0

  -------------------------------------------------------------------------
  -- MOTOR
  -------------------------------------------------------------------------

  local motorOn = opt["Motor Switch"] ~= 0 and getSwitchValue(opt["Motor Switch"])

  local statusColor = BLACK

  if rssVal ~= 0 then
    statusColor = motorOn and GREEN or RED
  end

  local circleR = 30
  local circleX = z.x + z.w - circleR - 20
  local circleY = z.y + circleR + 10

  lcd.drawFilledCircle(circleX, circleY, circleR, statusColor)
  lcd.drawCircle(circleX, circleY, circleR, WHITE)
  lcd.drawText(circleX, circleY - 4, motorOn and "Mtr On" or "Mtr Off", CENTER + SMLSIZE + WHITE)

  lcd.drawText(math.floor(z.x + z.w / 2 + 0.5), z.y + 8, model.getInfo().name or "MODEL", CENTER + DBLSIZE + ((rssVal ~= 0) and tlmColor or WHITE))

  -------------------------------------------------------------------------
  -- TX BATTERY
  -------------------------------------------------------------------------

  local txV = getValue("tx-voltage") or 0
  local txPct = math.max(0, math.min(1, (txV - 6.8) / (8.4 - 6.8)))

  local battColor = GREEN
  if txV < 7.1 then
    battColor = RED
  elseif txV <= 7.5 then
    battColor = YELLOW
  end

  local battW = 60
  local battH = 18
  local battX = math.floor(z.x + z.w / 2 - battW / 2 + 0.5)
  local battY = z.y + 50

  lcd.drawRectangle(battX, battY, battW, battH, WHITE)
  lcd.drawFilledRectangle(battX + battW, battY + battH / 4, 5, battH / 2, WHITE)
  lcd.drawFilledRectangle(battX + 1, battY + 1, math.floor((battW - 2) * txPct + 0.5), battH - 2, battColor)
  lcd.drawText(battX + battW / 2, battY + 1, string.format("%.1fV", txV), CENTER + SMLSIZE + WHITE)

  -------------------------------------------------------------------------
  -- RX BATTERY GAUGE
  -------------------------------------------------------------------------

  lcd.drawFilledCircle(battCX, battCY, rBigScaled, GREY)

  for i = 0, 2 do
    lcd.drawCircle(battCX, battCY, rBigScaled - i, RED)
  end

  -------------------------------------------------------------------------
  -- SECOND LARGE CIRCLE
  -------------------------------------------------------------------------

  local circle2CX = battCX - (rBigScaled * 2) + 1
  local circle2CY = battCY

  lcd.drawFilledCircle(circle2CX, circle2CY, rBigScaled, GREY)

  for i = 0, 2 do
    lcd.drawCircle(circle2CX, circle2CY, rBigScaled - i, RED)
  end

  -- FM
  local fm = getFlightMode() or 0
  lcd.drawText(z.x + 90, z.y + 130, "FM" .. fm, CENTER + ((rssVal ~= 0) and YELLOW or WHITE))

  --ALTITUDE
  if altVal > maxAlt then
    maxAlt = altVal
  end
  lcd.drawText(z.x + 170, z.y + 125, string.format("Alt: %.1fm", altVal), SMLSIZE + ((rssVal ~= 0) and YELLOW or WHITE))
  lcd.drawText(z.x + 170, z.y + 137, string.format("Max: %.1fm", maxAlt), SMLSIZE + ((rssVal ~= 0) and YELLOW or WHITE))
  
  -- TIMER
  local timer = model.getTimer(0)
  local timeLeft = timer.value or 0

  lcd.drawText(z.x + 145, z.y + 90, string.format("%02d:%02d", math.floor(timeLeft / 60), timeLeft % 60), CENTER + MIDSIZE + ((rssVal ~= 0) and PINK or WHITE))
  -------------------------------------------------------------------------
  -- DATE / TIME
  -------------------------------------------------------------------------
  local dt = getDateTime()
  local months = {"Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"}

  lcd.drawText(z.x + z.w - 210, z.y + 125, string.format("%d %s", dt.day, months[dt.mon]), ((rssVal ~= 0) and YELLOW or WHITE))
  lcd.drawText(z.x + z.w - 115, z.y + 125, string.format("%02d:%02d", dt.hour, dt.min), ((rssVal ~= 0) and YELLOW or WHITE))

  local cellMin = 3.2
  local cellMax = 4.2

  local voltMin = cells * cellMin
  local voltMax = cells * cellMax

  local battClamped = math.max(voltMin, math.min(voltMax, battVal))

  local steps = {
    { label = "E", value = voltMin },
    { label = "F", value = voltMax }
  }

  for i = 1, #steps do

    local val = steps[i].value

    local angle = math.rad(165 - ((val - voltMin) / (voltMax - voltMin)) * 150)

    local tickLen = 10

    local x1 = math.floor(battCX + math.cos(angle) * (radius - tickLen / 2) + 0.5)
    local y1 = math.floor(battCY - math.sin(angle) * (radius - tickLen / 2) + 0.5)

    local x2 = math.floor(battCX + math.cos(angle) * (radius + tickLen / 2) + 0.5)
    local y2 = math.floor(battCY - math.sin(angle) * (radius + tickLen / 2) + 0.5)

    lcd.drawLine(x1, y1, x2, y2, SOLID)

    local tx = math.floor(battCX + math.cos(angle) * (radius - 9) + 0.5)
    local ty = math.floor(battCY - math.sin(angle) * (radius - 9) - 8 + 0.5)

    lcd.drawText(tx, ty, steps[i].label, CENTER + SMLSIZE + WHITE)

  end

  -------------------------------------------------------------------------
  -- NEEDLE
  -------------------------------------------------------------------------

  local angle = math.rad(165 - ((battClamped - voltMin) / (voltMax - voltMin)) * 150)

  local needleLen = radius - 34

  local nx = math.floor(battCX + math.cos(angle) * needleLen + 0.5)
  local ny = math.floor(battCY - math.sin(angle) * needleLen + 0.5)

  for o = -3, 3 do
    lcd.drawLine(battCX + o, battCY, nx + o, ny, SOLID)
  end

  lcd.drawFilledCircle(battCX, battCY, 10, BLACK)
  lcd.drawFilledCircle(battCX, battCY, 5, WHITE)

  lcd.drawText(battCX, battCY - 70, string.format("%.1fV", battVal), CENTER + MIDSIZE + ((rssVal ~= 0) and PINK or WHITE))

  -------------------------------------------------------------------------
  -- BLACK RECTANGEL	
  -------------------------------------------------------------------------
  lcd.drawFilledRectangle(z.x / 2, z.y + 155, z.w - 40, z.h + 125, BLACK)
  lcd.drawFilledRectangle(z.x + 48, z.y + 160, 280, 45, DARKBLUE)
  lcd.drawFilledRectangle(z.x + 48, z.y + 205, 280, 45, DARKBROWN)

  -------------------------------------------------------------------------
  -- ROLLING PLANE IMAGE
  -------------------------------------------------------------------------

  local planeImg = img

  if ailVal <= -820 then
    planeImg = img25L

  elseif ailVal <= -615 then
    planeImg = img20L

  elseif ailVal <= -410 then
    planeImg = img15L

  elseif ailVal <= -205 then
    planeImg = img10L

  elseif ailVal <= -80 then
    planeImg = img5L

  elseif ailVal < 80 then
    planeImg = img

  elseif ailVal < 205 then
    planeImg = img5R

  elseif ailVal < 410 then
    planeImg = img10R

  elseif ailVal < 615 then
    planeImg = img15R

  elseif ailVal < 820 then
    planeImg = img20R

  else
    planeImg = img25R
  end

  if planeImg then
    lcd.drawBitmap(planeImg, z.x + 91, z.y + 170)
  end
  -------------------------------------------------------------------------
  -- RSS BAR
  -------------------------------------------------------------------------

  local barW = 24
  local barH = 65
  local gap = 12

  local barX = z.x + z.w / 11 * 9 - 12
  local barY = math.floor(z.y + z.h - barH - 45)

  lcd.drawRectangle(barX, barY, barW, barH, WHITE)

  local rssClamped = math.max(-100, math.min(0, rssVal))

  local rssPct = 0
  if rssVal ~= 0 then
    rssPct = 1 - (math.abs(rssClamped) / 100)
  end

  local segments = 8
  local segGap = 2
  local segH = math.floor((barH - (segments - 1) * segGap) / segments + 0.5)

  local filledSegs = math.floor(rssPct * segments)

  local barColor = WHITE

  if rssVal <= -85 then
    barColor = RED
  elseif rssVal <= -70 then
    barColor = YELLOW
  elseif rssVal < 0 then
    barColor = GREEN
  end

  for i = 0, segments - 1 do

    local y = math.floor(barY + barH - (i + 1) * segH - i * segGap + 0.5)

    if i < filledSegs then
      lcd.drawFilledRectangle(barX + 1, y, barW - 2, segH, barColor)
    end

    if i < segments - 1 then
      lcd.drawLine(barX, y - segGap / 2, barX + barW, y - segGap / 2, GREY)
    end

  end

  lcd.drawText(barX + barW / 2, barY + barH + 4, string.format("%ddB", rssVal), CENTER + SMLSIZE + WHITE)
  lcd.drawText(barX + barW / 2, barY + barH + 18, sourceLabel(opt["Rx Signal"], "1RSS"), CENTER + SMLSIZE + WHITE)

  -------------------------------------------------------------------------
  -- RQTY BAR
  -------------------------------------------------------------------------

  local barX2 = barX + barW + gap
  local barY2 = barY

  lcd.drawRectangle(barX2, barY2, barW, barH, WHITE)

  local rqtyClamped = math.max(0, math.min(100, rqtyVal))
  local rqtyPct = rqtyClamped / 100

  local filledSegs2 = math.floor(rqtyPct * segments)

  local rqtyColor = WHITE

  if rqtyVal < 1 then
    rqtyColor = WHITE
  elseif rqtyVal <= 69 then
    rqtyColor = RED
  elseif rqtyVal <= 89 then
    rqtyColor = YELLOW
  else
    rqtyColor = GREEN
  end

  for i = 0, segments - 1 do

    local y = math.floor(barY2 + barH - (i + 1) * segH - i * segGap + 0.5)

    if i < filledSegs2 then
      lcd.drawFilledRectangle(barX2 + 1, y, barW - 2, segH, rqtyColor)
    end

    if i < segments - 1 then
      lcd.drawLine(barX2, y - segGap / 2, barX2 + barW, y - segGap / 2, GREY)
    end

  end

  lcd.drawText(barX2 + barW / 2, barY2 + barH + 4, string.format("%d%%", rqtyVal), CENTER + SMLSIZE + WHITE)
  lcd.drawText(barX2 + barW / 2, barY2 + barH + 18, sourceLabel(opt["Rx Qty"], "RQly"), CENTER + SMLSIZE + WHITE)

  -------------------------------------------------------------------------
  -- THROTTLE BAR
  -------------------------------------------------------------------------

  local barX3 = barX - barW - gap
  local barY3 = barY

  lcd.drawRectangle(barX3, barY3, barW, barH, WHITE)

  local thrClamped = math.max(-1024, math.min(1024, thrVal))

  local thrPct = (thrClamped + 1024) / 2048

  local filledSegs3 = math.floor(thrPct * segments)

  for i = 0, segments - 1 do

    local y = math.floor(barY3 + barH - (i + 1) * segH - i * segGap + 0.5)

    if i < filledSegs3 then

      local segPct = (i + 1) / segments

      local segColor = GREEN

      if segPct > 0.80 then
        segColor = RED
      elseif segPct > 0.50 then
        segColor = YELLOW
      end

      lcd.drawFilledRectangle(barX3 + 1, y, barW - 2, segH, segColor)

    end

    if i < segments - 1 then
      lcd.drawLine(barX3, y - segGap / 2, barX3 + barW, y - segGap / 2, GREY)
    end

  end

  lcd.drawText(barX3 + barW / 2, barY3 + barH + 4, string.format("%d%%", math.floor(thrPct * 100 + 0.5)), CENTER + SMLSIZE + WHITE)

  lcd.drawText(barX3 + barW / 2, barY3 + barH + 18, "THR", CENTER + SMLSIZE + WHITE)

  -------------------------------------------------------------------------
  -- TRIMS
  -------------------------------------------------------------------------

  local trimThickness = 6
  local hTrimWidth = math.floor(z.w * 0.38 + 0.5)

  drawTrimBar(z.x + 4, z.y + 55, trimThickness, z.h - 65, trim3, true)
  drawTrimBar(z.x + z.w - trimThickness - 4, z.y + 55, trimThickness, z.h - 65, trim2, true)
  drawTrimBar(z.x + 15, z.y + z.h - 10, hTrimWidth, trimThickness, trim4, false)
  drawTrimBar(z.x + z.w - hTrimWidth - 15, z.y + z.h - 10, hTrimWidth, trimThickness, trim1, false)

end

---------------------------------------------------------------------------
-- RETURN
---------------------------------------------------------------------------

return {
  name = name,
  create = create,
  refresh = refresh,
  update = update,
  options = options
}