import SwiftUI

struct AdditionList: View {
    @EnvironmentObject var additionData: AdditionData
    @EnvironmentObject var profileData: ProfileData
    let apiManager: ApiManager
    
    @Binding var showProfile: Bool
    @Binding var showAdd: Bool
    @Binding var refresh: Bool
    
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
            refresh = true
            Task {
                await refreshAdditions()
                refresh = false
            }
        }
        .refreshable {
            print("pull refresh additions")
            refresh = true
            await refreshAdditions()
            refresh = false
        }
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAdd.toggle()
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
            #if os(iOS)
            ToolbarItem(placement: .bottomBar) {
                Button {
                    showProfile.toggle()
                } label: {
                    HStack {
                        Image(systemName: "person.circle")
                        Text("Account")
                    }
                }
            }
            #endif
            #if os(macOS)
            ToolbarItem {
                Button {
                    print("button refresh additions")
                    refresh = true
                    Task {
                        await refreshAdditions()
                        refresh = false
                    }
                } label: {
                    if refresh {
                        ProgressView()
                            .scaleEffect(0.6)
                    } else {
                        Label("Refresh", systemImage: "arrow.2.circlepath")
                    }
                }
            }
            #endif
        }
        .sheet(isPresented: $showProfile) {
            ProfileSheet(apiManager: apiManager)
        }
        .sheet(isPresented: $showAdd) {
            AdditionAdd(apiManager: apiManager)
        }
    }
}

struct AdditionList_Previews: PreviewProvider {
    @State static var showProfile = false
    @State static var showAdd = false
    @State static var refresh = false
    static var previews: some View {
        NavigationSplitView {
            AdditionList(apiManager: ApiManager(), showProfile: $showProfile, showAdd: $showAdd, refresh: $refresh)
                .environmentObject(AdditionData.example())
                .environmentObject(ProfileData.example())
        } detail: {
            Text("content")
        }
    }
}
