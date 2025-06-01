-- ----------------------------------------------------------------------------
-- 
-- Workfile: exroulette.lua
-- Created by: E Jet
-- Free licence (C) 2025 E Jet. All rights not reserved.
-- 
-- Global mod stuff. This script is executed on server shit,
-- from server.lua EXECUTE_SCRIPT.
-- 
-- Dear content designer or modder who wtumbled across this shit
-- This is genuinely the worst code i have written in my entire life
-- Do not read this
-- Do not try to understand it
-- Do not try to fix it
-- You will have an aneurysm (and autism)
-- - E Jet
-- 
-- ----------------------------------------------------------------------------
--  $Id: exroulette.lua, v1.0 2025/05/30 20:28:00 axeble Exp $
-- ----------------------------------------------------------------------------



local function ModFileInit()
	LOG("[I] ======================================")
	LOG("[I]             MOD FILE INIT!")
	LOG("[I] ======================================")

	local NAME = "ExRouletteMod"
	local VERSION = "1.0"
	local BUILD = "250530b"

	println("[I] ")
	println("[I] === "..NAME.." v"..VERSION.." ["..BUILD .."] ===")
	println("[I] ")
	LOG("[I] ")
	LOG("[I] === "..NAME.." v"..VERSION.." ["..BUILD .."] ===")
	LOG("[I] ")
end

ModFileInit()


ER_MaxSoundVol = 80
ER_MinSoundVol = 30


ER_PlayerItemSlots = {
	CVector(865.200, 266.800, 715.500),
	CVector(865.200, 266.800, 728.500),
	CVector(865.200, 266.800, 741.000)
}

ER_DealerItemSlots = {
	CVector(840, 266.800, 715.500),
	CVector(840, 266.800, 728.500),
	CVector(840, 266.800, 741.000)
}



ER_GUNbank = {0,0,0,0,0,0,0,0}
ER_GENbank = {0,0,0,0,0,0,0,0}

ER_DEALERITEMSnames = {}
ER_DEALERITEMSobjectNames = {}

function ER_ReloadShellBanks()
    ER_GUNbank = {0,0,0,0,0,0,0,0}
    ER_GENbank = {0,0,0,0,0,0,0,0}
end

function ER_GenerateBankShells(bAllLive)
    local bankPos = 1
    while ER_GENbank[bankPos]~=nil do
        local shell = math.random(0,1)
        ER_GENbank[bankPos] = shell
        bankPos=bankPos+1
    end
    --println(TableToString(ER_GENbank, nil, 1))
    local cutBank = random(0,getn(ER_GENbank))
    if (cutBank>0) and (7>cutBank) then
        for i=1, cutBank do
           table.remove(ER_GENbank)
        end
    end
    bankPos=1
    local isEmpty, isOverhead = true, true
    while ER_GENbank[bankPos]~=nil do
        if ER_GENbank[bankPos]==1 then
            isEmpty = false
            break
        end
        bankPos=bankPos+1
    end
    bankPos=1
    while ER_GENbank[bankPos]~=nil do
        if ER_GENbank[bankPos]==0 then
            isOverhead = false
            break
        end
        bankPos=bankPos+1
    end
    if isEmpty==true then
        --println("bank empty! replace {1} shell to 1")
        ER_GENbank[1] = 1
    end
    if isOverhead==true then
        --println("bank very hot! replace {2} shell to 0")
        ER_GENbank[2] = 0
    end
	bankPos=1
	if bAllLive==true then
		while ER_GENbank[bankPos]~=nil do
			ER_GENbank[bankPos] = 1
			bankPos=bankPos+1
		end
	elseif bAllLive==false then
		while ER_GENbank[bankPos]~=nil do
			ER_GENbank[bankPos] = 0
			bankPos=bankPos+1
		end
	end
    println("bank shells: "..TableToString(ER_GENbank, nil, 1))
    --ER_ReloadShellBanks()
