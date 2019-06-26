//
//  HomeWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/19/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol HomeWorkerProtocol {
    func getBancoTemporario(completion: @escaping (Result<[Ferramenta]>) -> ())
    func checkpoint(completion: @escaping (Result<Bool>) -> ())
}

class HomeWorker: HomeWorkerProtocol {
    
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }

    //MARK :- Funcoes
    func getBancoTemporario(completion: @escaping (Result<[Ferramenta]>) -> ())  {
        let parameters: [String : Any] = [:]
        defaultNetworking.request("bancotemporario",
                                  method: .get,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let ferramentas = try decoder.decode([Ferramenta].self, from: data!)
                    completion(Result.success(ferramentas))
                } catch let error {
                    completion(Result.error(error))
                }
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
    
    func checkpoint(completion: @escaping (Result<Bool>) -> ()) {
        let parameters: [String : Any] = [:]
        defaultNetworking.request("checkpoint",
                                  method: .post,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success:
                completion(Result.success(true))
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
}
