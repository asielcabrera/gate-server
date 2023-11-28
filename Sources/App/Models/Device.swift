//
//  Device.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 11/28/23.
//

import Fluent
import Vapor

final class Device: Model, Content {
    static let schema = "device"
    
    @ID(key: .id)
    var id: UUID?

    @Field(key: "name")
    var name: String
    
    @Field(key: "status")
    var status: DeviceStatus
    
    @Parent(key: "user_id")
    var user: User

    init() { }

    init(id: UUID? = nil, name: String, status: DeviceStatus, userID: User.IDValue) {
        self.id = id
        self.name = name
        self.status = status
        self.$user.id = userID
    }
    
    convenience init(from create: Create) {
        self.init(name: create.name, status: .close, userID: create.userID ?? UUID())
    }
}

enum DeviceStatus: String, Codable {
    case open
    case close
}

extension Device {
    struct Public: Content {
        let id: UUID
        let name: String
        let status: DeviceStatus
    }
    
    public func asPublic() throws -> Public {
        return .init(id: try self.requireID(), name: self.name, status: self.status)
    }
}

extension Device {
    struct Create: Content {
        var name: String
        var userID: UUID?
    }
}

extension Device.Create: Validatable {
    static func validations(_ validations: inout Validations) {
        validations.add("name", as: String.self)
    }
}

extension Device {
    struct ChangeStatus: Codable {
        let id: UUID
    }
    
    struct StatusResponse: Content {
        let status: DeviceStatus
    }
    
    func statusResponse() -> StatusResponse {
        .init(status: self.status)
    }
}