end

function ER_LoadShellsInGun(bRandomSort)
    --ER_GenerateBankShells()
    --println("gen "..TableToString(ER_GENbank, nil, 1))
    if bRandomSort==true then
        local gottedGENbank = ER_GENbank
        for i = getn(gottedGENbank), 2, -1 do
            local j = math.random(1, i)
            gottedGENbank[i], gottedGENbank[j] = gottedGENbank[j], gottedGENbank[i]
        end
        local suffleGUNbank = gottedGENbank
        ER_GUNbank = suffleGUNbank
    else
        ER_GUNbank = ER_GENbank
    end
    --println("gun "..TableToString(ER_GUNbank, nil, 1))
    --ER_ReloadShellBanks()
end

function ER_SHOOT()
    --println("gun "..TableToString(ER_GUNbank, nil, 1))
    local shell = nil
    local chamber = ER_GUNbank[getn(ER_GUNbank)]
    if chamber==1 then
        shell = true
		GL_LastLiveShell = true
        table.remove(ER_GUNbank)
        --println("BOOM")
		--journal
		if not IsQuestItemPresent("roulette_q_liveshell") then
			AddQuestItem("roulette_q_liveshell")
		end
    elseif chamber==0 then
        shell = false
		GL_LastLiveShell = false
        table.remove(ER_GUNbank)
        --println("lucky")
		--journal
		if not IsQuestItemPresent("roulette_q_blankshell") then
			AddQuestItem("roulette_q_blankshell")
		end
    end
    --if shell==nil then println("empty gun!") end
    return shell
end

function ER_GetAnyLiveRoundsInGUNbank()
	local Exists = false
	for i=1, getn(ER_GUNbank) do
		if ER_GUNbank[i]==1 then
			Exists = true
			break
		end
	end

	return Exists
end

function ER_GetAmountLiveRoundsInGUNbank()
	local Skoka = 0
	for i=1, getn(ER_GUNbank) do
		if ER_GUNbank[i]==1 then
			Skoka = Skoka + 1
		end
	end

	return Skoka
end

function ER_ChanceLiveShell()
	local SkokaEst = ER_GetAmountLiveRoundsInGUNbank()
	local aMaximum = getn(ER_GUNbank)
	local Chance = (SkokaEst / aMaximum) * 100
	--println(SkokaEst.." / "..aMaximum.." :: "..(SkokaEst - aMaximum).." = "..Chance)
	return Chance
end

function ER_CalcRandomPodskazka()
	local reversedGUNbank = ER_GUNbank
	local reversedTable = {}
	local length = getn(reversedGUNbank)
	for i, v in ipairs(reversedGUNbank) do
		reversedTable[length - i + 1] = v
	end
	reversedGUNbank = reversedTable
	local allShells = getn(reversedGUNbank)
	local randomShell = math.random(allShells)
	local shell = reversedGUNbank[randomShell]

	--println("shell "..randomShell.." is "..shell)

	local strVal = ""
	if randomShell==1 then strVal = "ПЕРВЫЙ" end
	if randomShell==2 then strVal = "ВТОРОЙ" end
	if randomShell==3 then strVal = "ТРЕТИЙ" end
	if randomShell==4 then strVal = "ЧЕТВЁРТЫЙ" end
	if randomShell==5 then strVal = "ПЯТЫЙ" end
	if randomShell==6 then strVal = "ШЕСТОЙ" end
	if randomShell==7 then strVal = "СЕДЬМОЙ" end
	if randomShell==8 then strVal = "ВОСЬМОЙ" end

	return strVal, shell
end



function m()
	RuleConsole("/map roulettemap")
end


function t_concatinateRotations(quaternion, x,y,z)
	--TActivate("GUN_holder")
	LOG("output: "..tostring(quaternion * EulerToQuaternion(x,y,z)), quaternion)
end


