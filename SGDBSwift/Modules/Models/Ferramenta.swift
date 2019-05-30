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
}

class Ferramenta: Codable, Equatable {
    static func == (lhs: Ferramenta, rhs: Ferramenta) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var descricao: String
    var bloqueio: Bloqueio?
    var transacao: Int?
    
    init(id: Int, descricao: String, bloqueio: Bloqueio?) {
        self.id = id
        self.descricao = descricao
        self.bloqueio = bloqueio
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
        
        if let bloqueio = try values.decodeIfPresent(Bloqueio.self, forKey: .bloqueio) {
            self.bloqueio = bloqueio
        } else {
            self.bloqueio = .desbloqueado
        }
        
        id = try values.decode(Int.self, forKey: .id)
        descricao = try values.decode(String.self, forKey: .descricao)
    }
}
