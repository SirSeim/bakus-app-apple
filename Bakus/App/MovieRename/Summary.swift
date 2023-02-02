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
    
    init(originalName: String, title: String, subtitle: SubtitleChoice) {
        self.id = originalName
        self.originalName = originalName
        let ext = (originalName as NSString).pathExtension
        self.newName = "\(title).\(subtitle.language.isoCode()).\(ext)"
    }
}

func getFileExtension(file: String) -> String {
    return (file as NSString).pathExtension
}

struct Summary: View {
    var addition: Addition
    @State var renames: [FileRename]

    var body: some View {
        Form {
            LabeledContent("Original Title", value: addition.name)
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
        }
        .navigationTitle("Rename Summary")
        .formStyle(.grouped)
    }
}

struct Summary_Previews: PreviewProvider {
    static var previews: some View {
        Summary(
            addition: Addition.exampleComplete,
            renames: [
                FileRename(originalName: "old", newName: "new"),
                FileRename(
                    originalName: "video.en.srt",
                    title: "Video (2001)",
                    subtitle: SubtitleChoice(name: "video.en.srt", language: .English)
                ),
                FileRename(
                    originalName: "video.es.srt",
                    title: "Video (2001)",
                    subtitle: SubtitleChoice(name: "video.es.srt", language: .Spanish)
                )
            ]
        )
    }
}
