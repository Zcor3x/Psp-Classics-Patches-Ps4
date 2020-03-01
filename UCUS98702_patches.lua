-- Lua 5.3
-- Title:   Parappa The Rapper PSP - UCUS-98702 (USA)
-- Author:  Ernesto Corvi

-- Changelog:
-- George added Moose antler adjustments (sept 8th)



apiRequest(1.0)	-- request version 1.0 API. Calling apiRequest() is mandatory.

local gpr		= require( "ax-gpr-alias" ) -- you can access Allegrex GPR by alias (gpr.a0 / gpr["a0"])
local pad		= require( "pad" ) -- pad state
local emuObj	= getEmuObject() -- emulator
local axObj		= getAXObject() -- allegrex

-- Set Texture Replacement Hash Mode for this title
emuObj.SetTextureHashMode("drawbounds")

-- Fixup additional songs path
local addOnPathHook = function()
	local pathPtr = axObj.GetGpr(gpr.a2)
	axObj.WriteMemStrZ(pathPtr, "ao0:/MUSIC/") -- reroute to add-on directory
end

axObj.AddHook(0x88c022c, 0x24c66de0, addOnPathHook)
axObj.AddHook(0x886ecc4, 0x24c6328c, addOnPathHook)

-- Accelerate some functions
axFuncReplace(0x883cd90, "I3dVecSet")
axFuncReplace(0x8849e14, "I3dRender__ReserveTrashQwc")
axFuncReplace(0x883cf48, "I3dVecAdd")
axFuncReplace(0x883cf10, "I3dVecScaleXYZ")
axFuncReplace(0x88520f4, "I3dGuSetMatrix_PSP")

-- Texture adjustments

--Fix little onion guy angry image globally. Can be tweaked a little more maybe.
emuObj.SetTextureScaleOffset("253ef7cc_14b32139_68_96_0.png", 1.0, 1.0, 3.0, 4.0)

