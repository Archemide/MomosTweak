local table = require('__stdlib__/stdlib/utils/table')
if not momoIRTweak then momoIRTweak = {} end

momoIRTweak.modName = ""
momoIRTweak.dumpText = ""
momoIRTweak.dumpStack = {""}

momoIRTweak.indentAmount = 0

function momoIRTweak.Init(modName)
	momoIRTweak.modName = modName
end

function momoIRTweak.Log(str)
	log("MomoIRTweak => " .. str)
end

function momoIRTweak.GetName(obj) 
	if (type(obj) == "table") then
		return obj.name
	end
	return obj
end

function momoIRTweak.DeepCopy(tableToCopy)
	return table.deep_copy(tableToCopy)
end

function momoIRTweak.tableAddValueIfUnique(aTable, value)
	for _, v in pairs(aTable) do
	    if (v == value) then
	        return
	    end
	end
	table.insert(aTable, value)
end

function momoIRTweak.tableFindValue(aTable, value)
	for _, v in pairs(aTable) do
		if (v == value) then
			return true
		end
	end
	return false
end

function momoIRTweak.tableRemoveItem(aTable, value)
	for k,v in pairs(aTable) do
		if v == value then
			table.remove(aTable, k)
			return
		end
	end
end

function momoIRTweak.DumpTable(_table)
	if (type(_table) == "table") then
		for k, v in pairs(_table) do 
			momoIRTweak.indentAmount = momoIRTweak.indentAmount + 1
			local indent = ""
			for _ = 1, momoIRTweak.indentAmount do
				indent = indent .. "   "
			end
			momoIRTweak.AddStringToDumpStack("\n" .. indent .. tostring(k) .. ":")
			momoIRTweak.DumpTable(v)
			momoIRTweak.indentAmount = momoIRTweak.indentAmount - 1
		end
	else
		momoIRTweak.AddStringToDumpStack(" " .. tostring(_table)) 
	end
end

function momoIRTweak.AddStringToDumpStack(str)
	table.insert(momoIRTweak.dumpStack, str)
	for i = table.getn(momoIRTweak.dumpStack)-1, 1, -1 do
		if string.len(momoIRTweak.dumpStack[i]) > string.len(momoIRTweak.dumpStack[i + 1]) then
			break
		end
		momoIRTweak.dumpStack[i] = momoIRTweak.dumpStack[i] .. table.remove(momoIRTweak.dumpStack)
	end
end

function momoIRTweak.PrintDump()
	momoIRTweak.Log(tostring(momoIRTweak.dumpStack))
	momoIRTweak.dumpText = {""}
end

function momoIRTweak.PrintTable(_table)
	momoIRTweak.DumpTable(_table)
	momoIRTweak.PrintDump()
end
