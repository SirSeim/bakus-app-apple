//
//  TVEdit.swift
//  Bakus
//
//  Created by Edward Seim on 2024-03-16.
//

import SwiftUI

struct EpisodeChoice: Identifiable, Equatable {
    var id: String
    
    var includedInSeason: Bool
    var fileName: String
    var multiPartEpisode: Bool
    var episodeStart: String
    var episodeEnd: String
    var useEpisodeTitle: Bool
    var episodeTitle: String
    
}

struct TVEdit: View {
    var addition: Addition
    var apiManager: ApiManager
    
    @State var title = ""
    @State var year = ""
    @State var season = ""
    
    @State var episodes: [EpisodeChoice] = []
    
    var body: some View {
        Form {
            Section(header: Text("TV Show")) {
                LabeledContent("Original Title", value: addition.name)
                HStack {
                    Text("Title")
                    Spacer()
                    TextField("", text: $title)
                }
                HStack {
                    Text("Year")
                    Spacer()
                    TextField("", text: $year)
                    #if os(iOS)
                        .keyboardType(.decimalPad)
                    #endif
                }
                HStack {
                    Text("Season")
                    Spacer()
                    TextField("", text: $season)
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
                            LabeledContent("Original File", value: episode.fileName)
                                .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            Toggle(isOn: $episode.multiPartEpisode) {
                                Text("Multi-Episode File")
                            }
                            .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            .disabled(!episode.includedInSeason)
                            if episode.multiPartEpisode {
                                HStack {
                                    Text("Start Episode")
                                    Spacer()
                                    TextField("", text: $episode.episodeStart)
                                        .disabled(!episode.includedInSeason)
#if os(iOS)
                                        .keyboardType(.decimalPad)
#endif
                                }
                                .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                                HStack {
                                    Text("End Episode")
                                    Spacer()
                                    TextField("", text: $episode.episodeEnd)
                                        .disabled(!episode.includedInSeason)
#if os(iOS)
                                        .keyboardType(.decimalPad)
#endif
                                }
                                .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            } else {
                                HStack {
                                    Text("Episode")
                                    Spacer()
                                    TextField("", text: $episode.episodeStart)
                                        .disabled(!episode.includedInSeason)
#if os(iOS)
                                        .keyboardType(.decimalPad)
#endif
                                }
                                .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            }
                            Toggle(isOn: $episode.useEpisodeTitle) {
                                Text("Specify Title")
                            }
                            .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            .disabled(!episode.includedInSeason)
                            if episode.useEpisodeTitle {
                                HStack {
                                    Text("Title")
                                    Spacer()
                                    TextField("", text: $episode.episodeTitle)
                                        .disabled(!episode.includedInSeason)
                                }
                                .foregroundColor(episode.includedInSeason ? .primary : .secondary)
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Rename TV Show")
        .formStyle(.grouped)
        .onAppear {
            // Generate episode list
            for file in addition.videos() {
                // TODO: fill in properly
                episodes.append(EpisodeChoice(
                    id: file.name,
                    includedInSeason: true,
                    fileName: file.name,
                    multiPartEpisode: true,
                    episodeStart: "2",
                    episodeEnd: "3",
                    useEpisodeTitle: true,
                    episodeTitle: "Howling"
                ))
            }
            
            // Populate Season Details
            // TODO: do it
        }
    }
}

#Preview {
    TVEdit(addition: Addition.example, apiManager: ApiManager())
}
