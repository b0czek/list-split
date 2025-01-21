//
//  User.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 09/01/2025.
//

import Foundation

// User Model
struct User: Codable, Identifiable {
    let uuid = UUID()
    
    
    var id: Int?
    var name: String = ""
    var email: String = ""
    var password: String?
    

    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case password
    }
}


struct LoginData: Codable {
    var email: String
    var password: String
    
    enum CodingKeys: String, CodingKey {
        case email
        case password
    }
}

class LoggedUser: ObservableObject {
    @Published var id = 0
    @Published var name = "user"
    @Published var email = "user@example.com"
    
}

