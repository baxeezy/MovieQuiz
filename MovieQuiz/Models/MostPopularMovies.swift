import UIKit

struct MostPopularMovies: Codable {
    let errorMessage: String
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let imDbRating: String
    let image: URL
    let year: String
    
    var resizedImageURL: URL {
            let urlString = image.absoluteString
            let imageUrlString = urlString.components(separatedBy: "._")[0] + "._V0_UX600_.jpg"
            guard let newURL = URL(string: imageUrlString) else {
                return image
            }
            return newURL
        }
}
