//
//  FlickrClient.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import Foundation

class FlickrClient {
    
    enum EndPoints {
        static let base = "https://www.flickr.com/services/rest/?method=flickr.photos.search"
        static let apiKey = "42216ccbfda3f3474d66e05a6813b4ab"
        
        case getPhotos(Double, Double)
        
        var stringValue: String {
            switch self {
            case .getPhotos(let latitude, let longitude):
                return EndPoints.base + "&api_key=\(EndPoints.apiKey)" + "&lat=\(latitude)&lon=\(longitude)" + "&extras=url_z&per_page=5&page=1&format=json&nojsoncallback=1"
            }
        }
        
        var url: URL? {
            guard let url = URL(string: stringValue) else {
                return nil
            }
            return url
        }
    }
    
    class func getPhotoURL(latitude: Double, longitude: Double) async throws -> FlickrPhoto {
        
        guard let request = EndPoints.getPhotos(latitude, longitude).url else {
            throw PhotoRequestErrors.invalidURL
        }
        
        let (data, response) = try await URLSession.shared.data(from: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw PhotoRequestErrors.couldNotGetPhotos
        }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(FlickrPhoto.self, from: data)
            // Data from the API is made available here
        } catch {
            print("Error parsign weather data")
            throw PhotoRequestErrors.couldNotGetPhotoURL
        }
        
    }
    
    class func getPhotoData(url: URL) async throws -> Data {
        
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw PhotoRequestErrors.couldNotGetPhotoData
        }
        
        return data
        
    }
}

//Enum that holds error cases
enum PhotoRequestErrors: Error {
    case invalidURL
    case couldNotGetPhotos
    case couldNotGetPhotoData
    case couldNotGetPhotoURL
}
