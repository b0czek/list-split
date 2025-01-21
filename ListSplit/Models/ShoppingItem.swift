//
//  ShoppingItem.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 09/01/2025.
//

// Item Model
import Foundation



struct ShoppingItem: Codable, Identifiable {
    
    var isChecked: Bool = false
    var uuid = UUID()
    
    var id: Int?
    var name: String
    var description: String = ""
    var shoppingListId: Int = 0

    init(name: String) {
        self.name = name
        self.id = nil
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case shoppingListId = "shopping_list_id"
    }
}
