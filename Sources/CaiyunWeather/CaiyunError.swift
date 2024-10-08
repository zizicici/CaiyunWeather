//
//  CaiyunError.swift
//  
//
//  Created by 袁林 on 2021/6/12.
//

import Foundation

public enum CaiyunError: Error, Equatable {
    case invalidData
    case invalidURL
    case invalidResponse(description: String)
}
