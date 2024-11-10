//
//  Movie.swift
//  MovieDBPractice
//
//  Created by Alwan on 06/11/24.
//

import Foundation
import SwiftyJSON

class Movie {
    var id: String = ""
    var title: String = ""
    var releaseDate: String = ""
    var overview: String = ""
    var posterPath: String = ""
    
    func populateJSON(_ json: JSON) -> Void{
        id = json["id"].stringValue
        title = json["original_title"].stringValue
        releaseDate = json["release_date"].stringValue
        overview = json["overview"].stringValue
        posterPath = json["poster_path"].stringValue
    }
    
}
