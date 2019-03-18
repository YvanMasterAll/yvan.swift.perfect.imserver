//
//  HTTPRequest+Extension.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import StORM
import PerfectHTTP
import PerfectLib

extension HTTPRequest {
    
    //MARK: - 获取用户标识
    public func userid() -> Int? {
        if let uid = self.scratchPad["userid"] as? Int {
            return uid
        }
        return nil
    }
    
    //MARK: - 分页指针
    public func cursor() -> StORMCursor {
        var cursor = StORMCursor(limit: basePageLimit, offset: 0)
        if let limit =  self.param(name: "limit")?.toInt() {
            cursor.limit = limit
        }
        if let page = self.param(name: "page")?.toInt() {
            cursor.offset = (page - 1)*cursor.limit
        }
        return cursor
    }
    public func cursor(pageindex: Int) -> StORMCursor {
        var cursor = StORMCursor(limit: basePageLimit, offset: 0)
        cursor.offset = (pageindex - 1)*cursor.limit
        return cursor
    }
    
    //MARK: - 图片上传
    public func upload_image_chat() -> String? {
        guard let uploads = postFileUploads, uploads.count == 1 else {
            return nil
        }
        let upload = uploads[0]
        let file = File(upload.tmpFileName)
        defer { file.close() }
        guard let suffix = upload.fileName.split(".").last else { return nil }
        let path = "\(baseUploadChatImage)/\(UUID().uuidString).\(suffix)"
        do {
            let _ = try file.moveTo(path: "\(baseDocument)/\(path)", overWrite: true)
            return path
        } catch {
            return nil
        }
    }
}
