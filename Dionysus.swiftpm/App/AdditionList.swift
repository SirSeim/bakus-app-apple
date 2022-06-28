import SwiftUI

struct AdditionList: View {
    @EnvironmentObject var additionData: AdditionData
    let apiManager: ApiManager
    
    var body: some View {
        List(additionData.additions) { addition in
            AdditionRow(addition: addition)
        }
        .navigationTitle("Additions")
        .onAppear {
            print("first load additions")
            apiManager.loadAdditions { additions in 
                print("recieved additions")
                additionData.additions = additions
            }
        }
        .refreshable {
            print("pull refresh additions")
            apiManager.loadAdditions { additions in 
                print("recieved additions")
                additionData.additions = additions
            }
        }
        .toolbar {
            ToolbarItem {
                Button {
                    print("button refresh additions")
                    apiManager.loadAdditions { additions in 
                        print("recieved additions")
                        additionData.additions = additions
                    }
                } label: {
                    Image(systemName: "arrow.2.circlepath")
                }
            }
        }
    }
}

struct AdditionList_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView{
            AdditionList(apiManager: ApiManager()).environmentObject(AdditionData.example())
        }
    }
}
