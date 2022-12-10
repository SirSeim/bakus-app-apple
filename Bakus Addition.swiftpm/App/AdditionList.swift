import SwiftUI

struct AdditionList: View {
    @EnvironmentObject var additionData: AdditionData
    @EnvironmentObject var profileData: ProfileData
    let apiManager: ApiManager
    
    @State private var showProfile = false
    
    func refreshAdditions() async {
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
    }
    
    var body: some View {
        List(additionData.additions) { addition in
            AdditionRow(addition: addition)
        }
        .navigationTitle("Additions")
        .onAppear {
            print("first load")
            Task {
                await refreshAdditions()
            }
        }
        .refreshable {
            print("pull refresh additions")
            await refreshAdditions()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    print("button refresh additions")
                    Task {
                        await refreshAdditions()
                    }
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
