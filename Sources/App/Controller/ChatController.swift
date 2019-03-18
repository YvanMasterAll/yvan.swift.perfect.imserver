//
//  ChatController.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import StORM
import PerfectHTTP
import PostgresStORM
import PerfectWebSockets
import Turnstile

class ChatController : BaseController {
    
    //MARK: - 声明区域
    lazy var chatService: ChatService = {
        return ChatServiceImpl()
    }()
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/chat/socket", handler: self.handler())
        self.route.add(method: .get, uri: "\(baseRoute)/chat/socket", handler: self.handler())
        //MARK: - 直通
        self.route_ex.append("\(baseRoute)/chat/socket")
    }
}

//MARK: - 请求句柄
extension ChatController {
    
    //MARK: - 聊天句柄
    func handler() -> RequestHandler {
        return WebSocketHandler(handlerProducer: {(request: HTTPRequest,
            protocals: [String]) -> WebSocketSessionHandler? in
            return ChatSessionHandler(chatService: self.chatService)
        }).handleRequest
    }
}

//MARK: - 聊天管理
class ChatSessionHandler: WebSocketSessionHandler {
    
    //MARK: - 声明区域
    var socketProtocol: String?
    var chatService: ChatService
    
    init(chatService: ChatService) {
        self.chatService = chatService
    }
    
    func handleSession(request: HTTPRequest, socket: WebSocket) {
        socket.readStringMessage(continuation: { data, type, finished in
            guard let _ = data else { //接受到空消息, 连接丢失
                for (clientId, client) in ChatChannel.shared.clients { //移除客户端
                    if client.socket == socket {
                        ChatChannel.shared.removeClient(clientId: clientId)
                        break
                    }
                }
                return
            }
            do {
                guard let dataDict = try data?.jsonDecode() as? Dictionary<String, Any>,
                let userid = dataDict["sender"] as? Int,
                let token = dataDict["token"] as? String,
                let _cmd = dataDict["cmd"] as? String,
                let cmd = SocketCmdType.init(_cmd) else {
                    socket.callback(ResultSet.requestIllegal)
                    return
                }
                switch cmd { //命令类型
                case .register:
                    try request.user.login(credentials: AccessToken(string: token))
                    if ChatChannel.shared.clients["\(userid)"]?.socket != socket,
                        let uniqueid = request.user.authDetails?.account.uniqueID {
                        let user = User()
                        try user.get(uniqueID: uniqueid)
                        if userid == user.id {
                            ChatChannel.shared.addClient(client: ChatClient.init(clientId: "\(userid)", socket: socket))
                            socket.callback(Result(code: .success), cmd: cmd)
                            break
                        }
                    }
                    socket.callback(ResultSet.requestIllegal, cmd: cmd)
                case .chat:
                    if ChatChannel.shared.clients["\(userid)"]?.socket == socket,
                        let message = ChatMessage.fromSocketMessage(cmd: cmd, data: dataDict),
                        message.sender != message.receiver {
                        let result = self.handleChatMessage(message: message, source: dataDict)
                        socket.callback(result, cmd: cmd)
                    } else {
                        socket.callback(ResultSet.requestIllegal, cmd: cmd)
                    }
                case .list:
                    if ChatChannel.shared.clients["\(userid)"]?.socket == socket,
                        let pageindex = dataDict["pageindex"] as? Int,
                        let message = ChatMessage.fromSocketMessage(cmd: cmd, data: dataDict) {
                        let cursor: StORMCursor = request.cursor(pageindex: pageindex)
                        let result = self.handleChatMessage(cmd: cmd, message: message, cursor: cursor)
                        socket.callback(result, cmd: cmd)
                    } else {
                        socket.callback(ResultSet.requestIllegal, cmd: cmd)
                    }
                case .list_dialog:
                    if ChatChannel.shared.clients["\(userid)"]?.socket == socket,
                        let pageindex = dataDict["pageindex"] as? Int,
                        let message = ChatMessage.fromSocketMessage(cmd: cmd, data: dataDict) {
                        let cursor: StORMCursor = request.cursor(pageindex: pageindex)
                        let result = self.handleChatMessage(cmd: cmd, message: message, cursor: cursor)
                        socket.callback(result, cmd: cmd)
                    } else {
                        socket.callback(ResultSet.requestIllegal, cmd: cmd)
                    }
                default:
                    throw BaseError.invalidSocketCMD
                }
            } catch {
                print(error)
            }
            //Loopback, 等待接受下一条消息
            self.handleSession(request: request, socket: socket)
        })
    }

