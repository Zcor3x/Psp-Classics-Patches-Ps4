-- Lua 5.3
-- Title:   Parappa The Rapper PSP - UCUS-98702 (USA)
-- Author:  Ernesto Corvi

-- Changelog:
-- 1.1 - removed MIDI vibration if not in "playing" mode.
-- 1.2 - fixed issue with High Scores when in Cool mode.

apiRequest(1.0)	-- request version 1.0 API. Calling apiRequest() is mandatory.

local gpr		= require( "ax-gpr-alias" ) -- you can access Allegrex GPR by alias (gpr.a0 / gpr["a0"])
local emuObj	= getEmuObject() -- emulator
local axObj		= getAXObject() -- allegrex

-- SaveData
local SaveData = emuObj.LoadConfig()

-- TODO: Load more midi files here. The first one gets index 0, etc.
-- 48/4 ticks per beat
emuObj.LoadMIDI("host0:midi/PaRappa_Stage_1.mid", 48/4)
emuObj.LoadMIDI("host0:midi/PaRappa_Stage_2.mid", 48/4)
emuObj.LoadMIDI("host0:midi/PaRappa_Stage_3.mid", 48/4)
emuObj.LoadMIDI("host0:midi/PaRappa_Stage_4.mid", 48/4)
emuObj.LoadMIDI("host0:midi/PaRappa_Stage_5.mid", 48/4)
emuObj.LoadMIDI("host0:midi/PaRappa_Stage_6.mid", 48/4)

if SaveData.vibrate == nil then
	SaveData.vibrate = false
end

if SaveData.feedback == nil then
	SaveData.feedback = false
end

-- Language support & manual locations

local lang = emuObj.GetLanguage()
local fullLangName = "English"
local numOfPages = 44

if lang == "fr" then
	fullLangName = "French"
	numOfPages = 41
	axInsnReplace(0x8817d28, 0x24030001, 0x24030005)
	axInsnReplace(0x8817d44, 0x24040001, 0x24040005)
	axInsnReplace(0x8817d68, 0x24060001, 0x24060005)
elseif lang == "es" then
	fullLangName = "Spanish"
	numOfPages = 41
	axInsnReplace(0x8817d28, 0x24030001, 0x2403000a)
	axInsnReplace(0x8817d44, 0x24040001, 0x2404000a)
	axInsnReplace(0x8817d68, 0x24060001, 0x2406000a)
end

pages = {}
for i = 1, numOfPages do
	table.insert(pages, string.format("host0:/manual/%s/Page%02d.jpg", fullLangName, i))
--	print(pages[i])
end

emuObj.LoadSlideshow(pages)

-- Vibration support

local vibrate_enable = SaveData.vibrate

--[[

The screen is divided in 48 markers: 0-47.

Marker 0 is the 1st star.
Marker 12 is the 2nd star.
Marker 24 is the 3rd star.
Marker 36 is the 4th star.

The marker number is indicated below in the "ticks" variable.

emuObj.PadVibrate() causes the DS4 to vibrate. The parameters are as follow:
1st parameter: Large Motor speed (0=off, 1 to 255=speed)
2nd parameter: Small Motor speed (0=off, 1 to 255=speed)
3rd parameter: Duration of the vibration in milliseconds (1000 = 1 second). Once the time has elapsed both motors are turned off automatically.

local ONION_STAGE = 1
local MOOSELINI_STAGE = 2
local FLEASWALLOW_STAGE = 3
local CHICKEN_STAGE = 4
local BATHROOM_STAGE = 5
local MUSHI_STAGE = 6
]]--

local updateTick = function()
	local eventMode = axObj.ReadMem16(0x8a33a90) -- 0 = playing, 1 = demo, 2 = replay (ParaAppInit: 78C94 [233a90 + 88000000 = 8a33a90])

	if vibrate_enable == false or eventMode ~= 0 then
		return
	end

	local tickCounter = axObj.ReadMem32(0x8993f18)
	if (tickCounter & 0x80000000) ~= 0 then
		return
	end

	local stage = axObj.GetGpr(gpr.s1)

    local midiNum = stage - 1
    local globalTicks = math.floor(tickCounter / 8);
    notes = emuObj.GetMIDINotesAtTick(midiNum, globalTicks)
    if notes ~= nil then
		local large = 0
		local small = 0
		local duration = 100
--		emuObj.Log("gotMidiNotes")
		for i,note in ipairs(notes) do
