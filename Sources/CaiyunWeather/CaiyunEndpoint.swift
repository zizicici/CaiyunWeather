//
//  CaiyunEndpoint.swift
//  
//
//  Created by 袁林 on 2021/6/12.
//

import Foundation

public struct CaiyunEndpoint: Codable, Equatable {
    private var token: String!
    private var latitude: Double!
    private var longitude: Double!
    private var version: String = "v2.6"
    private var shouldIncludeAlerts: Bool = true
    private var hourlyLength: Int = 72
    private var dailyLength: Int = 7
    private var startTimestamp: Int!
    
    public init(token: String, latitude: Double, longitude: Double, startTimestamp: Int) {
        self.token = token
        self.latitude = latitude
        self.longitude = longitude
        self.startTimestamp = startTimestamp
    }
    
    private var components: URLComponents {
        return getComponents()
    }
    
    public var url: URL? {
        return components.url
    }
    
    private func getComponents() -> URLComponents {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.caiyunapp.com"
        components.path = [version, token, "\(latitude!),\(longitude!)", "weather"].joined(separator: "/")
        components.queryItems = [
            URLQueryItem(name: "alert", value: "\(shouldIncludeAlerts)"),
            URLQueryItem(name: "dailysteps", value: "\(dailyLength)"),
            URLQueryItem(name: "hourlysteps", value: "\(hourlyLength)"),
            URLQueryItem(name: "begin", value: "\(startTimestamp!)")
        ]
        return components
    }
}
