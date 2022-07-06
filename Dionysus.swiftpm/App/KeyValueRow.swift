import SwiftUI

struct KeyValueRow: View {
    let key: String
    let value: String
    
    var body: some View {
        HStack {
            Text(key)
                .font(.headline)
            Spacer()
            Text(value)
                .font(.headline)
                .foregroundColor(.secondary)
        }
        .padding(.bottom, 10)
    }
}

struct KeyValueRow_Previews: PreviewProvider {
    static var previews: some View {
        KeyValueRow(key: "Title", value: "Value")
    }
}
