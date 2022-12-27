import SwiftUI

struct ProfileSheet: View {
    let apiManager: ApiManager
    @EnvironmentObject var profileData: ProfileData
    
    @State var username: String = ""
    @State var password: String = ""
    @State var loggedIn: Bool = true
    
    @Environment(\.dismiss) var dismiss
    private enum Field: Int, Hashable {
        case username
        case password
    }
    @FocusState private var loginFocus: Field?
    
    func login() {
        loginFocus = nil
        Task {
            await apiManager.login(username: username, password: password)
            await refreshProfile()
        }
    }
    
    func refreshProfile() async {
        loggedIn = apiManager.loggedIn()
        if !loggedIn {
            profileData.profile = Profile.empty
            return
        }
        
        guard let profile = await apiManager.loadProfile() else {
            profileData.profile = Profile.empty
            return
        }
        profileData.profile = profile
    }
    
    func logout() {
        Task {
            await apiManager.logout()
            loggedIn = false
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if loggedIn {
                    KeyValueRow(key: "Username", value: profileData.profile.username)
                    KeyValueRow(key: "Email", value: profileData.profile.email)
                    KeyValueRow(key: "First Name", value: profileData.profile.firstName)
                    KeyValueRow(key: "Last Name", value: profileData.profile.lastName)
                    Spacer()
                    Button("Logout") {
                        logout()
                    }
                } else {
                    TextField("Username", text: $username)
                        .focused($loginFocus, equals: .username)
                        .frame(maxWidth: 300)
                        .padding(20)
                        .onSubmit {
                            loginFocus = .password
                        }
                    SecureField("Password", text: $password)
                        .focused($loginFocus, equals: .password)
                        .frame(maxWidth: 300)
                        .padding([.leading, .bottom, .trailing], 20)
                        .onSubmit {
                            login()
                        }
                    Button {
                        login()
                    } label: {
                        Text("Login")
                    }
                    .onSubmit {
                        login()
                    }
                }
            }
            .padding(30)
            .navigationTitle("Account")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .frame(minWidth: 400)
            .onAppear {
                Task {
                    await refreshProfile()
                    if !loggedIn {
                        DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                            loginFocus = .username
                        }
                    }
                }
            }
            .toolbar {
                ToolbarItem {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ProfileSheet_Previews: PreviewProvider {
    static var previews: some View {
        ProfileSheet(apiManager: ApiManager())
            .environmentObject(ProfileData.example())
    }
}
