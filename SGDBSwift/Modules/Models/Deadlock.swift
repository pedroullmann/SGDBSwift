//
//  Deadlock.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/16/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

class Deadlock: Codable, Equatable {
    static func == (lhs: Deadlock, rhs: Deadlock) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var primeira_transacaoBloqueada: Int
    var segunda_transacaoBloqueada: Int
    
    init(id: Int,
         primeira_transacaoBloqueada: Int,
         segunda_transacaoBloqueada: Int) {
        self.id = id
        self.primeira_transacaoBloqueada = primeira_transacaoBloqueada
        self.segunda_transacaoBloqueada = segunda_transacaoBloqueada
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case primeira_transacaoBloqueada
        case segunda_transacaoBloqueada
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        primeira_transacaoBloqueada = try values.decode(Int.self, forKey: .primeira_transacaoBloqueada)
        segunda_transacaoBloqueada = try values.decode(Int.self, forKey: .segunda_transacaoBloqueada)
    }
}
