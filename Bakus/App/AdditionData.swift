import SwiftUI

struct AdditionResults: Codable {
    let results: [Addition]
}

class AdditionData: ObservableObject {
    @Published var additions: [Addition] = []
    
    func remove(id: String) {
        var index: Int? = nil
        for (i, addition) in additions.enumerated() {
            if addition.id == id {
                index = i
            }
        }
        if let index {
            additions.remove(at: index)
        }
    }
    
    func get(id: String) -> Addition? {
        additions.first(where: {$0.id == id})
    }
    
    static func example() -> AdditionData {
        let data = AdditionData()
        data.additions = [
            Addition(
                id: "1",
                state: .Downloading,
                name: "The End",
                progress: 0.4,
                files: [
                    File(name: "The_End.mp4", fileType: .Video),
                ]
            ),
            Addition(
                id: "2",
                state: .Completed,
                name: "A Day In New York", progress: 1.0, files: [
                    File(name: "A.Day.In.New.York.en.mp4", fileType: .Video),
                ]
            ),
            Addition(
                id: "3",
                state: .Downloading,
                name: "Dr. Strangelove or: How I Learned to Stop Worrying and Love the Bomb",
                progress: 0.75,
                files: [
                    File(name: "Dr_Strangelove_or_How_I_Learned_to_Stop_Worrying_and_love_the_Bomb.mov", fileType: .Video),
                    File(name: "Dr_Strangelove_or_How_I_Learned_to_Stop_Worrying_and_love_the_Bomben.en.srt", fileType: .Subtitle),
                ]
            ),
        ]
        return data
    }
}
