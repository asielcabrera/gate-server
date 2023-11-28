//
//  User.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 11/27/23.
//

import Fluent
import Vapor

final class User: Model, Content {
    static let schema = "users"

    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String

    @Field(key: "email")
    var email: String

    @Field(key: "password_hash")
    var passwordHash: String
    
    @Children(for: \.$user)
        var devices: [Device]

    init() { }

    init(id: UUID? = nil, name: String, email: String, passwordHash: String) {
        self.id = id
        self.name = name
        self.email = email
        self.passwordHash = passwordHash
    }
}


extension User {
    struct Public: Content {
        let id: UUID
        let name: String
        let email: String
    }
    
    public func asPublic() throws -> Public {
        return .init(id: try self.requireID(), name: self.name, email: self.email)
    }
    
}


extension User: ModelAuthenticatable {
    static let usernameKey = \User.$email
    static let passwordHashKey = \User.$passwordHash

    func verify(password: String) throws -> Bool {
        try Bcrypt.verify(password, created: self.passwordHash)
    }
}

extension User {
    func generateToken() throws -> UserToken {
        try .init(
            value: [UInt8].random(count: 16).base64,
            userID: self.requireID()
        )
    }
}
