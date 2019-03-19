//
//  FileController.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/18.
//

import Foundation
import StORM
import Turnstile
import TurnstilePerfect

class FileController : BaseController {
    
    override init() {
        super.init()
        
        //MARK: - 路由
        self.route.add(method: .post, uri: "\(baseRoute)/file/chat/image",
            handler: self.chat_image_upload())
    }
}

extension FileController {
    
    //MARK: - 聊天图片
    public func chat_image_upload() -> RequestHandler {
        return { request, response in
            if let url = request.upload_image_chat() {
                let params: [String: Any] = [
                    "body": url,
                    "_id": request.param(name: "_id") ?? ""
                ]
                response.callback(Result(code: .success, data: params))
            } else {
                response.callback(ResultSet.requestIllegal)
            }
        }
    }
}
