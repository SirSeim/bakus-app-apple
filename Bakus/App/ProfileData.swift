import SwiftUI

struct Profile: Codable, Hashable {
    var username: String
    var email: String
    var firstName: String
    var lastName: String
    
    static var example = Profile(
        username: "adamexample",
        email: "adam@example.io",
        firstName: "Adam",
        lastName: "Example"
    )
    static var empty = Profile(username: "", email: "", firstName: "", lastName: "")
}

class ProfileData: ObservableObject {
    @Published var profile: Profile = Profile.empty
    
    static func example() -> ProfileData {
        let example = ProfileData()
        example.profile = Profile.example
        return example
    }
}
