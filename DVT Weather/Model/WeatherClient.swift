//
//  WeatherClient.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/23.
//

import Foundation

class WeatherClient {
    
    enum EndPoints {
        static let base = "https://api.openweathermap.org/data/3.0/onecall?"
        static let apiKey = "2e94569c71ade91c47cc25aac3e0f358"
        
        case getCurrentWeather(Double, Double)
        
        var stringValue: String {
            switch self {
            case .getCurrentWeather(let latitude, let longitude):
                return EndPoints.base + "lat=\(latitude)&lon=\(longitude)&appid=\(EndPoints.apiKey)&units=metric"
            }
        }
        
        var url: URL? {
            guard let url = URL(string: stringValue) else {
                return nil
            }
            return url
        }
    }
    
    /// Function for obtaining a weather forecast
    class func getWeatherObjects(latitude: Double, longitude: Double) async throws -> WeatherForecast {
        
        guard let request = EndPoints.getCurrentWeather(latitude, longitude).url else {
            throw WeatherRequestErrors.invalidURL
        }
        
        //URL is used to make a network request
        let (data, response) = try await URLSession.shared.data(from: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw WeatherRequestErrors.couldNotGetWeather
        }
        
        do {
            // Data from the API is made available here
            let decoder = JSONDecoder()
            return try decoder.decode(WeatherForecast.self, from: data)
        } catch {
            print("Error parsing weather data")
            throw WeatherRequestErrors.couldNotGetWeatherData
        }
        
    }
}

//Enum that holds error cases
enum WeatherRequestErrors: Error {
    case invalidURL
    case couldNotGetWeather
    case couldNotGetWeatherData
}

