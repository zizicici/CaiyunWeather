//
//  CaiyunError.swift
//  
//
//  Created by 袁林 on 2021/6/12.
//

import Foundation

public enum CaiyunError: Error, Equatable {
    case invalidURL
    case fileDontExist
    case invalidResponse(description: String)
}
