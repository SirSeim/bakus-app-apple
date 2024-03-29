//
//  TVEdit.swift
//  Bakus
//
//  Created by Edward Seim on 2024-03-16.
//

import SwiftUI
import RegexBuilder

struct EpisodeChoice: Identifiable, Equatable {
    var id: String
    
    var includedInSeason: Bool
    var fileName: String
    var multiPartEpisode: Bool
    var episodeStart: String
    var episodeEnd: String
    var useEpisodeTitle: Bool
    var episodeTitle: String

    init(fileName: String) {
        self.id = fileName
        self.includedInSeason = false
        self.fileName = fileName
        self.multiPartEpisode = false
        self.episodeStart = ""
        self.episodeEnd = ""
        self.useEpisodeTitle = false
        self.episodeTitle = ""
    }
    
    init(
        fileName: String,
        includedInSeason: Bool,
        multiPartEpisode: Bool,
        episodeStart: String,
        episodeEnd: String,
        useEpisodeTitle: Bool,
        episodeTitle: String
    ) {
        self.id = fileName
        self.fileName = fileName
        self.includedInSeason = includedInSeason
        self.multiPartEpisode = multiPartEpisode
        self.episodeStart = episodeStart
        self.episodeEnd = episodeEnd
        self.useEpisodeTitle = useEpisodeTitle
        self.episodeTitle = episodeTitle
    }
}

struct TVEdit: View {
    var addition: Addition
    var apiManager: ApiManager
    
    @Binding var state: RenameProcess
    
    @Binding var title: TitleRename
    @Binding var renames: [FileRename]
    
    @State var episodes: [EpisodeChoice] = []
    
