import SwiftUI
import SwiftData

struct RepositoryDemoView: View {
    let modelContainer: ModelContainer
    @StateObject private var vm = DemoViewModel()
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

extension RepositoryDemoView {
    @MainActor
    final class DemoViewModel: ObservableObject {
        @Published private(set) var items: [Item] = []

        private var repository: ItemRepository?

        init() {
            // Placeholder repository until configured via `configure(container:itemsURL:)`
        }

        func configure(container: ModelContainer, itemsURL: String) {
            let local = SwiftDataLocalStore(container: container)
            self.repository = ItemRepository(local: local, network: NetworkClient(), itemsURL: itemsURL)
        }
        
        func load() async {
            guard let repository else { return }
            do {
                items = try await repository.getItems(nil)
            } catch {
                print("Failed to load items: \(error)")
            }
        }

        @MainActor
        func addItem(id: String, title: String, url: String, thumbnailUrl: String, albumId: Int) {
            guard let repository = repository else { return }
            let newItem = Item(id: -1, title: title, url: url, thumbnailUrl: thumbnailUrl, albumId: albumId)
            Task {
                do {
                    if let local = (repository as? ItemRepository)?.local as? SwiftDataLocalStore {
                        try await local.saveItems([newItem])
                        await load()
                    }
                } catch {
                    print("Failed to add item: \(error)")
                }
            }
        }
    }
}
