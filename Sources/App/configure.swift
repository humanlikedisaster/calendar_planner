import FluentPostgreSQL
import Vapor

/// Called before your application initializes.
public func configure(_ config: inout Config, _ env: inout Environment, _ services: inout Services) throws {
    // Register providers first
    try services.register(FluentPostgreSQLProvider())

    // Register routes to the router
    let router = EngineRouter.default()
    try routes(router)
    services.register(router, as: Router.self)
    
    var contentConfig = ContentConfig.default()
    
    let jsonEncoder = JSONEncoder()
    jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
    let jsonDecoder = JSONDecoder()
    jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
    
    /// Register JSON encoder and content config
    contentConfig.use(encoder: jsonEncoder, for: .json)
    contentConfig.use(decoder: jsonDecoder, for: .json)

    services.register(contentConfig)

    // Register middleware
    var middlewares = MiddlewareConfig() // Create _empty_ middleware config
    // middlewares.use(FileMiddleware.self) // Serves files from `Public/` directory
    middlewares.use(ErrorMiddleware.self) // Catches errors and converts to HTTP response
    services.register(middlewares)

    var databases = DatabasesConfig()
    if let url = Environment.get("DATABASE_URL") {
      // configuring database
        let databaseConfig:
            PostgreSQLDatabaseConfig = PostgreSQLDatabaseConfig(url: url, transport: .unverifiedTLS)!
        let postgresql = PostgreSQLDatabase(config: databaseConfig)
        databases.add(database: postgresql, as: .psql)
    } else {
      
    }
    services.register(databases)

    // Register the configured SQLite database to the database config.

    // Configure migrations
    var migrations = MigrationConfig()
    migrations.add(model: User.self, database: .psql)
    services.register(migrations)
}
