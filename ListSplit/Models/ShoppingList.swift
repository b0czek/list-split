//
//  ShoppingList.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 09/01/2025.
//

// ShoppingList Model

import Foundation

struct ShoppingList: Codable, Identifiable {
    var uuid = UUID()
    
    
    
    var id: Int?
    var name: String
    var description: String
    var currency: String
    var userId: Int?

    init() {
        self.name = ""
        self.description = ""
        self.currency = ""
    }
    
    init(name: String) {
        self.name = name
        self.description = ""
        self.currency = ""
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case currency
        case userId = "user_id"
    }
}


struct ListShare: Codable {
    var id: Int
    var shoppingListId: Int
    var userId: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case shoppingListId = "shopping_list_id"
        case userId = "user_id"
    }
}

struct ListShareCreate: Codable {    
    var email: String
    var shoppingListId: Int
    
    enum CodingKeys: String, CodingKey {
        case email
        case shoppingListId = "shopping_list_id"
    }
}
