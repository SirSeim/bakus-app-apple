import SwiftUI

struct StartRename: View {
    var addition: Addition

    var body: some View {
        VStack {
            Text("What type of Addition is this?")
            HStack {
                NavigationLink("Movie") {
                    MovieRenameStepOne(addition: addition)
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
        StartRename(addition: Addition.example)
    }
}
