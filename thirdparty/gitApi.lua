--[[
	BetterMovementAPI

	Copyright (C) 2015 siiikooo0743

	This programm is part of the OpenCcPrograms-project and licensed under the GPLv3,
	see LicenseDetails for more details and LICENSE for the complete license.

	Author: siiikooo0743
	Website: https://github.com/siiikooo0743/OpenCcPrograms
	Pastebin: https://pastebin.com/KwgQQGQ7
	
	This program is like the pastebin program, that is included in ComputerCraft, 
	but is used to download from GitHub
]]

local function printUsage()
    print( "Usage:" )
    print( "GitHub get <GitHub file> <filename> [<NotToUpdate>]" )
    print( "->Copies the file")
    print( "GitHub update [file]")
    print( "->Updates the or if not specifed all files(of all Repositorys)")
    print( "GitHub remove <file>")
    print( "->Removes file from update Function but not from Computer")
    print( "GitHub rep <GitHub repository>")
    print( "->Sets the repository")
end
     
local function getPath(sCode)
  file = fs.open(".GitHub/Rep", "r")
  s = file.readLine()
  s = "https://raw.github.com/" .. s
  s = s .. "/master/"
  s = s .. sCode
  return(s)
end

local function setRep(sRep)
  file = fs.open(".GitHub/Rep", "w")
  file.writeLine(sRep)
  file.close()
  print("Set Repository to:" .. sRep)
end
     
local function getFile(sCode, sFile) 
	local sPath = shell.resolve( sFile )
	if fs.exists( sPath ) then
        fs.delete( sPath )
	end
    
	-- GET the contents from GitHub.com
	
	local response = http.get(getPath(sCode))
    
	if response then
                      
        local sResponse = response.readAll()
        response.close()
           
        local file = fs.open( sPath, "w" )
        file.write( sResponse )
        file.close()
           
        print( "Downloaded:"..sFile )
           
	else
        print( "Failed:"..sFile)
	end
		
end
	
local function update(name)
	file = fs.open(".GitHub/update/"..name, "r")
	code = file.readAll()
	file.close()
	getFile(code, name)
end 	
    
    
local tArgs = { ... }

shell.run("clear")
    
if(#tArgs < 1) then
    printUsage()
    return
end

if(tArgs[1] == "help") then
    printUsage()
    return
end

fs.makeDir(".GitHub/update")
     
if(tArgs[1] == "rep") then
   if not (#tArgs == 2) then
   	printUsage()
   	return
   end
   setRep(tArgs[2])
   return
end
     
if not http then
    print( "GitHub requires http API" )
    print( "Set enableAPI_http to true in ComputerCraft.cfg" )
    return
end
          
if(tArgs[1] == "update") then
    if (#tArgs == 1) then
   	files = fs.list(".GitHub/update")
    else
    	files = {}
    	for i = 2, #tArgs, 1 do
			files[i - 1] = tArgs[i]
    	end
    end
    
    for _, file in ipairs(files) do 
	update(file)
    end 
    return
end
          
if(tArgs[1] == "remove") then
    if not (#tArgs == 2) then
   	printUsage()
   	return
    end
    fs.delete(".GitHub/update/"..tArgs[2])
    print("Removed <" .. tArgs[2] .. "> from update")
    return
end	
          
if not (fs.exists(".GitHub/Rep")) then
    print( "Please set the repository.")
    return
end
          
if(tArgs[1] == "get") then
   if (#tArgs > 4 or #tArgs < 3) then
   	printUsage()
   	return
   end
   
   -- Determine file to download
   local sCode = tArgs[2]
   local sFile = tArgs[3]
   
   print( "Connecting to GitHub.com... " )
   getFile(sCode, sFile)
   
   if(not(#tArgs == 4) or not(tArgs[4] == "true")) then
   	file = fs.open(".GitHub/update/"..sFile, "w")
   	file.write(sCode)
   	file.close()
   end
   return
end

printUsage()
