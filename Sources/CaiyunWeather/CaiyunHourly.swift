//
//  CaiyunHourly.swift
//  
//
//  Created by 袁林 on 2021/6/14.
//

import Foundation

public struct CaiyunHourly: Codable, Equatable {
    
    public let responseStatus: String
    public let description: String
    public let phenomenon: [Phenomenon]
    public let temperature: [Temperature]
    public let apparentTemperature: [Temperature]
    public let precipitation: [Precipitation]
    public let cloudrate: [Cloudrate]
    public let humidity: [Humidity]
    public let pressure: [Pressure]
    public let wind: [Wind]
    public let visibility: [Visibility]
    public let dswrf: [DSWRF]
    public let airQuality: AirQuality
    
    private enum CodingKeys: String, CodingKey {
        case responseStatus = "status"
        case description
        case phenomenon = "skycon"
        case temperature
        case apparentTemperature = "apparent_temperature"
        case precipitation
        case cloudrate
        case humidity
        case pressure
        case wind
        case visibility
        case dswrf
        case airQuality = "air_quality"
    }
}

// MARK: - Redefined Types

extension CaiyunHourly {
    public struct AirQuality: Codable, Equatable {
        let aqi: [AQI]
        let pm25: [PM25]
    }
}

// MARK: - Type Alias

extension CaiyunHourly {
    public typealias HourlyContentDouble = ValueWithDatetime<Double>
    
    public typealias Phenomenon = ValueWithDatetime<CaiyunContent.Phenomenon>
    public typealias Temperature = HourlyContentDouble
    public typealias Precipitation = ValueWithDatetimeFlat<CaiyunContent.Precipitation>
    public typealias Cloudrate = HourlyContentDouble
    public typealias Humidity = HourlyContentDouble
    public typealias Pressure = HourlyContentDouble
    public typealias Wind = ValueWithDatetimeFlat<CaiyunContent.Wind>
    public typealias Visibility = HourlyContentDouble
    public typealias DSWRF = HourlyContentDouble
    public typealias AQI = ValueWithDatetime<CaiyunContent.AirQuality.AQI>
    public typealias PM25 = HourlyContentDouble
}

// MARK: - Abstract Types

extension CaiyunHourly {
    
    public struct ValueWithDatetime<T: Codable & Equatable>: Codable, Equatable {
        /// 时间
        public let datetime: CaiyunContent.DatetimeServerType
        /// 值
        public let value: T
    }
    
    public struct ValueWithDatetimeFlat<T: Codable & Equatable>: Codable, Equatable {
        /// 时间
        public let datetime: CaiyunContent.DatetimeServerType
        /// 值
        public let value: T
        
        private enum CodingKeys: String, CodingKey {
            case datetime
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            datetime = try container.decode(CaiyunContent.DatetimeServerType.self, forKey: .datetime)
            value = try T(from: decoder)
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.container(keyedBy: CodingKeys.self)
            
            try container.encode(datetime, forKey: .datetime)
            try value.encode(to: encoder)
        }
    }
}
