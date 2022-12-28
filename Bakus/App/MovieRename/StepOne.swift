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


struct MovieRenameStepOne: View {
    var addition: Addition
    
    let spaceReplacements = #"[\s()._-]"#
    
    @State var title = ""
    @ObservedObject var year = NumbersOnly()

    var body: some View {
        VStack {
            Form {
                Section(header: Text("Title")) {
                    Text("Original Title: \(addition.name)")
                        .foregroundColor(.secondary)
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
                    Text("TBD")
                }
                Section(header: Text("Featurettes")) {
                    Text("TBD")
                }
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
        }
    }
}

struct MovieRenameStepOne_Previews: PreviewProvider {
    static var previews: some View {
        MovieRenameStepOne(addition: Addition.example)
    }
}
