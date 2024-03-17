//
//  TVSummary.swift
//  Bakus
//
//  Created by Edward Seim on 2024-03-17.
//

import SwiftUI

struct TVSummary: View {
    @EnvironmentObject var additionData: AdditionData
    
    var addition: Addition
    var apiManager: ApiManager
    
    var titleRename: TitleRename
    var season: String
    
    @State var renames: [FileRename]
    @State var deleteRest = false
    @State var untouchedFiles: [File] = []
    
    @State var doingRename = false
    @State var doneRename = false
    
    var body: some View {
        if !doneRename {
            Form {
                LabeledContent("Original Title", value: addition.name)
                LabeledContent("New Title", value: titleRename.description)
                LabeledContent("Season", value: season)
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
                Button("Rename TV Show") {
                    print("renaming tv")
                    doingRename =  true
                    
                    guard let seasonInt = Int(season) else {
                        print("year must be int \(season)")
                        // TODO: show actual error
                        doingRename = false
                        return
                    }
                    Task {
                        _ = await apiManager.renameTV(addition_id: addition.id, title: titleRename.description, season: seasonInt, deleteRest: deleteRest, files: renames)
                        
                        print("rename tv request done")
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
    TVSummary(
        addition: Addition.exampleTV,
        apiManager: ApiManager(),
        titleRename: TitleRename(name: "Mystery Science Theater 3000", year: 1988),
        season: "1",
        renames: [
            FileRename(originalFile: "mst3k_s01e01-02.mov", newName: "mst3k - S01E01-02"),
            FileRename(originalFile: "mst3k_s01e03_Real_Run.mp4", newName: "mst3k - S01E03 - Real Run")
        ]
    )
}
