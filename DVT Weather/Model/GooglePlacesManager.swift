//
//  GooglePlacesManager.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/04/24.
//

import Foundation
import GooglePlaces
import CoreLocation

struct Place {
    let name: String
    let identifier: String
}

struct GooglePlace {
    let coordinates: CLLocationCoordinate2D
    let name: String
}

class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    
    enum PlacesError: Error {
        case failedToFind
        case failedToGetCoordinates
    }
    
    /// Function that contacts the Places API once a search query has been added
    public func findPlace(query: String, completion: @escaping (Result<[Place], Error>) -> Void) {
        let filter = GMSAutocompleteFilter()
        filter.types = ["geocode"]
        // A method that has auto complete functionality as a user
        // types in a search query
        client.findAutocompletePredictions(fromQuery: query, filter: filter, sessionToken: nil) {
            results, error in
            guard let results = results, error == nil else {
                completion(.failure(PlacesError.failedToFind))
                return
            }
            
            let places: [Place] = results.compactMap({
                Place(name: $0.attributedFullText.string, identifier: $0.placeID)
            })
            
            completion(.success(places))
        }
    }
    
    /// Function that finds the name of the location as well as its coordinates
    public func resloveLocation(for place: Place, completion: @escaping (Result<GooglePlace, Error>) -> Void) {
        let fields: GMSPlaceField = GMSPlaceField(rawValue: UInt64(UInt(GMSPlaceField.coordinate.rawValue) |
                                                                   UInt(GMSPlaceField.name.rawValue)))
        
        // Method that finds information reletad to the selected place
        client.fetchPlace(fromPlaceID: place.identifier, placeFields: fields, sessionToken: nil) {
            googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                print("Error: \(error!)")
                completion(.failure(PlacesError.failedToGetCoordinates))
                return
            }
            
            // Coordinate constant to be used in other files
            let coordinate = CLLocationCoordinate2D(latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
            
            completion(.success(GooglePlace(coordinates: coordinate, name: googlePlace.name!)))
            
        }
    }
}


