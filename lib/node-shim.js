WebSocket = require("websocket").w3cwebsocket;
var savedProcess = process;

window.addEventListener('load', function() {
  process = savedProcess;
});
