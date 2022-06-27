import SwiftUI


enum FileType : String, Codable {
    case Video = "VID"
    case Subtitle = "SUB"
    case Image = "IMG"
    case Other = "OTH"
}


enum AdditionState : String, Codable {
    case Downloading = "DW"
    case Completed = "CP"
}


struct File: Codable, Hashable {
    var name: String
    var fileType: FileType
}


struct Addition: Codable, Identifiable, Hashable {
    var id: String
    
    var state: AdditionState
    var name: String
    var progress: Double
    var files: [File]
    
    static var example = Addition(
        id: "101",
        state: .Downloading,
        name: "The Thing",
        progress: 0.5,
        files: [
            File(name: "The_Thing.mp4", fileType: .Video),
        ]
    )
}
