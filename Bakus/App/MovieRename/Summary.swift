import SwiftUI

struct FileRename: Identifiable, Codable {
    var id: String
    
    var currentName: String
    var newName: String

    init(originalName: String, newName: String) {
        self.id = originalName
        self.currentName = originalName
        self.newName = newName
    }
    
    init(originalFile: String, newName: String) {
        self.id = originalFile
        self.currentName = originalFile
        let ext = getFileExtension(file: originalFile)
        self.newName = "\(newName).\(ext)"
    }
    
    init(title: TitleRename, subtitle: SubtitleChoice) {
        self.id = subtitle.name
        self.currentName = subtitle.name
        let ext = (subtitle.name as NSString).pathExtension
        self.newName = "\(title).\(subtitle.language.isoCode()).\(ext)"
    }
}

func getFileExtension(file: String) -> String {
    return (file as NSString).pathExtension
}

struct Summary: View {
    @EnvironmentObject var additionData: AdditionData

    var addition: Addition
    var apiManager: ApiManager
    var titleRename: TitleRename
    @State var deleteRest = false
    @Binding var renames: [FileRename]
    @State var untouchedFiles: [File] = []
    
    @State var doingRename = false
    @State var doneRename = false

    var body: some View {
        if !doneRename {
            Form {
                LabeledContent("Original Title", value: addition.name)
                LabeledContent("New Title", value: titleRename.description)
                Section("Files") {
                    ForEach($renames) { $rename in
                        VStack {
                            HStack {
                                Text(rename.currentName)
                                Spacer()
                            }
                            HStack {
                                Label("", systemImage: "arrow.turn.down.right")
                                TextField("", text: $rename.newName, prompt: Text("New Filename"))
                            }
                        }
                    }
                }
                Section("Untouched Files") {
                    Toggle(isOn: $deleteRest) {
                        Text("Delete Untouched Files")
                    }
                    ForEach(untouchedFiles) { untouchedFile in
                        HStack {
                            if deleteRest {
                                Label("", systemImage: "multiply.circle")
                                    .foregroundColor(.red)
                            } else {
                                Label("", systemImage: "minus.circle")
                                    .foregroundColor(.gray)
                            }
                            FileRow(file: untouchedFile)
                        }
                    }
                }
                Button("Rename Movie") {
                    print("renaming movie")
                    doingRename =  true
                    
                    Task {
                        _ = await apiManager.renameMovie(addition_id: addition.id, title: titleRename.description, deleteRest: deleteRest, files: renames)
                        
                        print("rename movie request done")
                        additionData.remove(id: addition.id)
                        doingRename = false
                        doneRename = true
                    }
                }
                .disabled(doingRename)
            }
            .navigationTitle("Rename Summary")
            .formStyle(.grouped)
            .onAppear {
                for file in addition.files {
                    var found = false
                    for renamedFile in renames {
                        if renamedFile.currentName == file.name {
                            found = true
                        }
                    }
                    if found {
                        continue
                    }
                    print("file not in renames \(file.name)")
                    untouchedFiles.append(file)
                }
            }
        } else {
            Text("Select an Addition")
                .foregroundStyle(.secondary)
                .navigationTitle("")
        }
    }
}

#Preview {
    Summary(
        addition: Addition.exampleComplete,
        apiManager: ApiManager(),
        titleRename: TitleRename(name: "The Day the Earth Stood Still", year: 1951),
        renames: .constant([
            FileRename(originalName: "old", newName: "new"),
            FileRename(
                title: TitleRename(name: "Video", year: 2001),
                subtitle: SubtitleChoice(name: "video.en.srt", language: .English)
            ),
            FileRename(
                title: TitleRename(name: "Video", year: 2001),
                subtitle: SubtitleChoice(name: "video.es.srt", language: .Spanish)
            )
        ])
    )
}
