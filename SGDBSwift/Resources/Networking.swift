//
//  Networking.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/25/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation
import Alamofire

enum Result<T> {
    case success(T)
    case error(Error)
}

enum DefaultNetworkingMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case post    = "POST"
    case patch   = "PATCH"
    
    func getMethod() -> HTTPMethod {
        switch self {
        case .options:
            return HTTPMethod.options
        case .get:
            return HTTPMethod.get
        case .post:
            return HTTPMethod.post
        case .patch:
            return HTTPMethod.patch
        }
    }
}

enum DefaultEncoding {
    case `default`
    case queryString
    case json
    case jsonPretty
    func getEncoding() -> ParameterEncoding {
        switch self {
        case .default:
            return URLEncoding.default
        case .queryString:
            return URLEncoding.queryString
        case .json:
            return JSONEncoding.default
        case .jsonPretty:
            return JSONEncoding.prettyPrinted
        }
    }
}

protocol DefaultNetworkingProtocol: class {
    typealias NetworkingDataCompletion = ((Result<Data?>) -> Void)
    
    func request(_ path: String,
                 method: DefaultNetworkingMethod,
                 encoding: DefaultEncoding,
                 parameters: [String: Any],
                 completion: @escaping NetworkingDataCompletion)
}

extension DefaultNetworkingProtocol {
    func request(_ path: String,
                 method: DefaultNetworkingMethod = .get,
                 encoding: DefaultEncoding = .default,
                 parameters: [String: Any],
                 completion: @escaping NetworkingDataCompletion) {
        request(path,
                method: method,
                encoding: encoding,
                parameters: parameters,
                completion: completion)
    }
}

class DefaultNetworking {
    /// Default interface
    private let httpInterface: SessionManager
    
    /// Default Alamofire initialization
    private var alamoFireManager: Alamofire.SessionManager = { () -> Alamofire.SessionManager in
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 45
        let manager = Alamofire.SessionManager(configuration: configuration)
        return manager
    }()
    
    init(httpInterface: SessionManager = SessionManager()) {
        self.httpInterface = httpInterface
    }
}

extension DefaultNetworking: DefaultNetworkingProtocol {
    func request(_ path: String,
                 method: DefaultNetworkingMethod,
                 encoding: DefaultEncoding,
                 parameters: [String: Any],
                 completion: @escaping NetworkingDataCompletion) {
        
        let url = "http://127.0.0.1:3003/\(path)"
            
        self.httpInterface.request(url,
                                   method: method.getMethod(),
                                   parameters: parameters,
                                   encoding: encoding.getEncoding(),
                                   headers: nil)
            .validate()
            .responseJSON(queue: DispatchQueue.global(qos: DispatchQoS.QoSClass.default),
                          options: JSONSerialization.ReadingOptions.allowFragments)
            { (response: DataResponse) in
            switch response.result {
            case .success:
                completion(Result.success(response.data))
            case .failure(let error):
                completion(Result.error(error))
            }
        }
    }
}
