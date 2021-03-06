//
//  List.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/14/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class List: Codable, Equatable {
    static func == (lhs: List, rhs: List) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var transacaoBloqueada: Int
    var transacaoLiberada: Int
    
    init(id: Int,
         transacaoBloqueada: Int,
         transacaoLiberada: Int) {
        self.id = id
        self.transacaoBloqueada = transacaoBloqueada
        self.transacaoLiberada = transacaoLiberada
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case transacaoBloqueada
        case transacaoLiberada
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        transacaoBloqueada = try values.decode(Int.self, forKey: .transacaoBloqueada)
        transacaoLiberada = try values.decode(Int.self, forKey: .transacaoLiberada)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(transacaoBloqueada, forKey: .transacaoBloqueada)
        try container.encode(transacaoLiberada, forKey: .transacaoLiberada)
    }
}
