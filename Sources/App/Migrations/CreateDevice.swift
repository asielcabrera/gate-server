//
//  CreateDevice.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 11/28/23.
//

import Fluent

extension Device {
    struct Migration: AsyncMigration {
        var name: String { "CreateDevice" }
        
        func prepare(on database: Database) async throws {
            try await database.schema("device")
                .id()
                .field("name", .string, .required)
                .field("status", .string, .required)
                .field("user_id", .uuid, .required, .references("users", "id"))
                .create()
        }
        
        func revert(on database: Database) async throws {
            try await database.schema("device").delete()
        }
    }
}

//TODO: add location property and location Model
