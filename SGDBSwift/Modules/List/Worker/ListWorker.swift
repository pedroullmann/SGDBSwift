//
//  ListWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/14/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol ListWorkerProtocol {
    func createBlock(list: List, completion: @escaping (Result<Bool>) -> ())
    func getListBlock(completion: @escaping (Result<[List]>) -> ())
}

class ListWorker: ListWorkerProtocol {
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }

    //MARK :- Functions
    func createBlock(list: List, completion: @escaping (Result<Bool>) -> ()) {
        let parameters: [String : Any] = [
            "transacaoBloqueada": list.transacaoBloqueada,
            "transacaoLiberada": list.transacaoLiberada
        ]
        
        defaultNetworking.request("lista",
                                  method: .post,
                                  encoding: .json,
                                  parameters: parameters) { result in
            switch result {
            case .success:
                completion(Result.success(true))
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
    
    func getListBlock(completion: @escaping (Result<[List]>) -> ()) {
        let parameters: [String : Any] = [:]
        
        defaultNetworking.request("lista",
                                  method: .get,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let lista = try decoder.decode([List].self, from: data!)
                    completion(Result.success(lista))
                } catch let error {
                    completion(Result.error(error))
                }
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
}