--			emuObj.Log("midiNote " .. note .. " at tick " .. globalTicks)
			if note == 36 then
				large = 100
			elseif note == 38 then
				small = 225
			end
		end
--		emuObj.Log(string.format("vibrate %d/%d/%d at tick: %d", large, small, duration, globalTicks))
		emuObj.PadVibrate(large, small, duration)
	end
end

local setVibrate = function(value)
	vibrate_enable = value
	SaveData.vibrate = value
	emuObj.SaveConfig(SaveData)
	if vibrate_enable == true then
		emuObj.PadVibrate(125, 255, 250)
	end
end

axObj.AddHook(0x886f900, 0x44850000, updateTick) -- AT3M_PLAYER::getTime

-- Button Feedback
local feedback_enable = SaveData.feedback
local zoomFactor = 1.0

local zoomPaRappa = function()
	if zoomFactor > 1.0 then
		local pc = axObj.GetPC()
		local buf = 0x09ffff40 -- use the tail bottom of RAM for this
		local sprite = axObj.GetGpr(gpr.a2)
		local x = axObj.GetGpr(gpr.a0) - (160 - 8)
		local y = axObj.GetGpr(gpr.v0) - (120 - 8)
		local attr = axObj.ReadMem32(sprite)
		local scale = math.floor(4096 * zoomFactor)
		
		-- write out the attributes, x, y, scale and rotation
		axObj.WriteMem32(buf, attr)
		axObj.WriteMem16(buf+4, x)
		axObj.WriteMem16(buf+6, y)
		axObj.WriteMem32(buf+32, 0) -- rotation
		
		-- setup the call, parameters and return address
		axObj.SetPC(0x888222c) -- PrDrawBtnSprite
		axObj.SetGpr(gpr.a0, buf)
		axObj.SetGpr(gpr.a1, sprite)
		axObj.SetGpr(gpr.a2, scale)
		axObj.SetGpr(gpr.a3, scale)
		axObj.SetGpr(gpr.ra, pc + 12)
	end
end

local zoomTrigger = function()
	if feedback_enable == true then
		zoomFactor = 2.25
	end
end

local zoomUpdate = function()
	if zoomFactor > 1.0 then
		zoomFactor = zoomFactor - 0.075
	end
end

axObj.AddHook(0x8888304, 0x27a8008c, zoomPaRappa) -- PrDrawExamBar
axObj.AddHook(0x88778C8, 0x27bdffe0, zoomTrigger) -- ParaActionKeyPress

emuObj.AddVsyncHook(zoomUpdate)

local setFeedback = function(value)
	feedback_enable = value
	SaveData.feedback = value
	emuObj.SaveConfig(SaveData)
end

-- Menu augmentation

local adhocSprite = 0
local sharingSprite = 0

local captureSprite = function()
	local name = axObj.ReadMemStr(axObj.GetGpr(gpr.a1))
	local dir
	local file
	dir, file = string.match(name, "(.*/)(.*)" )
	if file == "menu_moji12.tm2" then -- adhoc
		adhocSprite = axObj.GetGpr(gpr.a0)
	elseif file == "menu_moji13.tm2" then -- game sharing
		sharingSprite = axObj.GetGpr(gpr.a0)
	end
	
--	print(string.format("name: %s - dir: %s - file: %s", name, dir, file))
end

local interceptSprite = function()
	local sprite = axObj.GetGpr(gpr.a0)
	if sprite == adhocSprite then
		local texture = axObj.ReadMem32(sprite+0x30)
		if vibrate_enable == true then
			axObj.WriteMem8(texture, 0)
		else
			axObj.WriteMem8(texture, 0xff)
		end
	elseif sprite == sharingSprite then
		local texture = axObj.ReadMem32(sprite+0x30)
		if feedback_enable == true then
			axObj.WriteMem8(texture, 0)
		else
			axObj.WriteMem8(texture, 0xff)
		end
	end
end

local interceptMenu = function()
	local menu = axObj.GetGpr(gpr.s0)

	if menu == 16 then -- adhoc
		setVibrate(not vibrate_enable)
		axObj.SetGpr(gpr.s0, 3) -- back to the options menu
	elseif menu == 17 then -- game sharing
		setFeedback(not feedback_enable)
		axObj.SetGpr(gpr.s0, 3) -- back to the options menu
	elseif menu == 19 then -- download
		axObj.SetGpr(gpr.s0, 3) -- back to the options menu
		emuObj.StartSlideshow()
	end
end

