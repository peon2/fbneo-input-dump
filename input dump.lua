dofile("input dump modules.lua")

local P1 = {}
local P2 = {}
local Players = {P1 = P1, P2 = P2}
local fs
local output = "out.txt" -- output file

local framec = 0

local iget, igetdown = joypad.get, joypad.getdown

function run()

	local attack
	local player
	local pos
	for i,v in pairs(iget()) do -- check every button
		player = i:sub(1,2)
		attack = i:sub(4):gsub(" ","")
		pos = P1[1][attack]
		if pos then
			if not v then
				if (Players[player][3][pos][1] ~= Players[player][3][pos][2]) then -- if button has been held for some amount of time
					fs:write(player.." "..P1[2][pos].." "..Players[player][3][pos][1].." "..(Players[player][3][pos][2]+1).."\n")
				end
				Players[player][3][pos][1] = framec
			end
			Players[player][3][pos][2] = framec
		end
	end
	
	if framec%1000 == 0 then
		fs:flush()
		collectgarbage("collect")
	end
	
	framec = framec+1
end


function cleanup()
	for i,v in pairs(Players) do
		for j,k in ipairs(v[3]) do
			if k[1] ~= k[2] then
				fs:write(i.." "..v[2][j].." "..v[3][j][1].." "..(v[3][j][2]+1).."\n")
			end
		end
	end
	fs:flush()
	collectgarbage("collect")
end

if inputmodules[emu.romname()] then

	P1[1] = inputmodules[emu.romname()][1]; -- Lookup table
	P1[2] = inputmodules[emu.romname()][2]; -- Output text
	
	P1[3] = {} -- Tracks framecounts on buttons
	for _, v in pairs(P1[1]) do -- initialize P1 array
		P1[3][v] = {}
		P1[3][v][1] = framec
		P1[3][v][2] = framec
	end
	
	P2[1] = inputmodules[emu.romname()][1];
	P2[2] = inputmodules[emu.romname()][2];
	
	P2[3] = {}
	for _, v in pairs(P2[1]) do -- initialize P2 array
		P2[3][v] = {}
		P2[3][v][1] = framec
		P2[3][v][2] = framec
	end

	fs = io.open(output,"w")

	emu.registerbefore(run)
	emu.registerexit(cleanup)

else 
	print(emu.romname() .. ": game not supported")
end

