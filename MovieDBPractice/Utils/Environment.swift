//
//  Environment.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import Foundation

enum Environment {
    
    case production
    case development
    
    static let shared: Environment = .development
    
    var baseUrl: String {
        switch self {
        case .development: return "https://api.themoviedb.org/3"
        case .production:
            return ""
        }
    }
    
    var apiKey: String {
        switch self {
        case .development: return "e60824122f1c24ee7eba9e852f89104a"
        case .production: return ""
        }
    }
    
    var posterBaseUrl: String {
        switch self {
        case .development: return "https://image.tmdb.org/t/p/w500"
        case .production: return ""
        }
    }
    
}
