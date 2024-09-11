//
//  CaiyunResponse.swift
//  
//
//  Created by 袁林 on 2021/6/13.
//

import Foundation

public struct CaiyunResponse: Codable, Equatable {
    /// 响应状态
    public let responseStatus: String
    /// API 版本
    public let apiVersion: String
    /// API 状态
    public let apiStatus: String
    /// 请求语言
    public let language: String
    /// 单位制
    public let unit: String
    /// 返回点经纬度
    public let latitude: Double
    public let longitude: Double
    /// 服务器时间
    public let serverTime: CaiyunContent.Datetime1970Based
    /// 服务器时区
    public let serverTimeZone: CaiyunTimeZone
    /// 返回结果对象
    public let result: CaiyunResult
    
    private enum CodingKeys: String, CodingKey {
        case responseStatus = "status"
        case version = "api_version"
        case apiStatus = "api_status"
        case language = "lang"
        case unit
        case location
        case serverTime = "server_time"
        case serverTimeZone = "tzshift"
        case result
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        responseStatus = try container.decode(String.self, forKey: .responseStatus)
        apiVersion = try container.decode(String.self, forKey: .version)
        apiStatus = try container.decode(String.self, forKey: .apiStatus)
        language = try container.decode(String.self, forKey: .language)
        unit = try container.decode(String.self, forKey: .unit)
        var locationContainer = try container.nestedUnkeyedContainer(forKey: .location)
        latitude = try locationContainer.decode(Double.self)
        longitude = try locationContainer.decode(Double.self)
        serverTime = try container.decode(CaiyunContent.Datetime1970Based.self, forKey: .serverTime)
        serverTimeZone = try container.decode(CaiyunTimeZone.self, forKey: .serverTimeZone)
        result = try container.decode(CaiyunResult.self, forKey: .result)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(responseStatus, forKey: .responseStatus)
        try container.encode(apiVersion, forKey: .version)
        try container.encode(apiStatus, forKey: .apiStatus)
        try container.encode(language, forKey: .language)
        try container.encode(unit, forKey: .unit)
        var locationContainer = container.nestedUnkeyedContainer(forKey: .location)
        try locationContainer.encode(latitude)
        try locationContainer.encode(longitude)
        try container.encode(serverTime, forKey: .serverTime)
        try container.encode(serverTimeZone, forKey: .serverTimeZone)
        try container.encode(serverTime, forKey: .serverTime)
    }
}

// MARK: - Redefined Types

extension CaiyunResponse {
    
    public struct CaiyunTimeZone: Codable, Equatable {
        /// 值
        public let value: TimeZone
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            
            let serverTimeShiftRaw = try container.decode(Int.self)
            value = TimeZone(secondsFromGMT: serverTimeShiftRaw)!
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            
            let serverTimeShiftRaw = value.secondsFromGMT()
            try container.encode(serverTimeShiftRaw)
        }
    }
}
