import SwiftUI

struct AdditionRow: View {
    let addition: Addition
    
    var body: some View {
        HStack {
            Text(addition.name)
                .fontWeight(.bold)
                .lineLimit(1)
                .truncationMode(.tail)
            Spacer()
            ProgressCircle(progress: addition.progress)
                .frame(width: 15, height: 15, alignment: .leading)
        }
    }
}

struct AdditionRow_Previews: PreviewProvider {
    static var previews: some View {
        AdditionRow(addition: Addition.example)
    }
}
