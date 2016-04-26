local _Set = {}

function _Set.addToSet(set, val)
	if not _Set.setContains(set, val) then
    	set[val] = true
    	table.insert(set, val)
    else
    	print ("Value already in set, could not add.")
    end
end

function _Set.removeFromSet(set, val)
	if _Set.setContains(set, val) then
    	set[val] = nil
    	for i=1,#set do
    		if set[i] == val then
    			table.remove( set, i )
    		end
    	end
    else
    	print("Value not in set, could not remove.")
    end
end

function _Set.setContains(set, key)
    return set[key] ~= nil
end

function _Set.printSet( set )
	local string = "{"
	for k,v in pairs(set) do
		string = string .. tostring(v) .. ", "
	end
	string = string .. "}"
	print(string)
end

return _Set