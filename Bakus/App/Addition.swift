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


struct File: Codable, Identifiable, Hashable {
    var id: String
    
    var name: String
    var fileType: FileType
    
    init(name: String, fileType: FileType) {
        self.id = name
        self.name = name
        self.fileType = fileType
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.id = self.name
        self.fileType = try container.decode(FileType.self, forKey: .fileType)
    }
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
