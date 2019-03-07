//
//  WebSocket+Extension.swift
//  App
//
//  Created by Yiqiang Zeng on 2019/3/5.
//

import Foundation
import PerfectWebSockets

extension WebSocket {
    
    //MARK: - 响应数据
    func callback(_ result: Result) {
        do {
            let messageStr = try result.toDict().jsonEncodedString()
            self.sendStringMessage(string: messageStr, final: true, completion: { })
        } catch {
            print(error)
        }
    }
}