-- PaRappa hands
emuObj.SetTextureScaleOffset("14e8e4af_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("3a5bf0d8_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("4319a856_49bf702a_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("4a57df32_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("4c96e238_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("57ecafdb_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("956351a4_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("d67ebce6_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("f2e8afb7_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("f9bbdbed_ed983c40_59_68_0.png", 1.0, 1.0, 0.0, 2.5)

emuObj.SetTextureScaleOffset("2cdfc73d_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("2f48f4a0_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("53fd2625_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("5191aa41_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("8780c959_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("29723ba4_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("a0e1dcf6_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("d9a8165b_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)
emuObj.SetTextureScaleOffset("f73ce335_454e82e9_60_71_0.png", 1.0, 1.0, 0.0, 2.5)

--xscale, yscale, xpos, ypos (larger numbers shrink)


--George

-- Left Antler
emuObj.SetTextureScaleOffset("e48bd34b_fb097c65_59_64_0.png", 1.0, 1.0, 0.0, 1.0)
emuObj.SetTextureScaleOffset("922d76ab_fb097c65_59_64_0.png", 1.0, 1.0, 0.0, 1.0)
emuObj.SetTextureScaleOffset("64f63948_fb097c65_59_64_0.png", 1.0, 1.0, 0.0, 1.0)


--Right Antler
emuObj.SetTextureScaleOffset("5b4cb82a_fb097c65_59_64_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("963df3b8_fb097c65_59_64_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("ab6e0e1e_fb097c65_59_64_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("6654582d_fb097c65_59_22_0.png", 1.0, 1.0, 1.0, 0.0)


--Mooseface
emuObj.SetTextureScaleOffset("df1748bf_f00d347d_135_83_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("c4688f0c_f00d347d_135_83_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("a2a88817_f00d347d_135_83_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("3845dcae_f00d347d_135_83_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("617aa504_f00d347d_135_83_0.png", 1.0, 1.0, 1.0, 0.0)
emuObj.SetTextureScaleOffset("7caaab59_f00d347d_135_83_0.png", 1.0, 1.0, 1.0, 0.0)



--Adam

-- PaRappa face
emuObj.SetTextureScaleOffset("d6208233_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("dada4bee_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("0e6bbfb9_e2dfb0ba_171_31_0.png", 1.00, 1.0, -0.1, 0.0) -- S3
emuObj.SetTextureScaleOffset("7fedfeff_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("6fcc6b58_e2dfb0ba_171_31_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("ed9bc143_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("c6761e6c_e2dfb0ba_171_31_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("b7006485_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("9ce11082_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("70982d7e_e2dfb0ba_171_31_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("6e3cfeb4_e2dfb0ba_170_30_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("23dfe393_e2dfb0ba_171_31_0.png", 1.005, 1.0, -0.1, 0.0)
emuObj.SetTextureScaleOffset("a812e8b6_a4a39739_170_30_0.png", 1.005, 1.0, 0.0, 0.0) -- S5
emuObj.SetTextureScaleOffset("802a2918_a4a39739_170_30_0.png", 1.005, 1.0, 0.0, 0.0) -- S5
emuObj.SetTextureScaleOffset("285d10e8_a4a39739_170_30_0.png", 1.005, 1.0, 0.0, 0.0) -- S5
emuObj.SetTextureScaleOffset("0ba3b6a9_a4a39739_170_30_0.png", 1.005, 1.0, 0.0, 0.0) -- S5
emuObj.SetTextureScaleOffset("3d28b91b_31cc1bc4_170_30_0.png", 1.005, 1.0, 0.0, 0.0) -- S5
emuObj.SetTextureScaleOffset("0dfbca0c_31cc1bc4_170_30_0.png", 1.005, 1.0, 0.0, 0.0) -- S5
emuObj.SetTextureScaleOffset("0950755d_31cc1bc4_170_30_0.png", 1.003, 1.0, 0.0, 0.0) -- S5

-- PaRappa body
emuObj.SetTextureScaleOffset("9ab3bd81_689b6bf7_76_5_0.png", 0.996, 1.0, 0.0, 0.0) -- neck
emuObj.SetTextureScaleOffset("0da1645e_a32ba683_187_20_0.png", 1.03, 1.0, -3.0, 0.0) -- arms/chest S1
emuObj.SetTextureScaleOffset("2ec6be54_31a101dc_188_21_0.png", 1.04, 1.0, -4.0, 0.0) -- arms/chest S3
emuObj.SetTextureScaleOffset("0ba3b6a9_a4a39739_170_30_0.png", 1.01, 1.0, 0.0, 0.0) -- left leg S3

-- Master Onion
emuObj.SetTextureScaleOffset("36878fe7_8a39da54_119_89_0.png", 0.982, 1.0, 1.0, 0.0) -- top of head
emuObj.SetTextureScaleOffset("9e695b86_8a39da54_119_89_0.png", 0.982, 1.0, 1.0, 0.0) -- top of head
emuObj.SetTextureScaleOffset("408f774a_de1416b1_87_40_0.png", 1.005, 1.0, 0.0, 0.0) -- right arm
emuObj.SetTextureScaleOffset("efa0254f_df3b94d7_39_39_0.png", 1.005, 1.0, -2.3, 0.0) -- right leg S5
emuObj.SetTextureScaleOffset("a482231c_f5be00aa_39_39_0.png", 1.005, 1.0, -0.2, 0.0) -- left leg S5
emuObj.SetTextureScaleOffset("96fc00ca_674aeb5a_88_78_0.png", 1.005, 1.0, 0.0, -0.8) -- right arm S6
emuObj.SetTextureScaleOffset("96fc00ca_3a16923a_88_78_0.png", 1.005, 1.0, 0.0, -0.8) -- right arm S6

-- Flee
emuObj.SetTextureScaleOffset("c23aaa45_02af2339_205_123_0.png", 0.980, 1.0, 1.0, 0.0) -- Eyes & hat
emuObj.SetTextureScaleOffset("66370dd6_02af2339_205_123_0.png", 0.980, 1.0, 1.0, 0.0) -- Eyes & hat
emuObj.SetTextureScaleOffset("d6ee9c05_02af2339_205_123_0.png", 0.980, 1.0, 1.0, 0.0) -- Eyes & hat
emuObj.SetTextureScaleOffset("c5ac713b_02af2339_205_123_0.png", 0.980, 1.0, 1.0, 0.0) -- Eyes & hat
emuObj.SetTextureScaleOffset("882fc765_06bd7520_48_6_0.png", 0.996, 1.0, -0.1, 0.0) -- Neck S3
emuObj.SetTextureScaleOffset("841852a8_fb60ff68_48_6_0.png", 0.996, 1.0, -0.2, 0.0) -- Neck S5
emuObj.SetTextureScaleOffset("c874f0e7_9e970241_108_42_0.png", 0.978, 1.0, 3.4, 0.9) -- Lower shirt S5
