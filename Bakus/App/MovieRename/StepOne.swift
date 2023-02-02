import SwiftUI
import RegexBuilder

class NumbersOnly: ObservableObject {
    @Published var value = "" {
        didSet {
            let filtered = value.filter { $0.isNumber }
            
            if value != filtered {
                value = filtered
            }
        }
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
    
    @State var title = ""
    @ObservedObject var year = NumbersOnly()
    @State var mainFile = File(name: "", fileType: .Video)
    @State var subtitles = [SubtitleChoice]()

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
                    TextField("", text: $title)
                }
                HStack {
                    Text("Year")
                    Spacer()
                    TextField("", text: $year.value)
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
            title = String(match.output.1)
                .replacingOccurrences(of: spaceReplacements, with: " ", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
            year.value = String(match.output.2)
        }
    }
}

struct MovieRenameStepOne_Previews: PreviewProvider {
    static var previews: some View {
        MovieRename(addition: Addition.example)
    }
}
