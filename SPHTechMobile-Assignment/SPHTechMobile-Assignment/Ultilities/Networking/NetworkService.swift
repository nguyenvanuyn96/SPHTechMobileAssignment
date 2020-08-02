//
//  NetworkService.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/2/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift

public class Endpoint: RequestDataProtocol {
    public var path: String
    public var method: HTTPMethodType = .get
    public var queryParameters: [String: Any] = [:]
    public var headerParamaters: [String: String] = [:]
    public var bodyParamaters: [String: Any] = [:]
    public var bodyEncoding: DataEncoding = .jsonSerializationData
    
    init(path: String,
         method: HTTPMethodType = .get,
         queryParameters: [String: Any] = [:],
         headerParamaters: [String: String] = [:],
         bodyParamaters: [String: Any] = [:],
         bodyEncoding: DataEncoding = .jsonSerializationData) {
        self.path = path
        self.method = method
        self.queryParameters = queryParameters
        self.headerParamaters = headerParamaters
        self.bodyParamaters = bodyParamaters
        self.bodyEncoding = bodyEncoding
    }
}

extension URLSession: NetworkSessionProtocol {
    public func loadData(from request: URLRequest) -> Observable<(Data?, URLResponse?, Error?)> {
        return Observable<(Data?, URLResponse?, Error?)>.create { [weak self] obs in
            guard let self = self else {
                obs.onNext((nil, nil, nil))
                obs.onCompleted()
                return Disposables.create()
            }
            
            let task = self.dataTask(with: request) { (data, response, error) in
                obs.onNext((data, response, error))
                obs.onCompleted()
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}

final public class DefaultNetworkService: NetworkServiceProtocol {
    private let _session: NetworkSessionProtocol
    private let _config: NetworkConfigurable
    private let _logger: NetworkLoggerProtocol
    
    public init(session: NetworkSessionProtocol,
                config: NetworkConfigurable,
                logger: NetworkLoggerProtocol = DefaultNetworkLogger()) {
        self._session = session
        self._config = config
        self._logger = logger
    }
    
    public func request(endpoint: RequestDataProtocol) -> Observable<Result<Data?, NetworkServiceError>> {
        do {
            let urlRequest = try endpoint.urlRequest(with: self._config)
            return self.request(request: urlRequest)
        } catch {
            return Observable.just(Result.failure(NetworkServiceError.urlGeneration))
        }
    }
    
    private func request(request: URLRequest) -> Observable<Result<Data?, NetworkServiceError>>  {
        let sessionDataObs = self._session.loadData(from: request)
            .map({ [weak self] (arg0) -> Result<Data?, NetworkServiceError> in
                let (data, response, requestError) = arg0
                var error: NetworkServiceError
                if let requestError = requestError {
                    if let response = response as? HTTPURLResponse, (400..<600).contains(response.statusCode) {
                        error = .errorStatusCode(statusCode: response.statusCode)
                        self?._logger.log(statusCode: response.statusCode)
                    } else if requestError._code == NSURLErrorNotConnectedToInternet {
                        error = .networkNotFound
                    } else if requestError._code == NSURLErrorCancelled {
                        error = .cancelled
                    } else {
                        error = .requestError(requestError)
                    }
                    self?._logger.log(error: requestError)
                    
                    return Result.failure(error)
                } else {
                    self?._logger.log(responseData: data, response: response)
                    return Result.success(data)
                }
            })
        
        self._logger.log(request: request)
        
        return sessionDataObs
    }
}

final public class DefaultNetworkLogger: NetworkLoggerProtocol {
    public init() {
        
    }
    
    public func log(request: URLRequest) {
        #if DEBUG
        print("================================")
        print("request: \(request.url!)")
        print("headers: \(request.allHTTPHeaderFields!)")
        print("method: \(request.httpMethod!)")
        if let httpBody = request.httpBody, let result = ((try? JSONSerialization.jsonObject(with: httpBody, options: []) as? [String: AnyObject]) as [String: AnyObject]??) {
            print("body: \(String(describing: result))")
        }
        if let httpBody = request.httpBody, let resultString = String(data: httpBody, encoding: .utf8) {
            print("body: \(String(describing: resultString))")
        }
        #endif
    }
    
    public func log(responseData data: Data?, response: URLResponse?) {
        #if DEBUG
        guard let data = data else { return }
        if let dataDict =  try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
            print("responseData: \(String(describing: dataDict))")
        }
        #endif
    }
    
    public func log(error: Error) {
        #if DEBUG
        print("error: \(error)")
        #endif
    }
    
    public func log(statusCode: Int) {
        #if DEBUG
        print("status code: \(statusCode)")
        #endif
    }
}

