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
    @Published var season : String {
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
        season = ""
    }
    
    init(name: String, year: Int) {
        self.name = name
        self.year = String(year)
        self.season = ""
    }
    
    init(name: String, year: Int, season: Int) {
        self.name = name
        self.year = String(year)
        self.season = String(season)
    }
    
    var description: String {
        return "\(name) (\(year))"
    }
}

struct SubtitleChoice: Identifiable, Equatable {
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
    var apiManager: ApiManager
    
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
    
    @Binding var state: RenameProcess
    
    @Binding var title: TitleRename
    @Binding var fileRenames: [FileRename]
    
    @State var mainFile = File(name: "", fileType: .Video)
    @State var subtitles: [SubtitleChoice] = []

    func buildFileRenames() {
        var newRenames: [FileRename] = []
        // Add mainFile
        newRenames.append(FileRename(
            originalName: mainFile.name,
            newName: "\(title).\(getFileExtension(file: mainFile.name))"
        ))
        
        // Add subtitles
        for subtitle in subtitles {
            newRenames.append(FileRename(title: title, subtitle: subtitle))
        }
        
        // TODO: Add featurettes
        fileRenames = newRenames
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
            Button {
                buildFileRenames()
                state = .MovieSummary
            } label: {
                HStack {
                    Text("Continue")
                    #if os(iOS)
                    Spacer()
                    #endif
                    Image(systemName: "chevron.right")
                }
            }
        }
        .navigationTitle("Rename Movie")
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

#Preview {
    MovieRename(
        addition: Addition.example,
        apiManager: ApiManager(),
        state: .constant(.MovieRename),
        title: .constant(TitleRename()),
        fileRenames: .constant([])
    )
}
