import FluentPostgreSQL
import Vapor

final class UserCreate: Content {
    var username: String
    var dates: [Int]
}

final class User: PostgreSQLModel {
    /// The unique identifier for this `Todo`.
    var id: Int?

    /// A title describing what this `Todo` entails.
    var sessionId: String
    var userId: String
    var username: String
    var dates: [Int]

    /// Creates a new `Todo`.
    init(sessionId: String, userId: String, username: String, dates: [Int]) {
        self.sessionId = sessionId
        self.userId = userId
        self.username = username
        self.dates = dates
    }
    
    func update(username: String, dates: [Int]) {
        self.username = username
        self.dates = dates
    }
    
    static func createSessionId() -> String {
        let code = UInt.random(in: 0..<100)
        let sessionIdDecoded = "\(Date().timeIntervalSince1970)_\(code)"
        guard let data = sessionIdDecoded.data(using: String.Encoding.utf8) else {
            return ""
        }

        return data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters).base64URLEscaped()
    }
    
    static func createUserId(sessionId: String, username: String) -> String {
        let code = UInt.random(in: 0..<100)
        let userIdDecoded = "\(sessionId)_\(Date().timeIntervalSince1970)_\(username)_\(code)"
        guard let data = userIdDecoded.data(using: String.Encoding.utf8) else {
            return ""
        }
        return data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters).base64URLEscaped()
    }
}

/// Allows `Todo` to be used as a dynamic migration.
extension User: PostgreSQLMigration { }

/// Allows `Todo` to be encoded to and decoded from HTTP messages.
extension User: Content { }

/// Allows `Todo` to be used as a dynamic parameter in route definitions.
extension User: Parameter { }
