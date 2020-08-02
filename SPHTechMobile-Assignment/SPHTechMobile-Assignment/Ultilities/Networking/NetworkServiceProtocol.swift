//
//  NetworkService.swift
//  SPHTechMobile-Assignment
//
//  Created by Uy Tikier on 8/1/20.
//  Copyright © 2020 Uy Nguyen. All rights reserved.
//

import Foundation
import RxSwift

public enum NetworkServiceError: Error {
    case errorStatusCode(statusCode: Int)
    case cancelled
    case urlGeneration
    case requestError(Error?)
    case serverError
    case dataError(code: Int, message: String)
    case networkNotFound
}

enum RequestDataError: Error {
    case components
}

public enum HTTPMethodType: String {
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case delete  = "DELETE"
}

public enum DataEncoding {
    case jsonSerializationData
    case stringEncodingAscii
}

public protocol RequestDataProtocol {
    var path: String { get }
    var method: HTTPMethodType { get }
    var queryParameters: [String: Any] { get }
    var headerParamaters: [String: String] { get }
    var bodyParamaters: [String: Any] { get }
    var bodyEncoding: DataEncoding { get }
    
    func urlRequest(with networkConfig: NetworkConfigurable) throws -> URLRequest
}

public protocol NetworkSessionProtocol {
    func loadData(from request: URLRequest) -> Observable<(Data?, URLResponse?, Error?)>
}

public protocol NetworkServiceProtocol {
    func request(endpoint: RequestDataProtocol) -> Observable<Result<Data?, NetworkServiceError>>
}
public protocol NetworkLoggerProtocol {
    func log(request: URLRequest)
    func log(responseData data: Data?, response: URLResponse?)
    func log(error: Error)
    func log(statusCode: Int)
}

extension RequestDataProtocol {
    public func urlRequest(with config: NetworkConfigurable) throws -> URLRequest {
        let url = try self.makeURL(with: config)
        var urlRequest = URLRequest(url: url)
        var allHeaders: [String: String] = config.headers
        
        self.headerParamaters.forEach({ allHeaders.updateValue($1, forKey: $0) })
        
        if !self.bodyParamaters.isEmpty {
            urlRequest.httpBody = encodeBody(bodyParamaters: self.bodyParamaters, bodyEncoding: self.bodyEncoding)
        }
        urlRequest.httpMethod = self.method.rawValue
        urlRequest.allHTTPHeaderFields = allHeaders
        
        return urlRequest
    }
    
    private func makeURL(with config: NetworkConfigurable) throws -> URL {
        let baseURL = config.baseUrl.last != "/" ? "\(config.baseUrl)/" : config.baseUrl
        let endpoint = baseURL.appending(self.path)
        
        guard var urlComponents = URLComponents(string: endpoint) else { throw RequestDataError.components}
        
        var urlQueryItems = [URLQueryItem]()
        
        self.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: "\($0.value)"))
        }
        config.queryParameters.forEach {
            urlQueryItems.append(URLQueryItem(name: $0.key, value: $0.value))
        }
        urlComponents.queryItems = !urlQueryItems.isEmpty ? urlQueryItems : nil
        
        guard let url = urlComponents.url else { throw RequestDataError.components }
        
        return url
    }
    
    private func encodeBody(bodyParamaters: [String: Any], bodyEncoding: DataEncoding) -> Data? {
        switch bodyEncoding {
        case .jsonSerializationData:
            return try? JSONSerialization.data(withJSONObject: bodyParamaters)
        case .stringEncodingAscii:
            return bodyParamaters.queryString.data(using: String.Encoding.ascii, allowLossyConversion: true)
        }
    }
}

fileprivate extension Dictionary {
    var queryString: String {
        return self.map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
            .addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed) ?? ""
    }
}
