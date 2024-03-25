import SwiftUI

@main
struct BakusApp: App {
    @StateObject private var additionData = AdditionData()
    @StateObject private var profileData = ProfileData()
    private let apiManager = ApiManager()
    
    @State private var additionSelection: Addition.ID?
    
    @State private var showProfile = false
    @State private var showAdd = false
    @State private var refresh = false
    
    var body: some Scene {
        WindowGroup {
            NavigationSplitView {
                AdditionList(apiManager: apiManager, additionSelection: $additionSelection, showProfile: $showProfile, showAdd: $showAdd, refresh: $refresh)
            } detail: {
                if let selection = additionSelection {
                    if let addition = additionData.get(id: selection) {
                        AdditionDetail(addition: addition, apiManager: apiManager)
                    } else {
                        Text("Select an Addition...")
                            .foregroundStyle(.secondary)
                    }
                } else {
                    Text("Select an Addition")
                        .foregroundStyle(.secondary)
                }
            }
            .environmentObject(additionData)
            .environmentObject(profileData)
        }
        .commands {
            SidebarCommands()
            CommandGroup(before: .appSettings) {
                Button("Account") {
                    showProfile = true
                }.keyboardShortcut(",")
            }
            CommandGroup(before: .newItem) {
                Button("Add Addition") {
                    showAdd = true
                }.keyboardShortcut("n")
            }
            CommandGroup(before: .toolbar) {
                Button("Refresh") {
                    refresh = true
                    Task {
                        if !apiManager.loggedIn() {
                            showProfile = true
                            return
                        }
                        
                        print("verify authentication")
                        let loggedIn = await apiManager.authenticated()
                        if !loggedIn {
                            print("authentication invalid")
                            showProfile = true
                            return
                        }
                        
                        print("load additions")
                        guard let additions = await apiManager.loadAdditions() else {
                            return
                        }
                        additionData.additions = additions
                        refresh = false
                    }
                }.keyboardShortcut("r")
            }
        }
    }
}
