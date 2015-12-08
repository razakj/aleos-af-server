# aleos-af-server
Solution to provide remote control via socket server for [Sierra Wireless](http://source.sierrawireless.com/) routers supporting [Aleos AF](http://source.sierrawireless.com/resources/airlink/aleos_af/aleos_af_home/).
## Overview
Main purpose of this application is to provide remote access and control capabilities of Sierra Wireless routers from 3rd party application using simple JSON-based API.

Following functionality is supported via the API
* Get or Set router paramters accessible via [DeviceTree](https://github.com/razakj/aleos-af-server/blob/master/docs/devicetree.txt).
* Use modbus to communicate with the router or any other modbus-enabled device on the remote network. (*functionality limited at the moment*)

## Architecture
Aleos-af-server is a simple http socket server listening on configurable interface and port capable of handling only one request at the time. By default it listens at *all the interfaces* and port *8888* It consists of following modules
* Socket server module with authenticator
* Main module with request handler (interface and port shall be configured here before deploying to the device)
* [JSON parser by Jeffrey Friedl](http://regex.info/blog/lua/json)
* Custom module provides template for custom logic ie. Network Health Check
* Modbus communciation module

## API
The API is based on JSON itnernally parsed to Lua objects.

### Request
* authKey(*string*): Authentication key specified by the server to provide authentication facility. 
* get(*array*): List of router's parameters to get.
  * string: Parameter name defined by [DeviceTree](https://github.com/razakj/aleos-af-server/blob/master/docs/devicetree.txt).
* set(*object*): List of key/value objects specifying DeviceTree parameter name and value to be set.
  * string: Parameter name defined by [DeviceTree](https://github.com/razakj/aleos-af-server/blob/master/docs/devicetree.txt).
  * value: Value to be applied to parameter.
* modbus(*array*): List of modbus devices, connection information and registers to read/write
  * address: Modbus device address on remote lan
  * port: Modbus server port
  * read(*array*): List of registers, their addresses and length to read
    * type: Enum 'digitaloutput', 'digitalinput', 'holdingregister', 'inputregister'
    * address: Modbus register address
    * length: Number of registers to read
  * write(*array*): List of registers to write to
    * type: Enum 'digitaloutput', 'digitalinput', 'holdingregister', 'inputregister'
    * address: Modbus register address
    * value: Value to be written

### Response
* result(*integer*): 0 if request was successful or -1 if at least one error has occured.
* errors(*array*): List of string formated error messages
* get(*array*): List of requested router's values
  * string: Parameter name
  * value: Paremeter's value
* modbus(*object*): Modbus devices requested via read modbus command. Each device is represented as property - with address as property name - containing array of result specified as below
  * address: Register address
  * type: Register type
  * value: Register value

## Custom module
Custom module has been added to provide basic workflow and template for any sort of custom operations required to be executed by the server without need to change core modules.

The custom module is executed in different scheduler than rest of the application.

### init()
Always called during the application initialization.

### healthCheck()
Health Check is a function executed in configurable intervals via *HEALTH_CHECK_INTERVAL* variable to execute any sort of periodic task. It is called healthCheck as we've used it for fail-safe check - In case another device is not accessible then perform some action. This is very helpful in conjunction with [aleos-af-client](https://github.com/razakj/aleos-af-client)

## Notes
* Write commands are always executed before read commands.

## Example and Testing
### Node.JS
See the *test* folder for Node.JS script used for testing and interfacing with aleos-af-server. You'll need to download [Node.JS](http://nodejs.org/) and run the script using
```javascript
node test.js
```
Do not forget to change IP address/DNS name and port the server is running on.
### Aleos-af-client
See [aleos-af-client](https://github.com/razakj/aleos-af-client) for further details.

## Credentials
* [Lua JSON parse](http://regex.info/blog/lua/json)
* [Aleos AF](http://source.sierrawireless.com/resources/airlink/aleos_af/aleos_af_home/)
