import PerfectLib
import PerfectHTTP
import PerfectHTTPServer

import PerfectRequestLogger
import PostgresStORM
import PerfectTurnstilePostgreSQL
import TurnstilePerfect

//创建服务
let server = HTTPServer()

//请求日志
RequestLogFile.location = "./log/request.log"

//数据库配置
PostgresConnector.host        = "localhost"
PostgresConnector.username    = "postgres"
PostgresConnector.password    = "19920213"
PostgresConnector.database    = "postgres"
PostgresConnector.port        = 5432

//用户实体
let auth = AuthAccount()
try? auth.setup()

//用户认证实体
tokenStore = AccessTokenStore()
try? tokenStore?.setup()

//路由
let baseController = BaseController()
let testController = TestController()
let authWebRoutes = makeWebAuthRoutes() //权限路由[Web]
let authJsonRoutes = makeJSONAuthRoutes(ApiRoot) //权限路由[Api]

server.addRoutes(authWebRoutes)
server.addRoutes(authJsonRoutes)
server.addRoutes(baseController.route)
server.addRoutes(testController.route)

//过滤器, 顺序很重要
var authenticationConfig = AuthenticationConfig()
authenticationConfig.include("\(ApiRoot)/check")
authenticationConfig.include("\(ApiRoot)/getpassword")
authenticationConfig.exclude("\(ApiRoot)/login")
authenticationConfig.exclude("\(ApiRoot)/register")
let authFilter = AuthFilter(authenticationConfig) //认证过滤器

let pturnstile = TurnstilePerfectRealm() //Realm 过滤器, 用于认证存储

let myLogger = RequestLogger() //日志过滤器

server.setRequestFilters([pturnstile.requestFilter])
server.setResponseFilters([pturnstile.responseFilter])
server.setRequestFilters([(authFilter, .high)])
server.setRequestFilters([(myLogger, .high)])
server.setResponseFilters([(myLogger, .low)])

//启动服务
server.serverPort = 8181 //端口
server.documentRoot = "./webroot" //Web 目录

do {
    try server.start()
} catch PerfectError.networkError(let err, let msg) {
    print("网络异常: \(err) \(msg)")
}







