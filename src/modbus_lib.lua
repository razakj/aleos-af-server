local modbustcp = require 'modbustcp'
local bit32 = require 'bit32'
local log = require('log') 
log.setlevel("INFO", "MODBUS")

local modbusdev = {}
local ADDRESS = "127.0.0.1"
local PORT = 502
local modbus_lib = {}
local LOGNAME = "MODBUS"

local function check_error(err)
	if err then
		log(LOGNAME, "ERROR", "An error has occured - %s", err) 
	end
end

--local function bit(p)
--  return 2 ^ (p - 1)  -- 1-based indexing
--end

local function check_read_value(data, err, length, decoder)
	local res
	if not err then
		res={string.unpack(data,string.format("<%s%s", decoder, length))}
		table.remove(res,1)
	else
		check_error(err)
	end
	return res, err
end

function modbus_lib.init(address, port, maxsocket, timeout) 
	ADDRESS = address
	PORT = port
	local cfg = {maxsocket = maxsocket, timeout = timeout}
	modbusdev = modbustcp:new('TCP', cfg)
end

function modbus_lib.close()
	modbusdev:close()
end

function modbus_lib.writeCoil(address, value) 
	local realValue
	local val = tonumber(value)
	if val then
		if val > 0 then
			realValue = true
		else 
			realValue = false
		end 
		_,err = modbusdev:writeSingleCoil(ADDRESS, PORT, 1, address, realValue)
		check_error(err)	
	end
end

function modbus_lib.writeFloat(address, value) 
	--local realAddress = 9000 + (address * 2);
	local pack = string.pack("<f1", value)
	_,err = modbusdev:writeMultipleRegisters(ADDRESS, PORT, 1, address, pack)
	check_error(err)
end

function modbus_lib.writeLong(address, value) 
	--local realAddress = 5000 + (address * 2);
	local pack = string.pack("<l1", value)
	_,err = modbusdev:writeMultipleRegisters(ADDRESS, PORT, 1, address, pack)
	check_error(err)
end

function modbus_lib.writeRegister(address, value) 
	_,err = modbusdev:writeSingleRegister(ADDRESS, PORT, 1, address, value)
	check_error(err)
end

function modbus_lib.readHoldingRegister(address, length)
	local data,err = modbusdev:readHoldingRegisters(ADDRESS, PORT, 1, address, length)
	return check_read_value(data, err, length, 'h')
end

function modbus_lib.readInputRegisters(address, length)
	local data,err = modbusdev:readInputRegisters(ADDRESS, PORT, 1, address, length)
	return check_read_value(data, err, length, 'h')
end

function modbus_lib.readCoils(address)
	local data,err = modbusdev:readCoils(ADDRESS, PORT, 1, address, 1)
	return check_read_value(data, err, 1, 'b')
end

function modbus_lib.readDiscreteInputs(address)
	local data,err = modbusdev:readDiscreteInputs(ADDRESS, PORT, 1, address, 1)
	return check_read_value(data, err, 1, 'b')
end

function modbus_lib.readLong(address, length)
	local res
	local data,err = modbusdev:readHoldingRegisters(ADDRESS, PORT, 1, address, length)
	if not err then
		res={string.unpack(data,string.format("<l%d", length))}
		table.remove(res,1)
	else
		check_error(err)
	end
	return res, err
end

function modbus_lib.readFloat(address, length)
	local res
	local data,err = modbusdev:readHoldingRegisters(ADDRESS, PORT, 1, address, length)
	if not err then
		res={string.unpack(data,string.format("<f%d", length))}
		table.remove(res,1)
	else
		check_error(err)
	end
	return res, err
end

return modbus_lib