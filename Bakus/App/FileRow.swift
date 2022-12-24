import SwiftUI

struct FileRow: View {
    var file: File

    var body: some View {
        switch file.fileType {
        case .Video:
            Label(file.name, systemImage: "play.rectangle")
        case .Subtitle:
            Label(file.name, systemImage: "captions.bubble")
        case .Image:
            Label(file.name, systemImage: "photo.artframe")
        case .Other:
            Label(file.name, systemImage: "doc")
        }
    }
}

struct FileRow_Previews: PreviewProvider {
    static var previews: some View {
        List {
            FileRow(file: File(name: "Video.mp4", fileType: .Video))
            FileRow(file: File(name: "Subtitle.srt", fileType: .Subtitle))
            FileRow(file: File(name: "Poster.png", fileType: .Image))
            FileRow(file: File(name: "readme.txt", fileType: .Other))
        }
        .scrollContentBackground(.hidden)
    }
}
