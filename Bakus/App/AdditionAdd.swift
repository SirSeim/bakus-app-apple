import SwiftUI

struct AdditionAdd: View {
    let apiManager: ApiManager
    @EnvironmentObject var additionData: AdditionData

    @State var link: String = ""
    @State var adding = false

    @Environment(\.dismiss) var dismiss

    private enum Field: Int {
        case link
    }
    @FocusState private var addFocus: Field?
    
    func add() {
        if link.count == 0 {
            return
        }
        addFocus = nil
        adding = true
        Task {
            _ = await apiManager.addAddition(link: link)
            adding = false
            dismiss()
        }
    }

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Magnet link", text: $link)
                    .focused($addFocus, equals: .link)
                    .frame(maxWidth: 300)
                    .padding(20)
                    .onSubmit {
                        add()
                    }
                Spacer()
            }
            .padding(30)
            .navigationTitle("Add Addition")
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .frame(minWidth: 400)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        add()
                    }
                    .onSubmit {
                        add()
                    }
                    .disabled(link.count == 0)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now()+0.5) {
                    addFocus = .link
                }
            }
        }
    }
}

struct AdditionAdd_Previews: PreviewProvider {
    static var previews: some View {
        AdditionAdd(apiManager: ApiManager())
    }
}
