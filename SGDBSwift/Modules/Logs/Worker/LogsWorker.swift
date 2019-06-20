//
//  LogsWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 6/20/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol LogsWorkerProtocol {
    func getLogs(completion: @escaping (Result<[Log]>) -> ())
    func createLog(log: Log, completion: @escaping (Result<Bool>) -> ())
}

class LogsWorker: LogsWorkerProtocol {
    
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }
    
    func getLogs(completion: @escaping (Result<[Log]>) -> ()) {
        let parameters: [String : Any] = [:]
        
        defaultNetworking.request("logs",
                                  method: .get,
                                  encoding: .default,
                                  parameters: parameters) { result in
            switch result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let logs = try decoder.decode([Log].self, from: data!)
                    completion(Result.success(logs))
                } catch let error {
                    completion(Result.error(error))
                }
            case .error(let error):
                completion(Result.error(error))
            }
        }
    }
    
    func createLog(log: Log, completion: @escaping (Result<Bool>) -> ()) {
        guard let logJSON = try? JSONEncoder().encode(log) else {
            completion(Result.success(false))
            return
        }
        
        var parameters: [String : Any] = [:]
        parameters["log"] = String(data: logJSON, encoding: .utf8)
        
        defaultNetworking.request("logs",
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
