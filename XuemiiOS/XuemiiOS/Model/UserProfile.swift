import Foundation

struct UserProfile: Identifiable, Codable, Hashable {
    var id: String { email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)! }
    
    var email: String
    var firstName: String
    var lastName: String?
    var username: String
    var school: String
    var country: String
    var age: Int
    var favoriteAnimal: String
    var favoriteColor: String
    var bioLine: String
}