function t_upper(s)
	local str=""
	for i=1,string.len(s) do
		local byte=string.byte(s,i)
		local char=string.char(byte)
		if(byte>= 97)and(byte<=122)then char=string.char(byte-32) end -- Латинские буквы
		if(byte>=224)and(byte<=255)then char=string.char(byte-32) end -- Русские буквы
		if(byte==184)              then char=string.char(byte-16) end -- Русская ё
		str=str..char
	end
	return str
end
function tu()
	local a = "ebanaya exmachina suka ya tebya nenaviju"
	LOG(a)
	a = t_upper(a)
	LOG(a)

	local a = "анальная пиздопроёбина"
	LOG(a)
	a = t_upper(a)
	LOG(a)
end






--///////////////////////////////////////////////////////////////////////////////
--
--						ExplorerMod ИМПОРТИРОВАННЫЕ ФУНКЦИИ!!!
--
--///////////////////////////////////////////////////////////////////////////////



--Функция E Jet'а
--Возвращает позицию CVector как среднее арифметическое между другими точками CVector, выбирает средний Y если boolY = true, иначе ноль на ландшафте
--listCVectorPozs = {CVector(1.111, 2.222, 3.333), CVector(1.111, 2.222, 3.333)}
--listObjectNames = {"Team_vehicle_0", "Team_vehicle_1"}
function GetAverageArithmeticCVectorBy(listCVectorPozs, listObjectNames, boolY)
	--println(GetAverageArithmeticCVectorBy({CVector(1,0,0), CVector(0,1,0), CVector(0,0,1)}, nil, false))
	local Gde = CVector(0,0,0)
	local Kto = {CVector(1,0,0), CVector(0,1,0), CVector(0,0,1)}

	if type(listCVectorPozs)=="table" then
		Kto = listCVectorPozs
		listObjectNames = nil
	end
	if type(listObjectNames)=="table" then
		Kto = listObjectNames
		listCVectorPozs = nil
	end

	local Skoka = getn(Kto)
	if 2>Skoka then 
		Kto = GenListForProtCopy(tostring(Kto[1]), 2)
		Skoka = getn(Kto)
	end
	
	local n = 1
	local SummaX = 0
	local SummaY = 0
	local SummaZ = 0
	while Kto[n]~=nil do
	--for i, Object in ipairs(Kto) do

	--println("vhod")
	--println(Kto[n])
		if type(Kto[n])=="string" then
			local GetObj = GetEntityByName(Kto[n])
			if GetObj then
				SummaX = SummaX + tonumber(GetObj:GetPosition().x)
				SummaY = SummaY + tonumber(GetObj:GetPosition().y)
				SummaZ = SummaZ + tonumber(GetObj:GetPosition().z)
			else
				SummaX = SummaX + ParseCVectorForX(Kto[n], 0)
				SummaY = SummaY + ParseCVectorForY(Kto[n], 0)
				SummaZ = SummaZ + ParseCVectorForZ(Kto[n], 0)
			end
		else
			SummaX = SummaX + Kto[n].x
			SummaY = SummaY + Kto[n].y
			SummaZ = SummaZ + Kto[n].z
		end
		n=n+1
	end

	if not (SummaZ==0 and SummaY==0 and SummaX==0) then
		Gde.x = SummaX / Skoka
		Gde.z = SummaZ / Skoka
		if boolY==true then
			Gde.y = SummaY / Skoka
		else
			Gde.y = g_ObjCont:GetHeight(Gde.x, Gde.z)
		end
	end

	return Gde
end
--Функция E Jet'а
--Возвращает сгенерированный лист {} с stringPrototype в количестве равным intAmount
function GenListForProtCopy(stringPrototype, intAmount)
	local List = {}
	if not intAmount then intAmount = 1 end
	for i=1, intAmount do
		List[i] = stringPrototype
	end
	return List
