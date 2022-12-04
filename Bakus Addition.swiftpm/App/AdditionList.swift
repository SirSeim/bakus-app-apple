import SwiftUI

struct AdditionList: View {
    @EnvironmentObject var additionData: AdditionData
    @EnvironmentObject var profileData: ProfileData
    let apiManager: ApiManager
    
    @State private var showProfile = false
    
    func refreshAdditions() {
        if !apiManager.loggedIn() {
            showProfile = true
        } else {
            print("verify authentication")
            apiManager.authenticated { loggedIn in
                if !loggedIn {
                    print("authentication invalid")
                    showProfile = true
                } else {
                    print("load additions")
                    apiManager.loadAdditions { additions in
                        additionData.additions = additions
                    }
                }
            }
        }
    }
    
    var body: some View {
        List(additionData.additions) { addition in
            AdditionRow(addition: addition)
        }
        .navigationTitle("Additions")
        .onAppear {
            print("first load")
            refreshAdditions()
        }
        .refreshable {
            print("pull refresh additions")
            refreshAdditions()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("button refresh additions")
                    refreshAdditions()
                } label: {
                    Label("Refresh", systemImage: "arrow.2.circlepath")
                }
            }
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showProfile.toggle()
                } label: {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }
                }
                .sheet(isPresented: $showProfile) {
                    ProfileSheet(apiManager: apiManager)
                }
            }
        }
    }
}

struct AdditionList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            AdditionList(apiManager: ApiManager())
                .environmentObject(AdditionData.example())
                .environmentObject(ProfileData.example())
        }
    }
}
