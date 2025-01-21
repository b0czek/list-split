//
//  Message.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 15/01/2025.
//

import Foundation



struct Message: Codable, Identifiable {
    var id = UUID()
    var message: String = ""
    
    init() {

    }
    
    enum CodingKeys: String, CodingKey {
        case message
    }
}