end
--Функции E Jet'а
--Функции возвращают координаты цвектора по отдельности
--CVector - в это надо передать строкой позицию объекта без надписи цвектор: 
--tostring(GetPlayerVehicle():GetPosition())
--IsStrings - это надо "1" или нет "0" строку на выходе
--E Jet: нахуя, если есть Pos.x, Pos.y, Pos.z??? не спрашивайте
--Upd: E Jet: а вот не нихуя, пригодилось таки емае, не зря писал фичу (парсит гет позишн без цвектора, полезно для составления листов)
function ParseCVectorForX(CVector, IsString)
	--Пример CVector: '(1.111, 2.222, 3.333)'
	--Вернет: 1.111
	if not CVector then
		return nil
	else
		--"парсерим" координаты
		CVector = tostring(CVector)
		local findzap = string.gsub(CVector, ",", "", 3)
		local findzapStr = tostring(findzap)
		local strLen = string.len(findzapStr)
		local readCords = string.sub(findzapStr, 2, strLen - 1)
		local readCordsStr = tostring(readCords)
		local findSpace1 = string.gsub(readCordsStr, " ", "A", 1)
		local findSpace1Str = tostring(findSpace1)
		local findA = string.find(findSpace1Str,"A")
		local CoordX = string.sub(findSpace1Str, 1, findA - 1)
		local CoordXStr = tostring(CoordX)
		--println(CoordXStr)
		local CoordXNum = tonumber(CoordXStr)

		if IsString==1 or IsString==true then
			return tostring(CoordXNum)
		else
			return CoordXNum
		end
	end
end
function ParseCVectorForY(CVector, IsString)
	--Пример CVector: '(1.111, 2.222, 3.333)'
	--Вернет: 2.222
	if not CVector then
		return nil
	else
		--"парсерим" координаты
		CVector = tostring(CVector)
		local findzap = string.gsub(CVector, ",", "", 3)
		local findzapStr = tostring(findzap)
		local strLen = string.len(findzapStr)
		local readCords = string.sub(findzapStr, 2, strLen - 1)
		local readCordsStr = tostring(readCords)
		local findSpace1 = string.gsub(readCordsStr, " ", "A", 1)
		local findSpace1Str = tostring(findSpace1 )
		local findSpace2 = string.gsub(findSpace1Str, " ", "B", 1)
		local findSpacesStr = tostring(findSpace2)
		local findA = string.find(findSpacesStr,"A")
		local findB = string.find(findSpacesStr,"B")
		local CoordY = string.sub(findSpacesStr, findA + 1, findB - 1)
		local CoordYStr = tostring(CoordY)
		--println(CoordYStr)
		local CoordYNum = tonumber(CoordYStr)

		if IsString==1 or IsString==true then
			return tostring(CoordYNum)
		else
			return CoordYNum
		end
	end
end
function ParseCVectorForZ(CVector, IsString)
	--Пример CVector: '(1.111, 2.222, 3.333)'
	--Вернет: 3.333
	if not CVector then
		return nil
	else
		--"парсерим" координаты
		CVector = tostring(CVector)
		local findzap = string.gsub(CVector, ",", "", 3)
		local findzapStr = tostring(findzap)
		local strLen = string.len(findzapStr)
		local readCords = string.sub(findzapStr, 2, strLen - 1)
		local readCordsStr = tostring(readCords)
		local findSpace1 = string.gsub(readCordsStr, " ", "A", 1)
		local findSpace1Str = tostring(findSpace1 )
		local findSpace2 = string.gsub(findSpace1Str, " ", "B", 1)
		local findSpacesStr = tostring(findSpace2)
		local CoordsLen = string.len(findSpacesStr)
		local findB = string.find(findSpacesStr,"B")
		local CoordZ = string.sub(findSpacesStr, findB + 1, CoordsLen)
		local CoordZStr = tostring(CoordZ)
		--println(CoordZStr)
		local CoordZNum = tonumber(CoordZStr)

		if IsString==1 or IsString==true then
			return tostring(CoordZNum)
		else
			return CoordZNum
		end
	end