    //MARK: - 消息处理
    func handleChatMessage(message data: ChatMessage, source: [String: Any]) -> Result {
        switch data._dialogtype {   //会话类型
        case .single:               //单聊会话
            do {
                //会话判断
                let _dialogid = try chatService.dialog_exists(id1: data.sender, id2: data.receiver)
                if data.dialogid != "", let k = _dialogid, k != data.dialogid {
                    return ResultSet.requestIllegal
                } else if data.dialogid != "", _dialogid == nil {
                    return ResultSet.requestIllegal
                }
                if let dialogid = _dialogid { //会话存在
                    //创建标识
                    let messageid = UUID().uuidString
                    return try PostgresStORM.doWithTransaction(closure: { () -> Result in
                        //创建消息
                        let message = ChatMessage()
                        message.id = messageid
                        message.dialogid = dialogid
                        message.sender = data.sender
                        message.receiver = data.receiver
                        message.body = data.body
                        message.type = data.type
                        try message.insert(message.asData())
                        //更新会话
                        let dialog = ChatDialog()
                        try dialog.get(dialogid)
                        dialog.lastmessageid = messageid
                        try dialog.save()
                        //消息通知
                        if let client = ChatChannel.shared.clients["\(data.receiver)"] {
                            client.socket.callback(Result(code: .success,
                                                          data: message.toDict()), cmd: .receive)
                        }
                        //响应结果
                        var _source = source
                        _source["dialogid"] = dialogid
                        return Result(code: .success, data: _source)
                    })
                } else {
                    //判断用户是否存在
                    if try !chatService.user_exists(id: data.receiver) {
                        return Result.init(code: .userNotExists)
                    }
                    //创建标识
                    let dialogid = UUID().uuidString
                    let messageid = UUID().uuidString
                    return try PostgresStORM.doWithTransaction(closure: { () -> Result in
                        //创建会话
                        let dialog = ChatDialog()
                        dialog.id = dialogid
                        dialog.lastmessageid = messageid
                        dialog.type = .single
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
                        message.body = data.body
                        message.type = data.type
                        try message.insert(message.asData())
                        //消息通知
                        if let client = ChatChannel.shared.clients["\(data.receiver)"] {
                            client.socket.callback(Result(code: .success,
                                                          data: message.toDict()), cmd: .receive)
                        }
                        //响应结果
                        var _source = source
                        _source["dialogid"] = dialogid
                        return Result(code: .success, data: _source)
                    })
                }
            } catch {
                print(error)
                return ResultSet.serverError
            }
        }
    }
    
    //MARK: - 消息列表
    func handleChatMessage(cmd: SocketCmdType, message _data: ChatMessage, cursor: StORMCursor) -> Result {
        let data = _data
        switch cmd {
        case .list:
            switch data._dialogtype {
            case .single:
                do {
                    if data.dialogid == "" {
                        guard let _dialogid = try chatService
                            .dialog_exists(id1: data.sender, id2: data.receiver) else {
                                return Result(code: .dialogNotExists)
                        }
                        data.dialogid = _dialogid
                    }
                    let list = try chatService.message_list(dialogid: data.dialogid,
                                                            userid: data.sender, cursor: cursor)
                    return Result(code: .success, data: list)
                } catch {
                    print(error)
                    return ResultSet.serverError
                }
            }
        case .list_dialog:
            do {
                let list = try chatService.dialog_list(id: data.sender, dialogtype: data._dialogtype, cursor: cursor)
                return Result(code: .success, data: list)
            } catch {
                print(error)
                return ResultSet.serverError
            }
        default:
            return ResultSet.requestIllegal
        }
    }
}

//MARK: - 客户端
class ChatClient {
    
    //MARK: - 声明区域
    let clientId: String
    var socket: WebSocket
    
    init(clientId: String, socket: WebSocket) {
        self.clientId = clientId
        self.socket = socket
    }
}

//MARK: - 频道管理
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


