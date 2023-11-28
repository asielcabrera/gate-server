//
//  UserController.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 11/28/23.
//

import Fluent
import Vapor

struct UserController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let users = routes.grouped("user")
    }
}
