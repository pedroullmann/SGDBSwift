//
//  Transacao.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

enum EstadoTransacao: Int, Codable {
    case ativa = 0
    case commit
    case rollback
    
    init(from decoder: Decoder) throws {
        let id = try decoder.singleValueContainer().decode(Int.self)
        if let novoEstado = EstadoTransacao(rawValue: id) {
            self = novoEstado
        } else {
            self = .ativa
        }
    }
    
    init(fromRawValue: Int) {
        self = EstadoTransacao(rawValue: fromRawValue) ?? .ativa
    }
}

class Transacao: Codable, Equatable {
    static func == (lhs: Transacao, rhs: Transacao) -> Bool {
        return lhs.id == rhs.id
    }
    
    var id: Int
    var nome: String
    var visao: [Ferramenta]
    var transacao_estado: EstadoTransacao
    var data: String
    
    init(id: Int, nome: String, visao: [Ferramenta], transacao_estado: EstadoTransacao, data: String) {
        self.id = id
        self.nome = nome
        self.visao = visao
        self.transacao_estado = transacao_estado
        self.data = data
    }
    
    private enum CodingKeys: String, CodingKey {
        case id
        case nome
        case visao
        case transacao_estado
        case data
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        id = try values.decode(Int.self, forKey: .id)
        nome = try values.decode(String.self, forKey: .nome)
        visao = try values.decode([Ferramenta].self, forKey: .visao)
        data = try values.decode(String.self, forKey: .data)
        
        if let unEstado = try? values.decode(Int.self, forKey: .transacao_estado) {
            transacao_estado = EstadoTransacao(fromRawValue: unEstado)
        } else {
            transacao_estado = .ativa
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(nome, forKey: .nome)
        try container.encode(visao, forKey: .visao)
        try container.encode(transacao_estado, forKey: .transacao_estado)
        try container.encode(data, forKey: .data)
    }
}
