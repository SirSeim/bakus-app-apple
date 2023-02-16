import SwiftUI

struct StartRename: View {
    var addition: Addition
    var apiManager: ApiManager

    var body: some View {
        VStack {
            Text("What type of Addition is this?")
            HStack {
                NavigationLink("Movie") {
                    MovieRename(addition: addition, apiManager: apiManager)
                }
                Button("TV Show") {}
                    .disabled(true)
            }
            .padding(10)
        }
    }
}

struct StartRename_Previews: PreviewProvider {
    static var previews: some View {
        StartRename(addition: Addition.example, apiManager: ApiManager())
    }
}
