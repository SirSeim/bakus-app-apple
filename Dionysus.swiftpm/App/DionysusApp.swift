import SwiftUI

@main
struct DionysusApp: App {
    @StateObject private var additionData = AdditionData()
    @StateObject private var profileData = ProfileData()
    private let apiManager = ApiManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                AdditionList(apiManager: apiManager)
                Text("Select an Addition")
                    .foregroundStyle(.secondary)
            }
            .environmentObject(additionData)
            .environmentObject(profileData)
        }
    }
}
