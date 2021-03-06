import Vapor

/// Register your application's routes here.
public func routes(_ router: Router) throws {
    // Example of configuring a controller
    let calendar = CalendarController()
    router.post(UserCreate.self, at: "create", use: calendar.create)
    router.post(UserCreate.self, at: "join", String.parameter, use: calendar.join)
    router.get("get_planned", String.parameter, use: calendar.getPlanned)
    router.post(User.self, at: "update", use: calendar.update)
}
