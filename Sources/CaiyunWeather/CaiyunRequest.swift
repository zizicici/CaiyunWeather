//
//  CaiyunRequest.swift
//  
//
//  Created by 袁林 on 2021/6/12.
//

import Foundation

public class CaiyunRequest {
    
    /// The `CYEndpoint` object to which the request is sent to.
    public var endpoint: CaiyunEndpoint!
    
    /// The expiration, that is, the minimum time interval for URL request for the same condinate. In second.
    public var expiration: TimeInterval = 5 * 60
    
    /// The queue on which the request is performed
    public var queue: DispatchQueue = .global(qos: .background)
    
    public init(token: String, latitude: Double, longitude: Double, startTimestamp: Int) {
        self.endpoint = CaiyunEndpoint(token: token, latitude: latitude, longitude: longitude, startTimestamp: startTimestamp)
    }
}

// MARK: - Work with request for CaiyunResponse

extension CaiyunRequest {
    
    /// Perform an action to request weather content.
    ///
    /// If the data from local cache will be used if:
    /// 1. the local cached file exists with no decoding errors; and
    /// 2. it is for the coordinate you are requiring (rounded to `%.4f`, about 100 meters in distance); and
    /// 3. it is not expired.
    ///
    /// Elsewise, a new data will be requested from remote API.
    public func perform(completionHandler: @escaping (CaiyunResponse?, Error?) -> Void) {
        queue.async { [weak self] in
            self?.fetchDataFromRemote { data, error in
                guard let data = data else {
                    completionHandler(nil, error)
                    return
                }
                self?.decode(data) { response, error in
                    completionHandler(response, error)
                }
            }
        }
    }
}

// MARK: - Work with data

extension CaiyunRequest {
    
    /// Explicitly fetch data.
    public func fetchData(completionHandler: @escaping (Data?, Error?) -> Void) {
        fetchDataFromRemote(completionHandler: completionHandler)
    }
    
    /// Explicitly fetch data from API.
    func fetchDataFromRemote(completionHandler: @escaping (Data?, Error?) -> Void) {
        queue.async { [self] in
            guard let url = endpoint.url else {
                completionHandler(nil, CaiyunError.invalidURL)
                return
            }
            
            URLSession.shared.dataTask(with: url) { (data, _, error) in
                completionHandler(data, error)
                NSLog("Performed a remote data fatching. URL: %@", url.absoluteString)
            }
            .resume()
        }
    }
}

// MARK: - Decoding and Validating

extension CaiyunRequest {
    
    /// Decode the data. May result in `CaiyunResponse`, `CaiyunInvalidResponse`, or cannot decode.
    /// Resulting in `CaiyunInvalidResponse` means there's some error with your token, so the `error` return will be `CaiyunError.invalidResponse(description: invalidResponse.error)`.
    public func decode(_ data: Data, completionHandler: @escaping (CaiyunResponse?, CaiyunError?) -> Void) {
        queue.async {
            let decoder = JSONDecoder()
            if let response = try? decoder.decode(CaiyunResponse.self, from: data) {
                completionHandler(response, nil)
                NSLog("Successfully decode content.", 0)
            }
            else if let invalidResponse = try? decoder.decode(CaiyunInvalidResponse.self, from: data) {
                completionHandler(nil, .invalidResponse(description: invalidResponse.error))
                NSLog("API return invalid result. API error content: %@", invalidResponse.error)
            }
            else {
                completionHandler(nil, .invalidResponse(description: "unexpected result"))
                NSLog("API return unexpected result", -1)
            }
        }
    }
    
    /// Validate a `CaiyunResponse` file.
    public func validate(_ response: CaiyunResponse) -> Bool {
        // Coordinate
//        guard response.coordinate.urlString == endpoint.coordinate.urlString else {
//            NSLog("The coordinate is not same. Response is not valid. response coordinate: %@, request coordinate: %@", response.coordinate.urlString, endpoint.coordinate.urlString)
//            return false
//        }
        // Data expiration
        let responseTime = response.serverTime.time
        let intervalTillNow = -responseTime.timeIntervalSinceNow
        return intervalTillNow <= expiration
    }
}
