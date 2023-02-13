import SwiftUI

struct FileRename: Identifiable, Codable {
    var id: String
    
    var originalName: String
    var newName: String

    init(originalName: String, newName: String) {
        self.id = originalName
        self.originalName = originalName
        self.newName = newName
    }
    
    init(title: TitleRename, subtitle: SubtitleChoice) {
        self.id = subtitle.name
        self.originalName = subtitle.name
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
    var titleRename: TitleRename
    @State var renames: [FileRename]
    
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
                                Text(rename.originalName)
                                Spacer()
                            }
                            HStack {
                                Label("", systemImage: "arrow.turn.down.right")
                                TextField("", text: $rename.newName, prompt: Text("New Filename"))
                            }
                        }
                    }
                }
                Button("Submit Rename") {
                    print("doing stuff")
                    additionData.remove(id: addition.id)
                    doneRename = true
                }
            }
            .navigationTitle("Rename Summary")
            .formStyle(.grouped)
        } else {
            Text("Select an Addition")
                .foregroundStyle(.secondary)
                .navigationTitle("")
        }
    }
}

struct Summary_Previews: PreviewProvider {
    static var previews: some View {
        Summary(
            addition: Addition.exampleComplete,
            titleRename: TitleRename(name: "The Day the Earth Stood Still", year: 1951),
            renames: [
                FileRename(originalName: "old", newName: "new"),
                FileRename(
                    title: TitleRename(name: "Video", year: 2001),
                    subtitle: SubtitleChoice(name: "video.en.srt", language: .English)
                ),
                FileRename(
                    title: TitleRename(name: "Video", year: 2001),
                    subtitle: SubtitleChoice(name: "video.es.srt", language: .Spanish)
                )
            ]
        )
    }
}
