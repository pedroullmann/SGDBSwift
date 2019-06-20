//
//  Log.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

enum TipoTransacao: Int, Codable {
    case inserção = 0
    case alteração
    case remoção
    case commit
    case rollback
    case checkpoint
    case instanciada
    
    init(from decoder: Decoder) throws {
        let id = try decoder.singleValueContainer().decode(Int.self)
        if let novoTipo = TipoTransacao(rawValue: id) {
            self = novoTipo
        } else {
            self = .inserção
        }
    }
    
    init(fromRawValue: Int) {
        self = TipoTransacao(rawValue: fromRawValue) ?? .inserção
    }
}

class Log: Codable, Equatable {
    static func == (lhs: Log, rhs: Log) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var sessao: Int
    var tipo: TipoTransacao
    var acao: String
    
    init(id: Int,
         sessao: Int,
         tipo: TipoTransacao,
         acao: String) {
        self.id = id
        self.sessao = sessao
        self.tipo = tipo
        self.acao = acao
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case sessao
        case tipo
        case acao
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decode(Int.self, forKey: .id)
        sessao = try values.decode(Int.self, forKey: .sessao)
        
        if let unTipo = try? values.decode(Int.self, forKey: .tipo) {
            tipo = TipoTransacao(fromRawValue: unTipo)
        } else {
            tipo = .inserção
        }
        
        acao = try values.decode(String.self, forKey: .acao)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(sessao, forKey: .sessao)
        try container.encode(tipo, forKey: .tipo)
        try container.encode(acao, forKey: .acao)
    }
}
