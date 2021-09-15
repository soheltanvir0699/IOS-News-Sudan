//
//  AppDatabase.swift
//  IOS News App
//
//  Created by GajoDev on 28/11/2018.
//  Copyright © 2018 GajoDev. All rights reserved.
//

import Foundation
import GRDB

/// A type responsible for initializing the application database.
///
/// See AppDelegate.setupDatabase()
struct AppDatabase {
    
    /// Creates a fully initialized database at path
    static func openDatabase(atPath path: String) throws -> DatabaseQueue {
        // Connect to the database
        // See https://github.com/groue/GRDB.swift/#database-connections
        dbQueue = try DatabaseQueue(path: path)
        
        // Use DatabaseMigrator to define the database schema
        // See https://github.com/groue/GRDB.swift/#migrations
        try migrator.migrate(dbQueue)
        
        return dbQueue
    }
    
    /// The DatabaseMigrator that defines the database schema.
    ///
    /// This migrator is exposed so that migrations can be tested.
    // See https://github.com/groue/GRDB.swift/#migrations
    static var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("createFavorite") { db in
            // Create a table
            // See https://github.com/groue/GRDB.swift#create-tables
            try db.create(table: "favorite") { t in
                // An integer primary key auto-generates unique IDs
                t.column("nid", .integer).primaryKey()
                
                // Sort player names in a localized case insensitive fashion by default
                // See https://github.com/groue/GRDB.swift/#unicode
                t.column("news_title", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("news_image", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("news_date", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("news_description", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("cat_id", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("category_name", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("content_type", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("comments_count", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("video_id", .text).notNull().collate(.localizedCaseInsensitiveCompare)
                t.column("video_url", .text).notNull().collate(.localizedCaseInsensitiveCompare)                
            }
        }
                
        //        // Migrations for future application versions will be inserted here:
        //        migrator.registerMigration(...) { db in
        //            ...
        //        }
        
        return migrator
    }
}

