# aleos-af-server
Solution to provide remote control via socket server for [Sierra Wireless](http://source.sierrawireless.com/) routers supporting [Aleos AF](http://source.sierrawireless.com/resources/airlink/aleos_af/aleos_af_home/).
## Overview
Main purpose of this application is to provide remote access and control capabilities of Sierra Wireless routers from 3rd party application using simple JSON-based API.

Following functionality is supported via the API
* Get or Set router paramters accessible via [DeviceTree](https://github.com/razakj/aleos-af-server/blob/master/docs/devicetree.txt).
* Use modbus to communicate with the router or any other modbus-enabled device on the remote network. (*functionality limited at the moment*)

## API
The API is based on JSON.

### Request API
* authKey(*string*): Authentication key specified by the server to provide authentication facility. 
* get(*array*): List of requested DeviceTree parameters
* set(*object*): List of key/value objects specifying DeviceTree parameter name and value to be set

**TBD**
