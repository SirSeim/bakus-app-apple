import SwiftUI

struct AdditionList: View {
    @EnvironmentObject var additionData: AdditionData
    @EnvironmentObject var profileData: ProfileData
    let apiManager: ApiManager
    
    @State private var showProfile = false
    
    var body: some View {
        List(additionData.additions) { addition in
            AdditionRow(addition: addition)
        }
        .navigationTitle("Additions")
        .onAppear {
            if !apiManager.loggedIn() {
                showProfile = true
            } else {
                print("first load additions")
                apiManager.loadAdditions { additions in
                    additionData.additions = additions
                }
            }
        }
        .refreshable {
            print("pull refresh additions")
            apiManager.loadAdditions { additions in
                additionData.additions = additions
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    print("button refresh additions")
                    apiManager.loadAdditions { additions in
                        additionData.additions = additions
                    }
                } label: {
                    Image(systemName: "arrow.2.circlepath")
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
