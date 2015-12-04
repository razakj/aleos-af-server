local sched = require 'sched'
local log = require('log')
local server = require 'server'
local devicetree = require 'devicetree'
local modbus_lib = require 'modbus_lib'
local custom = require 'custom'

local LOGNAME = "IOSERVER"
log.setlevel("DEBUG", "IOSERVER")

local function setHandleError(res, msg)
	log(LOGNAME, "ERROR", "%s", msg)
	res.result = -1
	res.errors[table.getn(res.errors)+1] = tostring(msg)
end

local function handleRequest(data, reply)
	local res = { result = 0, errors = {}, get = {}, modbus = {}}
	if data.set then
		for k,v in pairs(data.set) do
			if v.name then
				if v.value then
					devicetree.set(v.name, v.value)
					log(LOGNAME, "INFO", "%s changed to %s", v.name, v.value)
				else
					setHandleError(res, string.format("Value for %s is missing", v.name))
				end
			else
				setHandleError(res, string.format("Key for one of the SET commands is missing"))
			end	
		end
	end
	if data.get then
		for k,v in pairs(data.get) do
			res.get[v] = tostring(devicetree.get(v))
		end
	end
	if data.modbus then
		for k,v in pairs(data.modbus) do
			if v.address then
				local port = 502
				if v.port then
					port = v.port
				end
				modbus_lib.init(v.address, port, 5, 5)
				if v.read then
					res.modbus[v.address] = {}
					log(LOGNAME, "INFO", "Modbus reading from %s", v.address)
					for k1,v1 in pairs(v.read) do
						if v1.type then
							if v1.address then
								local length = 1
								local modbusResult, err
								if v1.length and v1.type ~= "digitaloutput" and v1.type ~= "digitalinput" then
									length = v1.length
								end
								if v1.type == "holdingregister" then
									modbusResult, err = modbus_lib.readHoldingRegister(v1.address, length)
								elseif v1.type == "inputregister" then
									modbusResult, err = modbus_lib.readInputRegisters(v1.address, length)
								elseif v1.type == "digitaloutput" then
									modbusResult, err = modbus_lib.readCoils(v1.address)
								elseif v1.type == "digitalinput" then
									modbusResult, err = modbus_lib.readDiscreteInputs(v1.address)
								elseif v1.type == "long" then
									modbusResult, err = modbus_lib.readLong(v1.address, length)
								elseif v1.type == "float" then
									modbusResult, err = modbus_lib.readFloat(v1.address, length)
								else
									setHandleError(res, string.format("Unknown type under device %s and address %s", v.address, v1.address))
								end
								if err then
									setHandleError(res, string.format("Error while reading modbus register (%s, %s, %s)", v.address, v1.address, v1.type))
								else
									if modbusResult then
										local realLength = length
										local currLength = table.getn(res.modbus[v.address])
										if v1.type == "long" or v1.type == "float" then
											realLength = length / 2
										end
										for i=1, realLength do
											local realAddress = v1.address + i - 1
											if v1.type == "long" or v1.type == "float" then
												realLength = v1.address + ((i-1)*2) 
											end
											local singleRes = {
												address = realLength,
												type = v1.type,
												value = modbusResult[i]
											}
											res.modbus[v.address][currLength+i] = singleRes
										end
									end
								end
							else
								setHandleError(res, string.format("Missing address type under device %s and type %s", v.address, v1.type))
							end
						else
							setHandleError(res, string.format("Missing register type under device %s", v.address))
						end
					end
				end
				if v.write then
					log(LOGNAME, "INFO", "Modbus writing to %s", v.address)
					for k1,v1 in pairs(v.write) do
						if v1.type then
							if v1.address then
								if v1.value then
									if v1.type == "digitaloutput" then
										modbus_lib.writeCoil(v1.address, v1.value)
									elseif v1.type == "float" then
										modbus_lib.writeFloat(v1.address, v1.value)
									elseif v1.type == "long" then
										modbus_lib.writeLong(v1.address, v1.value)
									elseif v1.type == "holdingregister" then
										modbus_lib.writeRegister(v1.address, v1.value)
									else
										setHandleError(res, string.format("Unknown type under device %s and address %s", v.address, v1.address))
									end
								else 
									setHandleError(res, string.format("Missing value for %s/%s/%s", v1.type, v1.address, v.address))
								end
							else
								setHandleError(res, string.format("Missing address type under device %s and type %s", v.address, v1.type))
							end
						else
							setHandleError(res, string.format("Missing register type under device %s", v.address))
						end
					end
				end
				modbus_lib.close()
			else
				setHandleError(res, string.format("Modbus address is missing"))
			end
		end
	end
	reply(res)
end

local function healthCheck()
	custom.init()
	local interval = 3600
	if custom.HEALTH_CHECK_INTERVAL then
		interval = custom.HEALTH_CHECK_INTERVAL
	end
	while true do
		if custom.healthCheck then
			custom.healthCheck()
		end
		sched.wait(interval)
	end
end

local function run()
	assert(devicetree.init())
	server.init("*", 8888, "secret_key")
	server.listen(handleRequest)
end

local function main()
  sched.run(run)
  sched.run(healthCheck)
  sched.loop()
end

main()

