import Vapor
import FluentPostgreSQL

/// Controls basic CRUD operations on `Todo`s.
final class CalendarController {
    /// Returns a list of all `Todo`s.
    func create(_ req: Request, _ userCreate: UserCreate) throws -> Future<User> {
        let sessionId = User.createSessionId()

        return User(sessionId: sessionId, userId: User.createUserId(sessionId: sessionId, username: userCreate.username), username: userCreate.username, dates: userCreate.dates).save(on: req)
    }
    
    func join(_ req: Request, _ userCreate: UserCreate) throws -> Future<User> {
        let sessionId = try req.parameters.next(String.self)
        
        return User(sessionId: sessionId, userId: User.createUserId(sessionId: sessionId, username: userCreate.username), username: userCreate.username, dates: userCreate.dates).save(on: req)
    }
    
    func getPlanned(_ req: Request) throws -> Future<[User]> {
        let sessionId: String = try req.parameters.next(String.self)
        return User.query(on: req).filter(\.sessionId == sessionId).all()
    }
    
    func update(_ req: Request, _ user: User) throws -> Future<User> {
        let promise = req.eventLoop.newPromise(User.self)
        let future = User.query(on: req).filter(\.sessionId == user.sessionId).filter(\.userId == user.userId).first()
        future.whenSuccess { (userDB) in
            if let userDB = userDB {
                userDB.update(username: user.username, dates: user.dates)
                userDB.save(on: req).cascade(promise: promise)
            } else {
                promise.fail(error: Abort(.badRequest, reason: "No data in database."))
            }
        }
        future.whenFailure { (error) in
            promise.fail(error: Abort(.badRequest, reason: error.localizedDescription))
        }
        return promise.futureResult
    }
}
