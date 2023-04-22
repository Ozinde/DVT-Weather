//
//  Weather.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/22.
//

import Foundation

struct WeatherForecast: Codable {
    let currentWeather: Current
    let dailyWeather: [DailyWeather]
    
    
    enum CodingKeys: String, CodingKey {
        case currentWeather = "current"
        case dailyWeather = "daily"
    }
}

struct Current: Codable {
    let temperature: Double
    let description: [WeatherDescription]
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case description = "weather"
    }
}

struct WeatherDescription: Codable {
    let type: String
    
    enum CodingKeys: String, CodingKey {
        case type = "main"
    }
}

struct DailyWeather: Codable {
    let date: Int
    let dayTemperature: DailyTemperature
    let description: [WeatherDescription]
    
    enum CodingKeys: String, CodingKey {
        case date = "dt"
        case dayTemperature = "temp"
        case description = "weather"
    }
}

struct DailyTemperature: Codable {
    let forTheDay: Double
    let minTemperature: Double
    let maxTemperature: Double
    
    enum CodingKeys: String, CodingKey {
        case forTheDay = "day"
        case minTemperature = "min"
        case maxTemperature = "max"
    }
}


