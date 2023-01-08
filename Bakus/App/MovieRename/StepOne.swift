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

struct MovieRenameStepOne: View {
    var addition: Addition
    
    let spaceReplacements = #"[\s()._-]"#
    
    @State var title = ""
    @ObservedObject var year = NumbersOnly()
    @State var mainFile = File(name: "", fileType: .Video)
    @State var subtitles = [SubtitleChoice]()

    var body: some View {
        Form {
            Section(header: Text("Movie")) {
                Text("Original Title: \(addition.name)")
                    .foregroundColor(.secondary)
                Picker("File", selection: $mainFile) {
                    ForEach(addition.videos()) { file in
                        Text(file.name).tag(file)
                    }
                }
                HStack {
                    Text("Title")
                    TextField("", text: $title)
                }
                HStack {
                    Text("Year")
                    TextField("", text: $year.value)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }
            }
            Section(header: Text("Subtitles")) {
                ForEach(subtitles) { subtitle in
                    HStack {
                        Text(subtitle.name)
//                        Spacer()
//                        Picker(selection: subtitle.language) {
//                            ForEach(Language.allCases) { language in
//                                Text(language).tag(language)
//                            }
//                        }
                    }
                }
            }
            Section(header: Text("Featurettes")) {
                Text("TBD")
            }
        }
        .navigationTitle("Rename Movie: Step 1")
        .padding(20)
        .onAppear {
            let movie = addition.name
            guard let match = movie.firstMatch(of: movieFind) else {
                return
            }
            
            title = String(match.output.1)
                .replacingOccurrences(of: spaceReplacements, with: " ", options: .regularExpression, range: nil)
                .trimmingCharacters(in: .whitespacesAndNewlines)
                
            year.value = String(match.output.2)
            
            for file in addition.subtitles() {
                subtitles.append(SubtitleChoice(name: file.name, language: .English))
            }
        }
    }
}

struct MovieRenameStepOne_Previews: PreviewProvider {
    static var previews: some View {
        MovieRenameStepOne(addition: Addition.example)
    }
}
