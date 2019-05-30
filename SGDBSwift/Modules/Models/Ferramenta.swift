//
//  Ferramenta,.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

enum Bloqueio: Int, Codable {
    case desbloqueado = 0
    case compartilhado
    case exclusivo
    
    init(from decoder: Decoder) throws {
        let id = try decoder.singleValueContainer().decode(Int.self)
        if let novoBloqueio = Bloqueio(rawValue: id) {
            self = novoBloqueio
        } else {
            self = .desbloqueado
        }
    }
    
    init(fromRawValue: Int) {
        self = Bloqueio(rawValue: fromRawValue) ?? .desbloqueado
    }
}

class Ferramenta: Codable, Equatable {
    static func == (lhs: Ferramenta, rhs: Ferramenta) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var descricao: String
    var bloqueio: Bloqueio?
    var transacao: Int?
    
    init(id: Int, descricao: String, bloqueio: Bloqueio?, transacao: Int? = 0) {
        self.id = id
        self.descricao = descricao
        self.bloqueio = bloqueio
        self.transacao = transacao
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case descricao
        case bloqueio
        case transacao
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        
        if let transacao = try values.decodeIfPresent(Int.self, forKey: .transacao) {
            self.transacao = transacao
        } else {
            self.transacao = 0
        }
        
        if let unBloqueio = try? values.decode(Int.self, forKey: .bloqueio) {
            bloqueio = Bloqueio(fromRawValue: unBloqueio)
        } else {
            bloqueio = .desbloqueado
        }
        
        id = try values.decode(Int.self, forKey: .id)
        descricao = try values.decode(String.self, forKey: .descricao)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(descricao, forKey: .descricao)
        try container.encode(bloqueio, forKey: .bloqueio)
        try container.encode(transacao, forKey: .transacao)
    }
}
