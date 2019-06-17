//
//  DetailWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/27/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol DetailWorkerProtocol {
    func rollbackTransaction(transacaoId: Int, completion: @escaping (Result<Transacao>) -> ())
}

class DetailWorker: DetailWorkerProtocol {
    
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }
    
    //MARK :- Funcoes
    func rollbackTransaction(transacaoId: Int, completion: @escaping (Result<Transacao>) -> ()) {
        let parameters : [String : Any] = [:]
        defaultNetworking.request("transacoes/\(transacaoId)",
                                  method: .post,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let transacao = try decoder.decode(Transacao.self, from: data!)
                    completion(Result.success(transacao))
                } catch let error {
                    completion(Result.error(error))
                }
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
}

