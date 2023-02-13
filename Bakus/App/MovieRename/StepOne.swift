import SwiftUI
import RegexBuilder

class TitleRename: ObservableObject, CustomStringConvertible {
    @Published var name : String
    @Published var year : String {
        didSet {
            let filtered = year.filter { $0.isNumber }
            
            if year != filtered {
                year = filtered
            }
        }
    }
    
    init() {
        name = ""
        year = ""
    }
    
    init(name: String, year: Int) {
        self.name = name
        self.year = String(year)
    }
    
    var description: String {
        return "\(name) (\(year))"
    }
}

struct SubtitleChoice: Identifiable {
    var id: String

    var name: String
    var language: Language

    init(name: String, language: Language) {
        self.id = name
        self.name = name
        self.language = language
    }
}

struct MovieRename: View {
    var addition: Addition
    
    let spaceReplacements = #"[\s()._-]"#
    let movieFind = Regex {
      Capture {
        OneOrMore(.digit.inverted)
      }
      Capture {
        Repeat(count: 4) {
          One(.digit)
        }
      }
    }
    .anchorsMatchLineEndings()
    
    @State var title = TitleRename()
    @State var mainFile = File(name: "", fileType: .Video)
    @State var subtitles: [SubtitleChoice] = []

    func fileRenames() -> [FileRename] {
        var newFiles : [FileRename] = []
        
        // Add mainFile
        newFiles.append(FileRename(
            originalName: mainFile.name,
            newName: "\(title).\(getFileExtension(file: mainFile.name))"
        ))
        
        // Add subtitles
        for subtitle in subtitles {
            newFiles.append(FileRename(title: title, subtitle: subtitle))
        }
        
        // Add featurettes
        return newFiles
    }

    var body: some View {
        Form {
            Section(header: Text("Movie")) {
                LabeledContent("Original Title", value: addition.name)
                Picker("File", selection: $mainFile) {
                    ForEach(addition.videos()) { file in
                        Text(file.name).tag(file)
                    }
                }
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("", text: $title.name)
                }
                HStack {
                    Text("Year")
                    Spacer()
                    TextField("", text: $title.year)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }
            }
            Section(header: Text("Subtitles")) {
                if subtitles.count == 0 {
                    Text("None").foregroundColor(.secondary)
                } else {
                    ForEach($subtitles) { $subtitle in
                        Picker(subtitle.name, selection: $subtitle.language) {
                            ForEach(Language.allCases) { language in
                                Text(language.rawValue).tag(language)
                            }
                        }
                    }
                }
            }
            Section(header: Text("Featurettes")) {
                Text("Coming Soon!!").foregroundColor(.secondary)
            }
            NavigationLink("View Summary") {
                Summary(
                    addition: addition,
                    titleRename: title,
                    // TODO: get fileRenames to regenerate on changes
                    renames: self.fileRenames()
                )
            }
        }
        .navigationTitle("Rename Movie")
        .padding(20)
        .formStyle(.grouped)
        .onAppear {
            // Populate file picker
            let videos = addition.videos()
            if videos.count != 0 {
                mainFile = videos[0]
            }
            
            // Generate subtitle list
            for file in addition.subtitles() {
                subtitles.append(SubtitleChoice(name: file.name, language: .English))
            }
            
            // Populate Title and Year
            guard let match = addition.name.firstMatch(of: movieFind) else {
                return
            }
            title.name = String(match.output.1)
                .replacingOccurrences(of: spaceReplacements, with: " ", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            title.year = String(match.output.2)
        }
    }
}

struct MovieRenameStepOne_Previews: PreviewProvider {
    static var previews: some View {
        MovieRename(addition: Addition.example)
    }
}
