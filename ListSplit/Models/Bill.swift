//
//  Bill.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 09/01/2025.
//

// Bill Model

import Foundation

struct Bill: Codable, Identifiable {
    let uuid = UUID()
    
    var id: Int?
    var name: String
    var date: Date
    var amount: Float
    var shoppingListId: Int?
    var userId: Int?
    var userName: String?

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case date
        case amount
        case shoppingListId = "shopping_list_id"
        case userId = "user_id"
        case userName = "user_name"
    }
    
    init(name: String, date: Date, amount: Float) {

        self.name = name
        self.date = date
        self.amount = amount
    }
}


struct BillSummary: Codable, Identifiable {
    let uuid = UUID()

    var id: Int?
    var user: String
    var amount: Float
    var percent: Float
    
    enum CodingKeys: String, CodingKey {
        case id = "user_id"
        case user
        case amount
        case percent
    }
}