axObj.AddHook(0x887916c, 0x8c990000, captureSprite) -- ParaAppLoadMenuFile
axObj.AddHook(0x88c3418, 0x27bdfff0, interceptSprite) -- CSprite::Draw
axObj.AddHook(0x8879ec0, 0x00408021, interceptMenu) -- S_RunMainMenu

-- Game bug fixes

-- Practice Mode

---- Relax tap window from 4 ticks to 6 ticks

-- S_PracticeLoop
axInsnReplace(0x888ba74, 0x2a010049, 0x2a010048) -- slti $at, $s0, 0x49 -> slti $at, $s0, 0x48
axInsnReplace(0x888ba98, 0x2a010049, 0x2a010048) -- slti $at, $s0, 0x49 -> slti $at, $s0, 0x48

-- S_EvaluateTap
axInsnReplace(0x888bcbc, 0x24a2fffe, 0x24a2fffd) -- addiu $v0, $a1, -2 -> addiu $v0, $a1, -3
axInsnReplace(0x888bcc8, 0x24a2fffe, 0x24a2fffd) -- addiu $v0, $a1, -2 -> addiu $v0, $a1, -3
axInsnReplace(0x888bccc, 0x24a20002, 0x24a20003) -- addiu $v0, $a1, 2 -> addiu $v0, $a1, 3
axInsnReplace(0x888bce4, 0x24a2fffe, 0x24a2fffd) -- addiu $v0, $a1, -2 -> addiu $v0, $a1, -3

-- Gameplay

---- Relax tap window (configurable, PS1 default: 8, PSP default: 7)
local range = 10

-- ParaSceneInit
axInsnReplace(0x888ca80, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x888deb0, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88901cc, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88b0e18, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88b3134, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88b5450, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88b79b8, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88b9c18, 0x2403000e, 0x24030000 | (range * 2))
axInsnReplace(0x88ba448, 0x2403000e, 0x24030000 | (range * 2))


-- Support for analog stick
local pad = require("pad")

local fixupControls = function()
	local padBuf = axObj.GetGpr(gpr.sp) + 0x10
	local buttons = axObj.ReadMem32(padBuf + 0x4)
	local lx = axObj.ReadMem8(padBuf + 0x8)
	local ly = axObj.ReadMem8(padBuf + 0x9)
	
	if lx < 0x40 then
		buttons = buttons | pad.LEFT
	elseif lx > 0xc0 then
		buttons = buttons | pad.RIGHT
	end
	
	if ly < 0x40 then
		buttons = buttons | pad.UP
	elseif ly > 0xc0 then
		buttons = buttons | pad.DOWN
	end
	
	axObj.WriteMem32(padBuf + 0x4, buttons)
	axObj.SetGpr(gpr.a0, buttons)
end

axObj.AddHook(0x88715e0, 0x8fa40014, fixupControls)
axObj.AddHook(0x8871600, 0x3c02089b, fixupControls)

-- Fix poster on first level

local fixupPoster = function()
	local namePtr = axObj.GetGpr(gpr.v0) + 4
	local name = axObj.ReadMemStr(namePtr)
	
	if name == "./s1/kamon_l.i3s.psp.i3r" then
		local base = axObj.GetGpr(gpr.s5)
		if axObj.ReadMem32(base+0x520) == 0xc1700000 and axObj.ReadMem32(base+0x580) == 0xc1700000 and axObj.ReadMem32(base+0x598) == 0xc1700000 then
			axObj.WriteMem32(base+0x520, 0xc1720000) -- -15.0 -> -15.125
			axObj.WriteMem32(base+0x580, 0xc1720000) -- -15.0 -> -15.125
			axObj.WriteMem32(base+0x598, 0xc1720000) -- -15.0 -> -15.125
		end
	end
end

axObj.AddHook(0x882f578, 0x00561021, fixupPoster)

-- Global HighScore support

local HIGHSCORE = 0x8A33AD0 -- from CHiscoreMenu2d::Draw
local stagePlaying = false
local stageCompleted = false


local initHighScores = function()
	SaveData.highscores = {}
	for x = 1, 6*3 do
		table.insert(SaveData.highscores, 0xffffffff)
	end
end

local writeHighscores = function()
	if SaveData.highscores == nil then
		initHighScores()
	end
	
	for num = 0, 5 do 
		local saveIndex = (num * 3) + 1
		local dataIndex = HIGHSCORE + 0x4c + (0x10 * num)
		axObj.WriteMem32(dataIndex + 0, SaveData.highscores[saveIndex + 0])
		axObj.WriteMem32(dataIndex + 4, SaveData.highscores[saveIndex + 1])
		axObj.WriteMem32(dataIndex + 8, SaveData.highscores[saveIndex + 2])
	end
