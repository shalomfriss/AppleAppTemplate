import SwiftUI
import SwiftData

struct RepositoryDemoView: View {
    let modelContainer: ModelContainer
    @StateObject private var vm = RepositoryDemoViewModel()
    
    @State private var showAddItemSheet = false
    @State private var newItemTitle = ""
    @State private var newItemDetails = ""

    var body: some View {
        NavigationStack {
            List(vm.items, id: \.id) { item in
                SimpeRow(title: item.title, description: item.url)
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showAddItemSheet = true
                    }) {
                        Image(systemName: "plus")		
                    }
                }
            }
            .sheet(isPresented: $showAddItemSheet) {
                VStack(spacing: 20) {
                    TextField("Title", text: $newItemTitle)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    TextField("Details", text: $newItemDetails)
                        .textFieldStyle(.roundedBorder)
                        .padding(.horizontal)
                    HStack {
                        Button("Cancel") {
                            showAddItemSheet = false
                            newItemTitle = ""
                            newItemDetails = ""
                        }
                        Spacer()
                        Button("Add") {
//                            let detailsValue = newItemDetails.isEmpty ? nil : newItemDetails
//                            vm.addItem(title: newItemTitle, url: item.url, albumId: <#Int#>)
//                            showAddItemSheet = false
//                            newItemTitle = ""
//                            newItemDetails = ""
                        }
                        .disabled(newItemTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                    .padding(.horizontal)
                }
                .padding()
            }
            .task {
                await vm.load()
            }
        }
        .task {
            vm.configure(container: modelContainer, itemsURL: UrlEndpoints.itemsURL.rawValue)
        }
    }
}

