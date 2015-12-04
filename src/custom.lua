local log = require('log')
local modbus_lib = require 'modbus_lib'
local http = require("socket.http")

-- TEMPLATE OF THIS FILE MUST REMAIN UNCHANGED HOWEVER IMPLEMENTATION OF INDIVIDUAL FUNCTIONS
-- SHALL BE CHANGED TO SUIT NEEDS OF INDIVIDUAL APPLICATIONS
local custom = {}

custom.HEALTH_CHECK_INTERVAL = 5 -- in seconds
http.TIMEOUT = 10 -- HTTP request timeout 
local MISSED_PINGS_LIMIT = 3 -- Upper limit of allowed missed pings 
local missedPings = 0 -- Missed pings counter
local url = "http://192.168.8.1/ping.html" -- URL address to "ping"

local LOGNAME = "IOSERVER"
log.setlevel("DEBUG", "IOSERVER")

function custom.init()
	-- Init routines
end

function custom.healthCheck()
	print("HEALTH CHECK")
	local r, c, h = http.request { method = "HEAD", url = url }
	if not r then
		missedPings = missedPings + 1
		log(LOGNAME, "WARNING", "(HEALTH_CHECK) Missed ping to %s - %d out of %d", url, missedPings, MISSED_PINGS_LIMIT)
	else
		missedPings = 0	
	end
	
	if missedPings == MISSED_PINGS_LIMIT then
		log(LOGNAME, "ERROR", "(HEALTH_CHECK) Missed pings limit to %s reached - %d out of %d", url, missedPings, MISSED_PINGS_LIMIT)
	end 
end

return custom