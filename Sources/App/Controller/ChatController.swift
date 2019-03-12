//
//  ChatController.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import PerfectHTTP
import PostgresStORM
import PerfectWebSockets

class ChatController : BaseController {
    
    //MARK: - 声明区域
    lazy var chatService: ChatService = {
        return ChatServiceImpl()
    }()
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/chat", handler: self.handler())
        self.route.add(method: .get, uri: "\(baseRoute)/chat", handler: self.handler())
    }
}

extension ChatController {
    
    //MARK: - 请求句柄
    func handler() -> RequestHandler {
        return WebSocketHandler(handlerProducer: {(request: HTTPRequest,
            protocals: [String]) -> WebSocketSessionHandler? in
            return ChatSessionHandler(chatService: self.chatService)
        }).handleRequest
    }
}


//MARK: - Test

class ChatClient {
    
    //MARK: - 声明区域
    let clientId: String
    var socket: WebSocket
    
    init(clientId: String, socket: WebSocket) {
        self.clientId = clientId
        self.socket = socket
    }
}

class ChatChannel {
    
    //MARK: - 单例
    static let shared = ChatChannel()
    private init() { }
    
    //MARK: - 添加客户端
    func addClient(client: ChatClient) {
        self.removeClient(clientId: client.clientId)
        self.clients[client.clientId] = client
    }
    
    //MARK: - 移除客户端
    func removeClient(clientId: String) {
        guard let oldClient = self.clients[clientId] else { return }
        oldClient.socket.close()
        self.clients.removeValue(forKey: clientId)
    }
    
    //MARK: - 私有成员
    var clients = [String: ChatClient]()
}

class ChatSessionHandler: WebSocketSessionHandler {
    
    //MARK: - 声明区域
    var socketProtocol: String?
    var chatService: ChatService
    
    init(chatService: ChatService) {
        self.chatService = chatService
    }
    
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        socket.readStringMessage(continuation: { message, type, finished in
            guard let _ = message else { //接受到空消息, 连接丢失
                for (clientId, client) in ChatChannel.shared.clients { //移除客户端
                    if client.socket == socket {
                        ChatChannel.shared.removeClient(clientId: clientId)
                        break
                    }
                }
                return
            }
//            guard let userid = request.userid() else { //用户身份验证
//                socket.callback(ResultSet.requestIllegal)
//                socket.close()
//                return
//            }
            do {
                //yTest
                var userid: Int = 0
                if let _messageDict = try message?.jsonDecode() as? Dictionary<String, Any>,
                    let k = _messageDict["sender"] as? String,
                    let _userid: Int = k.toInt() {
                    userid = _userid
                } else {
                    socket.callback(ResultSet.requestIllegal)
                    socket.close()
                    return
                }
                if let messageDict = try message?.jsonDecode() as? Dictionary<String, Any>,
                    let k = messageDict["cmd"] as? String,
                    let cmd = SocketCmdType.init(k) {
                    switch cmd { //命令类型
                    case .register:
                        ChatChannel.shared.addClient(client: ChatClient.init(clientId: "\(userid)", socket: socket))
                        socket.callback(Result(code: .success))
                    case .chat:
                        if let message = ChatMessage.fromSocketMessage(sender: userid, data: messageDict),
                            message.sender != message.receiver {
                            let result = self.handleChatMessage(message: message)
                            socket.callback(result)
                        } else {
                            socket.callback(ResultSet.requestIllegal)
                        }
                    }
                } else {
                    socket.callback(ResultSet.requestIllegal)
                }
            } catch {
                print(error)
            }
            //Loopback, 等待接受下一条消息
            self.handleSession(request: request, socket: socket)
        })
    }

    //MARK: - 消息处理
    func handleChatMessage(message data: ChatMessage) -> Result {
        switch data._dialogtype {   //会话类型
        case .normal:               //普通会话
            switch data.type {      //消息类型
            case .normal:           //普通消息
                //会话判断
                let _dialogid = chatService.dialog_exists(id1: data.sender, id2: data.receiver)
                if data.dialogid != "", let k = _dialogid, k != data.dialogid {
                    return ResultSet.requestIllegal
                } else if data.dialogid != "", _dialogid == nil {
                    return ResultSet.requestIllegal
                }
                if let dialogid = _dialogid { //会话存在
                    //创建标识
                    let messageid = UUID().uuidString
                    do {
                        //创建消息
                        let message = ChatMessage()
                        message.id = messageid
                        message.dialogid = dialogid
                        message.sender = data.sender
                        message.receiver = data.receiver
                        message.message = data.message
                        message.type = .normal
                        try message.insert(message.asData())
                        //消息通知
                        if let socket = ChatChannel.shared.clients["\(data.receiver)"] {
                            socket.socket.callback(Result(code: .success, data: message.toDict()))
                        }
                        //响应结果
                        return Result(code: .success, data: message.toDict())
                    } catch {
                        print(error)
                        return ResultSet.serverError
                    }
                } else {
                    //判断用户是否存在
                    if !chatService.user_exists(id: data.receiver) {
                        return Result.init(code: .userNotExists)
                    }
                    //创建标识
                    let dialogid = UUID().uuidString
                    let messageid = UUID().uuidString
                    do {
                        return try PostgresStORM.doWithTransaction(closure: { () -> Result in
                            //创建会话
                            let dialog = ChatDialog()
                            dialog.id = dialogid
                            dialog.lastmessageid = messageid
                            dialog.type = .normal
                            try dialog.insert(dialog.asData())
                            //创建参与者
                            let participant = ChatParticipant()
                            participant.dialogid = dialogid
                            participant.p1 = min(data.sender, data.receiver)
                            participant.p2 = max(data.sender, data.receiver)
                            try participant.save()
                            //创建消息
                            let message = ChatMessage()
                            message.id = messageid
                            message.dialogid = dialogid
                            message.sender = data.sender
                            message.receiver = data.receiver
                            message.message = data.message
                            message.type = .normal
                            try message.insert(message.asData())
                            //消息通知
                            if let socket = ChatChannel.shared.clients["\(data.receiver)"] {
                                socket.socket.callback(Result(code: .success, data: message.toDict()))
                            }
                            //响应结果
                            return Result(code: .success, data: message.toDict())
                        })
                    } catch {
                        print(error)
                        return ResultSet.serverError
                    }
                }
            }
        }
    }
}



