//
//  TransactionsWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol TransactionsWorkerProtocol {
    func getTransactions(completion: @escaping (Result<[Transacao]>) -> ())
    func createTransaction(ferramentas: [Ferramenta], completion: @escaping (Result<Transacao>) -> ())
}

class TransactionsWorker: TransactionsWorkerProtocol {
    
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }
    
    //MARK :- Functions
    func getTransactions(completion: @escaping (Result<[Transacao]>) -> ()) {
        let parameters: [String : Any] = [:]
        defaultNetworking.request("transacoes",
                                  method: .get,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let transacoes = try decoder.decode([Transacao].self, from: data!)
                    completion(Result.success(transacoes))
                } catch let error {
                    completion(Result.error(error))
                }
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
    
    func createTransaction(ferramentas: [Ferramenta], completion: @escaping (Result<Transacao>) -> ()) {
        let parameters: [String : Any] = [:]
        defaultNetworking.request("transacoes",
                                  method: .post,
                                  encoding: .json,
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
