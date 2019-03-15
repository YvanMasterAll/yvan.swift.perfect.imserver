
	function init() {
		output = document.getElementById("output");
		userid = document.getElementById("userid");
		userid.value = Math.floor((Math.random()*10)+1);
		chatid = document.getElementById("chatid");
		input = document.getElementById("chatinput");
		clients = document.getElementById("clients");
		requestJoin();
	}
	function requestJoin() {
    	connectWebsocket(ws_params.channel);
    }
               
	function connectWebsocket(channel, clientid) {
		websocket = new WebSocket(wsUri);
		websocket.onopen = function(evt) { onOpen(evt) };
		websocket.onclose = function(evt) { onClose(evt) };
		websocket.onmessage = function(evt) { onMessage(evt) };
		websocket.onerror = function(evt) { onError(evt) };
	}

	function onOpen(evt) {
        console.log(ws_params);
		if(ws_params.dialog_id == undefined){
			writeToScreen("Connecting");
			valuetosend = {
				"cmd": "register", 
				"sender": userid.value*1, 
				"msg": "joining channel "+ws_params.channel, 
				"channelid":ws_params.channel
			};
		}
		websocket.send(JSON.stringify(valuetosend));
        writeToScreen('<span style="color: red;">Registering hello from Saroar:'+ws_params.channel+' <\/span> ');
	}

	function onClose(evt) {
		writeToScreen("DISCONNECTED");
	}

	function onMessage(evt) {
		json_data = JSON.parse(evt.data);
		console.log(json_data);
		code = json_data["code"];
		msg = json_data["msg"];
		data = json_data["dataDict"];
		if(code == 200) {
			if(data) {
				ws_params.dialog_id = data["dialogid"]
				if(userid.value == data["sender"]) {
					writeToScreen('<span style="color: blue;">' + userid.value + ': ' + data["body"] +'<\/span>');
				} else if (userid.value == data["receiver"]) {
					writeToScreen('<span style="color: blue;">' + data["sender"] + ': ' + data["body"] +'<\/span>');
				}
			} else {
				//register success
			}
		} else {
			//failed
		}
		writeToScreen('<span style="color: blue;">Received: ' + msg +'<\/span>');
	}

	function onError(evt) {
		writeToScreen('<span style="color: red;">ERROR:<\/span> ' + evt.data);
	}

	function doSend() {
		writeToScreen('<span style="color: red;">SENDING:<\/span> ' + input.value);
        valuetosend = {
        	"cmd": "chat", 
        	"sender": userid.value*1, 
        	"receiver": chatid.value*1,
        	"body": input.value, 
        	"dialogid": ws_params.dialog_id, 
        	"dialogtype": "single",
        	"type": "text",
        	"channelid": ws_params.channel
        };
        console.log(valuetosend);
        websocket.send(JSON.stringify(valuetosend));
	}
	
	function writeToScreen(message) {
		output.innerHTML += '<br>' +message;
	}
	function addToClients(message) {
		ws_params.client_list.push(message);
		clients.innerHTML = ws_params.client_list.join('<br>')+'<br>';
	}
	function removeClient(message) {
		//clientToRemove = JSON.parse(message);
		//clients_list = ws_params.clients.remove(clientToRemove);
		ws_params.client_list.splice(ws_params.client_list.indexOf(message), 1);
		clients.innerHTML = ws_params.client_list.join('<br>')+'<br>';
	}
	function registerResponse(response) {
		resp = JSON.parse(response);
		writeToScreen('<span style="color: blue;">Connection: '+resp["result"]+'<\/span>');
		ws_params.client_id = resp.params.client_id;
		ws_params.messages = resp.params.messages;
		if(resp.params.client_list != undefined){
			ws_params.client_list = resp.params.client_list
			listClients(ws_params.client_list)
		} else {
			ws_params.client_list = new Array();
		}
	}