    let spaceReplacements = #"[\s()._-]"#
    let showFind = Regex {
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
    let episodeFind = Regex {
        ZeroOrMore(CharacterClass.anyOf("sS").inverted)
        One(.anyOf("sS"))
        Capture {
            Repeat(1...2) {
                One(.digit)
            }
        }
        One(.anyOf("eE"))
        Capture {
            Repeat(1...2) {
                One(.digit)
            }
        }
        Optionally {
            One(.anyOf("_-"))
            Optionally(.anyOf("eE"))
            Capture {
                Repeat(1...2) {
                    One(.digit)
                }
            }
        }
        Repeat(0...3) {
            CharacterClass(
                .anyOf("_-"),
                .whitespace
            )
        }
        Capture {
            ZeroOrMore {
                /./
            }
        }
        "."
        OneOrMore {
            /./
        }
    }
    .anchorsMatchLineEndings()
    
    func buildFileRenames() {
        var newRenames: [FileRename] = []
        
        var epSeason: Int = 0
        if let season = Int(title.season) {
            epSeason = season
        }
        let strSeason = String(format: "%02d", epSeason)
        
        // Add episodes
        for episode in episodes {
            // skip episodes not for this season
            if !episode.includedInSeason {
                continue
            }
            
            // build episode number
            var epNumber = ""
            if let start = Int(episode.episodeStart) {
                epNumber = String(format: "%02d", start)
            }
            if let end = Int(episode.episodeEnd) {
                if episode.multiPartEpisode && end > 0 {
                    epNumber += String(format: "-e%02d", end)
                }
            }
            
            // build episode title
            var epTitle = ""
            if episode.useEpisodeTitle && episode.episodeTitle.count > 0 {
                epTitle = " - \(episode.episodeTitle)"
            }
            
            // add the rename
            newRenames.append(FileRename(
                originalFile: episode.fileName,
                newName: "\(title.description) - s\(strSeason)e\(epNumber)\(epTitle)"
            ))
        }
        
        renames = newRenames
    }
    
    var body: some View {
        Form {
            Section(header: Text("TV Show")) {
                LabeledContent("Original Title", value: addition.name)
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("", text: $title.name)
                        .multilineTextAlignment(.trailing)
                }
                HStack {
                    Text("Year")
                    Spacer()
                    TextField("", text: $title.year)
                        .multilineTextAlignment(.trailing)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }
                HStack {
                    Text("Season")
                    Spacer()
                    TextField("", text: $title.season)
                        .multilineTextAlignment(.trailing)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }
            }
            Section(header: Text("Episodes")) {
                if episodes.count == 0 {
                    Text("None").foregroundColor(.secondary)
                } else {
                    ForEach($episodes) { $episode in
                        VStack {
                            Toggle(isOn: $episode.includedInSeason) {
                                Text("Include in Season")
                            }
                            Group {
                                LabeledContent("Original File", value: episode.fileName)
                                Toggle(isOn: $episode.multiPartEpisode) {
                                    Text("Multi-Episode File")
                                }
                                if episode.multiPartEpisode {
                                    HStack {
                                        Text("Start Episode")
                                        Spacer()
                                        TextField("", text: $episode.episodeStart)
                                            .multilineTextAlignment(.trailing)
                                        #if os(iOS)
                                            .keyboardType(.decimalPad)
                                        #endif
                                    }
                                    HStack {
                                        Text("End Episode")
                                        Spacer()
                                        TextField("", text: $episode.episodeEnd)
                                            .multilineTextAlignment(.trailing)
                                        #if os(iOS)
                                            .keyboardType(.decimalPad)
                                        #endif
                                    }
                                } else {
                                    HStack {
                                        Text("Episode")
                                        Spacer()
                                        TextField("", text: $episode.episodeStart)
                                            .multilineTextAlignment(.trailing)
                                        #if os(iOS)
                                            .keyboardType(.decimalPad)
                                        #endif
                                    }
                                }
                                Toggle(isOn: $episode.useEpisodeTitle) {
                                    Text("Specify Title")
                                }
                                if episode.useEpisodeTitle {
                                    HStack {
                                        Text("Title")
                                        Spacer()
                                        TextField("", text: $episode.episodeTitle)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                            }
                            .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            .disabled(!episode.includedInSeason)
                        }
                    }
                }
            }
            Button {
                buildFileRenames()
                state = .TVSummary
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
        .navigationTitle("Rename TV Show")
        .formStyle(.grouped)
        .onAppear {
            // Determine season based on first episode
            var showSeason: Int? = nil
            for file in addition.videos() {
                if let match = file.name.firstMatch(of: episodeFind) {
                    showSeason = Int(match.output.1)
                    if showSeason != nil {
                        break
                    }
                }
            }
            if let s = showSeason {
                title.season = String(s)
            }
            
            // Generate episode list
            for file in addition.videos() {
                guard let match = file.name.firstMatch(of: episodeFind) else {
                    episodes.append(EpisodeChoice(fileName: file.name))
                    continue
                }
                let episodeSeason = Int(String(match.output.1))
                let inSeason = showSeason != nil && episodeSeason != nil && showSeason == episodeSeason
                var episodeEnd = ""
                if let ee = match.output.3, let eei = Int(ee) {
                    episodeEnd = String(eei)
                }
                let multiPartEpisode = episodeEnd != ""
                var episodeStart = ""
                if let es = Int(String(match.output.2)) {
                    episodeStart = String(es)
                }
                let episodeTitle = String(match.output.4)
                    .replacingOccurrences(of: spaceReplacements, with: " ", options: .regularExpression, range: nil)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                let useEpisodeTitle = episodeTitle != ""
                episodes.append(EpisodeChoice(
                    fileName: file.name,
                    includedInSeason: inSeason,
                    multiPartEpisode: multiPartEpisode,
                    episodeStart: episodeStart,
                    episodeEnd: episodeEnd,
                    useEpisodeTitle: useEpisodeTitle,
                    episodeTitle: episodeTitle
                ))
            }
            
            // Populate Show Details
            if let match = addition.name.firstMatch(of: showFind) {
                title.name = String(match.output.1)
                    .replacingOccurrences(of: spaceReplacements, with: " ", options: .regularExpression, range: nil)
                    .trimmingCharacters(in: .whitespacesAndNewlines)
                title.year = String(match.output.2)
            }
        }
    }
}

#Preview {
    TVEdit(
        addition: Addition.exampleTV,
        apiManager: ApiManager(),
        state: .constant(.TVRename),
        title: .constant(TitleRename()),
        renames: .constant([])
    )
}
