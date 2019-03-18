//
//  Const.swift
//  IMServerPackageDescription
//
//  Created by yiqiang on 2018/1/20.
//

import Foundation

//MARK: - 根路由
let baseRoute           = "/api/v1"

//MARK: - 日志文件
let baseLog             = "./log/request.log"

//MARK: - 配置文件
let baseConfig          = "./config/ApplicationConfiguration.json"

//MARK: - 默认配置
var baseDBHost          = "localhost"
var baseServerPort      = 8181
var baseDBPort          = 5432
var baseDBUsername      = ""
var baseDBPassword      = ""
var baseDBName          = ""
var baseURL             = "http://192.168.1.6:8181"
var baseDomain          = ""
var baseDocument        = "webroot"

//MARK: - 上传位置
var baseUploadChatImage = "upload/chat/images"

//MARK: - 用户信息
let baseNickname        = "用户"
let baseAvatar          = "static/avatar.png"

//MARK: - 页面配置
let basePageLimit       = 10

//MARK: - 枚举类型
protocol BaseType {
    var value: String { get }
}
public enum Gender: BaseType {      //性别
    
    case male, female
    
    public var value: String {
        switch self {
        case .male              : return "男"
        case .female            : return "女"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "男"                : self = .male
        case "女"                : self = .female
        default                  : return nil
        }
    }
}
public enum Status: BaseType {      //状态
    
    case normal, delete, unread, read
    
    public var value: String {
        switch self {
        case .normal            : return "正常"
        case .delete            : return "删除"
        case .unread            : return "未读"
        case .read              : return "已读"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "正常"              : self = .normal
        case "删除"              : self = .delete
        case "未读"              : self = .unread
        case "已读"              : self = .read
        default                  : return nil
        }
    }
}
public enum Whether: BaseType {     //是否
    
    case y, n
    
    public var value: String {
        switch self {
        case .y                 : return "是"
        case .n                 : return "否"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "是"                : self = .y
        case "否"                : self = .n
        default                  : return nil
        }
    }
}
public enum MessageType: BaseType { //消息类型
    
    case text, image
    
    public var value: String {
        switch self {
        case .text               : return "文本"
        case .image              : return "图片"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "文本", "text"       : self = .text
        case "图片", "image"      : self = .image
        default                  : return nil
        }
    }
}
public enum DialogType: BaseType {  //会话类型
    
    case single
    
    public var value: String {
        switch self {
        case .single              : return "单聊"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "单聊", "single"      : self = .single
        default                   : return nil
        }
    }
}
public enum SocketCmdType {         //命令类型, WebSocket
    
    case register, chat, receive, list, list_dialog
    
    public var value: String {
        switch self {
        case .register          : return "注册"
        case .chat              : return "聊天"
        case .receive           : return "接收"
        case .list              : return "列表"
        case .list_dialog       : return "会话"
        }
    }
    
    init?(_ value: String) {
        switch value {
        case "注册", "register"   : self = .register
        case "聊天", "chat"       : self = .chat
        case "列表", "list"       : self = .list
        case "接收", "receive"    : self = .receive
        case "会话", "list_dialog": self = .list_dialog
        default                   : return nil
        }
    }
}

//MARK: - 异常类型
public enum BaseError: Error {
    
    case invalidDigestString        //无效的加密字串
    case invalidSocketCMD           //无效的通讯命令
}