end

--Функция из мода "Армада" (дополненная)
--Возвращает тейбл(лист) как строку
--modo = дизайн границ(скобок) вокруг значениев тейблов
--deep = глубина распарсинга, 1 - {"a","b"}; 2 - {{"a","b"},{"1","2"}}
--itemsAmount = сколько ожидается элементов в одном {}
function TableToString(table, modo, deep, itemsAmount)
	local endString = "{"
	local tableLength
	local d,s=1,1
	if itemsAmount==nil then itemsAmount=2 end
	if type(table)=="table" then
		tableLength = getn(table)
		if deep==1 then
			for i=1, tableLength do
				if type(table[i])=="string" or type(table[i])=="number" then
					if modo==1 then
						endString = endString.."'"..table[i].."'"
					elseif modo==2 then
						endString = endString.."В¶"..table[i].."В¶"
					else
						endString = endString..'"'..table[i]..'"'
					end
				else
					endString = endString..table[i]
				end
	
				if i==tableLength then
					endString = endString.."}"
				else
					endString = endString..", "
				end
			end
		elseif deep==2 then
			s=1
			while table[s] do
				d=1
				while table[s][d] do
					if d>itemsAmount then 
						endString = endString.."{" 
						d=1
						break
					end
					--println("S "..s)
					--println("D "..d)
					if type(table[s][d])=="string" or type(table[s][d])=="number" then
						if modo==1 then
							endString = endString.."'"..table[s][d].."'"
						elseif modo==2 then
							endString = endString.."В¶"..table[s][d].."В¶"
						else
							endString = endString..'"'..table[s][d]..'"'
						end
					else
						endString = endString..table[s][d]
					end
		
					if type(table[s][d+1])=="string" or type(table[s][d+1])=="number" then
						endString = endString..","
					elseif s==tableLength then
						endString = endString.."}"
					elseif table[s+1][d]==nil then
						endString = endString.."}"
					else
						endString = endString.."},{"
					end
					d=d+1
				end
				s=s+1
			end
		end
		if deep==2 then
			endString = "{"..endString.."}"
		end
	else
		endString = '{"idi nahui eto ne massiff)))0)"}'
		println(endString)
	end
	--println(endString)
	return endString
end

--Функция из мода "Армада" 
--Возвращает тейбл(лист) из строки strVal
function StringToTable(strVal)
	local endTable = strVal
	endTable = string.gsub(endTable, "В¶", "'")
	local funcTableCode = loadstring("local t = "..endTable.."; return t")
	endTable = funcTableCode()

	return endTable
end


--Функция E Jet'a
--Преобразовывает углы Эйлера (градусы) в углы кватерниона.
--Возвращает Quaternion(), принимает градусы по отдельности.
--Принтит в лог результат, если bLOG = true.
function EulerToQuaternion(x,y,z,bLOG)
	if bLOG==true then
		LOG("[I] explorer.lua === EulerToQuaternion(): Input x: "..tostring(x)..", y: "..tostring(y)..", z: "..tostring(z))
	end
	--Преобразуем углы Эйлера из градусов в радианы
    local roll_rad = math.rad(x)
    local pitch_rad = math.rad(y)
    local yaw_rad = math.rad(z)

    --Вычисляем половины углов
    local halfRoll = roll_rad * 0.5
    local halfPitch = pitch_rad * 0.5
    local halfYaw = yaw_rad * 0.5

    --Вычисляем синусы и косинусы половины углов
    local cosRoll = math.cos(halfRoll)
    local sinRoll = math.sin(halfRoll)
    local cosPitch = math.cos(halfPitch)
    local sinPitch = math.sin(halfPitch)
    local cosYaw = math.cos(halfYaw)
    local sinYaw = math.sin(halfYaw)

    --Вычисляем кватернион
    local w = cosRoll * cosPitch * cosYaw + sinRoll * sinPitch * sinYaw
    local x = sinRoll * cosPitch * cosYaw - cosRoll * sinPitch * sinYaw
    local y = cosRoll * sinPitch * cosYaw + sinRoll * cosPitch * sinYaw
    local z = cosRoll * cosPitch * sinYaw - sinRoll * sinPitch * cosYaw

	--Результат Quaternion(w,x,y,z) будет неверным. 
	--В игре по умолчанию объекты смотрят на север и стандартное вращение (то бишь на север) равняется Quaternion(0,0,0,1)
	--Соответственно правильно будет Quaternion(x,y,z,w) при нулях на входе.
	--println(EulerToQuaternion(0,0,0))

	if bLOG==true then
		LOG("[I] explorer.lua === EulerToQuaternion(): Got Quaternion("..tostring(x)..", "..tostring(y)..", "..tostring(z)..", "..tostring(w)..")")
	end
	return Quaternion(x,y,z,w)
