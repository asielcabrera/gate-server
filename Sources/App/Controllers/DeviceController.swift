//
//  DeviceController.swift
//  
//
//  Created by Asiel Cabrera Gonzalez on 11/28/23.
//

import Fluent
import Vapor

struct DeviceController: RouteCollection {
    func boot(routes: RoutesBuilder) throws {
        let devices = routes.grouped("devices")
        let tokenProtected = devices.grouped(UserToken.authenticator())
        
        tokenProtected.get("", use: getDevicesByUser)
        tokenProtected.post("", use: createDevice)
        tokenProtected.group(":id") { device in
            device.post("getstatus", use: getStatus)
            device.post("open", use: openDevice)
            device.post("close", use: closeDevice)
        }
    }
    
    func getDevicesByUser(req: Request) async throws -> [Device.Public] {
        let user = try req.auth.require(User.self)
        let devices = try await user.$devices.get(on: req.db)
        return try devices.map { device in
            try device.asPublic()
        }
    }
    
    func createDevice(req: Request) async throws -> Device {
        let user = try req.auth.require(User.self)
        
        try Device.Create.validate(content: req)
        var deviceToCreate = try req.content.decode(Device.Create.self)
        deviceToCreate.userID = try user.requireID()
        let device = Device(from: deviceToCreate)
        try await device.save(on: req.db)
        return device
    }
    
    func getStatus(req: Request) async throws -> Device.StatusResponse {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        return device.statusResponse()
    }
    
    func openDevice(req: Request) async throws -> Device.StatusResponse {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        
        //    TODO: call webhook to open gate
        
        device.status = .open
        try await device.save(on: req.db)
        return try await self.getStatus(req: req)
    }
    
    func closeDevice(req: Request) async throws -> Device.StatusResponse {
        guard let device = try await Device.find(req.parameters.get("id"), on: req.db) else {
            throw Abort(.notFound)
        }
        //    TODO: call webhook to close gate
        device.status = .close
        try await device.save(on: req.db)
        return try await self.getStatus(req: req)
    }
}
