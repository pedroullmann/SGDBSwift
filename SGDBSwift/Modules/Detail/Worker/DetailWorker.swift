//
//  DetailWorker.swift
//  SGDBSwift
//
//  Created by Pedro Ullmann on 5/27/19.
//  Copyright © 2019 Pedro Ullmann. All rights reserved.
//

import Foundation

protocol DetailWorkerProtocol {
    //func getBancoTemporario(completion: @escaping (Result<[Ferramenta]>) -> ())
}

class DetailWorker: DetailWorkerProtocol {
    
    private var defaultNetworking: DefaultNetworking!
    
    init(defaultNetworking: DefaultNetworking = DefaultNetworking()) {
        self.defaultNetworking = defaultNetworking
    }
    
    //MARK :- Funcoes
    
}

