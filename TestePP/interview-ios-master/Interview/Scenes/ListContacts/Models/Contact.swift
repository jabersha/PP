import Foundation
import UIKit


class Contact: Codable {
    var id: Int
    var name: String = ""
    var photoURL = ""
    var img: UIImage?
    
    init(id: Int, name: String, photoURL: String, img: UIImage) {
        self.id = id
        self.name = name
        self.photoURL = photoURL
        self.img = img
        
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "name"
        case photoURL = "photoURL"
        case id = "id"
    }
}

