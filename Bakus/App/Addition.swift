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

    func isType(filter: FileType) -> Bool {
        return self.fileType == filter
    }
}


struct Addition: Codable, Identifiable, Hashable {
    var id: String
    
    var state: AdditionState
    var name: String
    var progress: Double
    var files: [File]

    func videos() -> [File] {
        return self.files.filter({ $0.isType(filter: .Video) })
    }

    func subtitles() -> [File] {
        return self.files.filter({ $0.isType(filter: .Subtitle) })
    }
    
    static var example = Addition(
        id: "101",
        state: .Downloading,
        name: "The_Thing_(1982)",
        progress: 0.5,
        files: [
            File(name: "The_Thing.mp4", fileType: .Video),
            File(name: "feature.mp4", fileType: .Video),
            File(name: "sub.en.srt", fileType: .Subtitle),
            File(name: "sub.es.srt", fileType: .Subtitle),
        ]
    )
    
    static var exampleComplete = Addition(
        id: "201",
        state: .Completed,
        name: "The_Day_the_Earth_Stood_Still_(1951)",
        progress: 1.0,
        files: [
            File(name: "the_day_the_earth_stood_still_1951.mp4", fileType: .Video),
            File(name: "feature.mp4", fileType: .Video),
            File(name: "sub.en.srt", fileType: .Subtitle),
            File(name: "sub.es.srt", fileType: .Subtitle),
        ]
    )
}
