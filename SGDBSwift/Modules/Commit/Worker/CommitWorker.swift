//
//  CommitWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/22/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol CommitWorkerProtocol {
    func setCommit(removedIds: [Int], transactionId: Int, completion: @escaping (Result<Transacao>)-> ())
}

class CommitWorker: CommitWorkerProtocol {
    
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }
    
    func setCommit(removedIds: [Int], transactionId: Int, completion: @escaping (Result<Transacao>) -> ()) {
        var parameters: [String : Any] = [:]
        parameters["removedIds"] = removedIds
        
        defaultNetworking.request("commit/\(transactionId)",
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
