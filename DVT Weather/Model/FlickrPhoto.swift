//
//  FlickrPhoto.swift
//  DVT Weather
//
//  Created by Oneh Zinde on 2023/11/09.
//

import Foundation


struct FlickrPhoto: Codable {
    let photos: Flickr
}

struct Flickr: Codable {
    let photo: [Photo]
}

struct Photo: Codable {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "url_z"
    }
}