end

local updateHighscores = function(stage, score)
	if SaveData.highscores == nil then
		initHighScores()
	end
	
	local needsSave = true
	local saveIndex = ((stage - 1) * 3) + 1
	
	if SaveData.highscores[saveIndex] == 0xffffffff then
		SaveData.highscores[saveIndex] = score
	elseif SaveData.highscores[saveIndex] < score then
		SaveData.highscores[saveIndex+2] = SaveData.highscores[saveIndex+1]
		SaveData.highscores[saveIndex+1] = SaveData.highscores[saveIndex]
		SaveData.highscores[saveIndex] = score
	elseif SaveData.highscores[saveIndex+1] == 0xffffffff then
		SaveData.highscores[saveIndex+1] = score
	elseif SaveData.highscores[saveIndex+1] < score then
		SaveData.highscores[saveIndex+2] = SaveData.highscores[saveIndex+1]
		SaveData.highscores[saveIndex+1] = score
	elseif SaveData.highscores[saveIndex+2] == 0xffffffff then
		SaveData.highscores[saveIndex+2] = score
	elseif SaveData.highscores[saveIndex+2] < score then
		SaveData.highscores[saveIndex+2] = score
	else
		needsSave = false
	end
	
	if needsSave == true then
		emuObj.SaveConfig(SaveData)
	end
end

local resetHighScores = function()
	SaveData.highscores = nil
	writeHighscores()
	emuObj.SaveConfig(SaveData)
end

local checkHighscoresUpdate = function()
	local stage = axObj.GetGpr(gpr.s3)
	local status = axObj.GetGpr(gpr.v0)
	local stageData = 0xFFFFFFFF
	if status == 1 then
		stageCompleted = true	-- Finished stage in Cool mode, but stageCompleted doesn't get activated. Update flag.
	end

	if stagePlaying == true and stageCompleted == true then
		if stage == 6 then
			stageData = axObj.GetGpr(gpr.s1)	-- last stage (6) stores stage data in $s1 instead of $s0
		else
			stageData = axObj.GetGpr(gpr.s0)	-- stages 1 to 5
		end

		local score = axObj.ReadMem32(stageData+0x30) -- from drawScore
		if stage >= 1 and stage <= 6 then
			updateHighscores(stage, score)
--			print(string.format("Stage %d ended - Score: %d", stage, score))
		end
		stagePlaying = false
		stageCompleted = false
	end
end

local stageHighscoresStarted = function()
	local eventMode = axObj.ReadMem16(0x8a33a90) -- 0 = playing, 1 = demo, 2 = replay (ParaAppInit: 78C94 [233a90 + 88000000 = 8a33a90])
	local difficulty = axObj.ReadMem8(0x8a33a9e) -- 0 = normal, 1 = easy
	if eventMode == 0 and difficulty == 0 then -- playing and normal
		stagePlaying = true
	else
		stagePlaying = false
	end
	stageCompleted = false
end

local stageHighscoresEnded = function()
	stageCompleted = true
end

-- High Score hooks
axObj.AddHook(0x88897a8, 0x02003821, writeHighscores)			-- S_MenuGetCtrlClass case 14 (CSaveDialogMenu2d)
axObj.AddHook(0x88895f8, 0x02402821, writeHighscores)			-- S_MenuGetCtrlClass case 3 (CHiscoreMenu2d)
axObj.AddHook(0x88773ac, 0x3c0308a3, stageHighscoresStarted)	-- ParaActionSetHighEnable
axObj.AddHook(0x8886e40, 0x2442fffe, stageHighscoresEnded)		-- ParaEventDynGetNext
axObj.AddHook(0x888F338, 0x00409021, checkHighscoresUpdate)		-- ParaSceneRun_0
axObj.AddHook(0x8891654, 0x00409021, checkHighscoresUpdate)		-- ParaSceneRun_1
axObj.AddHook(0x88B22A0, 0x00409021, checkHighscoresUpdate)		-- ParaSceneRun_2
axObj.AddHook(0x88B45BC, 0x00409021, checkHighscoresUpdate)		-- ParaSceneRun_3
axObj.AddHook(0x88B68F0, 0x00409021, checkHighscoresUpdate)		-- ParaSceneRun_4
axObj.AddHook(0x88B8D9C, 0x00408021, checkHighscoresUpdate)		-- ParaSceneRun_5