end

--Функция E Jet'a
--Преобразовывает углы кватерниона в углы Эйлера (градусы).
--Возвращает градусы по отдельности, принимает Quaternion().
--Принтит в лог результат, если bLOG = true.
--roll = x; pitch = y; yaw = z.
--local x,y,z = QuaternionToEuler(Quaternion) println(x) println(y) println(z)
function QuaternionToEuler(Quaternion,bLOG)
    --Получаем компоненты кватерниона
	Quaternion = QuaternionToTable(Quaternion)
    local x, y, z, w = Quaternion[1], Quaternion[2], Quaternion[3], Quaternion[4]
	if bLOG==true then
		LOG("[I] explorer.lua === QuaternionToEuler(): Input Quaternion("..x..", "..y..", "..z..", "..w..")")
	end
	--Вычисляем углы Эйлера (в радианах)
	--println("x "..x)
	--println("y "..y)
	--println("z "..z)
	--println("w "..w)
    local pitch = math.asin(2 * (w * y - z * x))

    --Проверяем, не вызывает ли это выход за пределы -1 и 1
	--println("pit "..pitch)
	--println("abs "..math.abs(pitch))
    if (math.abs(pitch) == (math.pi / 2)) or (math.abs(pitch) == -(math.pi / 2)) then
	--if math.abs(pitch) == (math.pi / 2) then
    --if math.abs(pitch)>=(-1.0000000001) or (-1.0000000001)>=math.abs(pitch) then
        local roll = 0
        local yaw = math.atan2(2 * (w * z + x * y), 1 - 2 * (y * y + z * z))
        --Возвращаем углы Эйлера в градусах
		--println("qqqqqqqqqqqqqqqqqqq")
		if bLOG==true then
			LOG("[I] explorer.lua === QuaternionToEuler(): Got x: "..math.deg(roll)..", y: "..math.deg(pitch)..", z: "..math.deg(yaw))
		end
		return math.deg(roll), math.deg(pitch), math.deg(yaw)
    end

    local roll = math.atan2(2 * (w * x + y * z), 1 - 2 * (x * x + y * y))
    local yaw = math.atan2(2 * (w * z + x * y), 1 - 2 * (z * z + y * y))

    --Возвращаем углы Эйлера в градусах
	if bLOG==true then
		LOG("[I] explorer.lua === QuaternionToEuler(): Got x: "..math.deg(roll)..", y: "..math.deg(pitch)..", z: "..math.deg(yaw))
	end
    return math.deg(roll), math.deg(pitch), math.deg(yaw)
end

--Функция E Jet'a
--Парсит кватернион в строку, чтобы затем вернуть лист (таблицу).
function QuaternionToTable(Quaternion)
    local retVal = string.sub(tostring(Quaternion), 2, string.len(tostring(Quaternion))-1)
	retVal = "{"..retVal.."}"

    return StringToTable(retVal)
end