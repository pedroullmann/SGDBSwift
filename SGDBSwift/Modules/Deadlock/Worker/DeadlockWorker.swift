//
//  DeadlockWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/16/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol DeadlockWorkerProtocol {
    func verifyDeadlock(completion: @escaping (Result<Bool>) -> ())
    func getDeadlocks(completion: @escaping (Result<[Deadlock]>) -> ())
}

class DeadlockWorker: DeadlockWorkerProtocol {
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }
    
    func verifyDeadlock(completion: @escaping (Result<Bool>) -> ()) {
        let parameters: [String : Any] = [:]
        defaultNetworking.request("deadlock/verify",
                                  method: .get,
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
    
    func getDeadlocks(completion: @escaping (Result<[Deadlock]>) -> ()) {
        let parameters: [String : Any] = [:]
        defaultNetworking.request("deadlock",
                                  method: .get,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let deadlocks = try decoder.decode([Deadlock].self, from: data!)
                    completion(Result.success(deadlocks))
                } catch let error {
                    completion(Result.error(error))
                }
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
    
    func removeDeadlock(deadlock: Deadlock, completion: @escaping (Result<Bool>) -> ()) {
        let parameters: [String : Any] = [
            "primeira_transacaoBloqueada": deadlock.primeira_transacaoBloqueada,
            "segunda_transacaoBloqueada": deadlock.segunda_transacaoBloqueada
        ]
        
        defaultNetworking.request("deadlock",
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
}
