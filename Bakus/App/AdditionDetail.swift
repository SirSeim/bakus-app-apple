import SwiftUI

struct AdditionDetail: View {
    var addition: Addition

    var body: some View {
        VStack {
            HStack {
                Text(addition.name)
                Spacer()
            }
            HStack {
                ProgressCircle(progress: addition.progress, state: addition.state)
                    .frame(maxHeight: 20)
                if addition.state == .Completed {
                    Text("Download complete")
                } else {
                    Text("\(NSString(format: "%.1f", addition.progress * 100))% Downloaded")
                }
                Spacer()
                if addition.state == .Completed {
                    NavigationLink("Start Rename") {
                        StartRename(addition: addition)
                    }
                    .buttonStyle(.bordered)
                }
            }
            List(addition.files) { file in
                FileRow(file: file)
            }
            .scrollContentBackground(.hidden)
        }
        .navigationTitle(addition.name)
        .padding(20)
    }
}

struct AdditionDetail_Previews: PreviewProvider {
    static var previews: some View {
        AdditionDetail(addition: Addition.example)
        AdditionDetail(addition: Addition.exampleComplete)
    }
}
