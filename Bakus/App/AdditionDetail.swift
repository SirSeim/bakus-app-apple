import SwiftUI

enum RenameProcess {
    case Detail
    case MovieRename
    case MovieSummary
    case TVRename
    case TVSummary
}

struct AdditionDetail: View {
    var addition: Addition
    var apiManager: ApiManager

    @State var state: RenameProcess = .Detail

    @State var title: TitleRename = TitleRename()
    @State var files: [FileRename] = []

    var body: some View {
        Group {
            switch state {
            case .Detail:
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
                        Menu {
                            Button("Movie") {
                                state = .MovieRename
                            }
                            Button("TV Show") {
                                state = .TVRename
                            }
                        } label: {
                            Text("Start Rename")
                        }
                        .buttonStyle(.bordered)
                        .disabled(addition.state != .Completed)
                    }
                    List(addition.files) { file in
                        FileRow(file: file)
                    }
                    .scrollContentBackground(.hidden)
                }
                .navigationTitle(addition.name)
                .padding(20)
            case .MovieRename:
                MovieRename(addition: addition, apiManager: apiManager, state: $state, title: $title, fileRenames: $files)
            case .MovieSummary:
                Summary(addition: addition, apiManager: apiManager, titleRename: title, renames: $files)
            case .TVRename:
                TVEdit(addition: addition, apiManager: apiManager, state: $state, title: $title, renames: $files)
            case .TVSummary:
                TVSummary(addition: addition, apiManager: apiManager, titleRename: title, renames: $files)
            }
        }
        .onChange(of: addition) { _ in
            state = .Detail
            title = TitleRename()
            files = []
        }
    }
}

struct AdditionDetail_Previews: PreviewProvider {
    static var previews: some View {
        AdditionDetail(addition: Addition.example, apiManager: ApiManager())
        AdditionDetail(addition: Addition.exampleComplete, apiManager: ApiManager())
    }
}
