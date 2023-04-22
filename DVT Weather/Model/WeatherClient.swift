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
        
        var url: URL {
            return URL(string: stringValue)!
        }
        
    }
    
    /// Function that contacts the Weather API and receives forecast information
    class func getCurrentWeather(latitude: Double, longitude: Double, completion: @escaping (WeatherForecast?, Error?) -> Void) {
        
        let request = URLRequest(url: EndPoints.getCurrentWeather(latitude, longitude).url)
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                // Give an error if there was a problem receiving data from the API
                completion(nil, WeatherRequestErrors.couldNotGetWeatherData)
                print("No items")
                return
            }
            
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(WeatherForecast.self, from: data)
                // Data from the API is made available here
                completion(responseObject, nil)
            } catch {
                completion(nil, WeatherRequestErrors.couldNotGetWeather)
                print("Error parsign weather data")
            }
        }
        task.resume()
    }
}

//Enum that holds error cases
enum WeatherRequestErrors: Error {
    case couldNotGetWeather
    case couldNotGetWeatherData
}
