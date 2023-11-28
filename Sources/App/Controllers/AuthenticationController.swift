//
//  AuthenticationController.swift
//
//
//  Created by Asiel Cabrera Gonzalez on 11/28/23.
//

import Fluent
import Vapor

struct AuthenticationController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let auth = routes.grouped("auth")
        
        auth.post("register", use: register)
        let passwordProtected = auth.grouped(User.authenticator())
        passwordProtected.post("login", use: login)
  
//        auth.group("email-verification") { emailVerificationRoutes in
//            emailVerificationRoutes.post("", use: sendEmailVerification)
//            emailVerificationRoutes.get("", use: verifyEmail)
//        }
//        
//        auth.group("reset-password") { resetPasswordRoutes in
//            resetPasswordRoutes.post("", use: resetPassword)
//            resetPasswordRoutes.get("verify", use: verifyResetPasswordToken)
//        }
//        auth.post("recover", use: recoverAccount)
//        
//        auth.post("accessToken", use: refreshAccessToken)
//
        
        let tokenProtected = auth.grouped(UserToken.authenticator())
        tokenProtected.get("me", use: getCurrentUser)
    }
    
    func register(req: Request) async throws -> User.Public {
        try User.Create.validate(content: req)
            let create = try req.content.decode(User.Create.self)
            guard create.password == create.confirmPassword else {
                throw Abort(.badRequest, reason: "Passwords did not match")
            }
            let user = try User(
                name: create.name,
                email: create.email,
                passwordHash: Bcrypt.hash(create.password)
            )
            try await user.save(on: req.db)
        return try user.asPublic()
    }
    
    func login(req: Request) async throws -> UserToken.Public {
        let user = try req.auth.require(User.self)
        let token = try user.generateToken()
        try await token.save(on: req.db)
        return token.asPublic()
    }
    
    private func sendEmailVerification(req: Request) async throws -> HTTPStatus {
        .ok
    }
    private func verifyEmail(req: Request) async throws -> HTTPStatus {
        .ok
    }
    private func resetPassword(req: Request) async throws -> HTTPStatus {
        .ok
    }
    private func verifyResetPasswordToken(req: Request) async throws -> HTTPStatus {
        .ok
    }
    private func recoverAccount(req: Request) async throws -> HTTPStatus {
        .ok
    }
    
    private func refreshAccessToken(req: Request) async throws -> HTTPStatus {
        .ok
    }
    
    private func getCurrentUser(req: Request) async throws -> User.Public {
        try req.auth.require(User.self).asPublic()
    }
}
