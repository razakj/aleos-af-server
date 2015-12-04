var net = require('net');

var testData = {
	authKey: "secret_key",
	get: [
		"system.aleos.io.analog1.raw",
		"system.aleos.io.relay1"
	],
	set: [
		{name: "system.aleos.io.relay2", value: 1}
	],
	modbus: [
		{
			address: "127.0.0.1",
			port: 502,
			read: [
				{ type: "long", address: 5000, length: 64 },
				{ type: "float", address: 9000, length: 64 }
			],
			write: [
				{ type: "long", address: 5000, value: 400000 }
			]
		}
	]
}

var client = net.connect(8888, '192.168.8.2', function() {
  console.log('connected to server!');
  client.write(JSON.stringify(testData)+'\r\n');
});

client.on('data', function(data) {
	console.log('Received: ' + data);
	client.end();
});

client.on('close', function() {
	console.log('Connection closed');
});