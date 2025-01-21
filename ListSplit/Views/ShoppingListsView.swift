import SwiftUI

struct ListsView: View {
    @State private var lists: [ShoppingList] = []
    @State private var newList = ShoppingList()
    
    @State private var itemToDelete: ShoppingList? = nil  // Track the item to delete
    @State private var showingDeleteConfirmation = false  // Show delete confirmation alert
    
    @State private var errorMessage : String? = nil
    
    @EnvironmentObject var loggedInUser: LoggedUser
    
    var body: some View {
        NavigationStack {
            
            List {
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                }
                else {
                    ForEach(lists.indices, id: \.self) { idx in
                        HStack {
                            NavigationLink(destination: ShoppingListView(shoppingList: self.$lists[idx])) {
                                VStack(alignment: .leading) {
                                    Text(lists[idx].name)
                                        .font(.headline)
                                    
                                    Text(lists[idx].description.isEmpty ? "No description" : lists[idx].description)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                }
                                //                        .padding()
                                //                        .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)  // Full width
                            }

                        }
                        .swipeActions(edge: .trailing) {
                            
                            // Trash button with confirmation
                            Button(role: .destructive, action: {
                                // Set the item to delete and show the confirmation alert
                                itemToDelete = lists[idx]
                                showingDeleteConfirmation = true
                            }) {
                                Image(systemName: "trash.fill")
                            }
                            .tint(.red)
                            
                            
                            NavigationLink(destination: ShoppingListProperties(shoppingList: $lists[idx])) {
     
                                Image(systemName: "gearshape.fill")
                                

                            }
                            .tint(.orange)
                            
                        }
                        
                    }
                }

            }
            .onAppear(perform: fetchLists)
            .refreshable(action: {
                fetchLists()
            })
            .listStyle(PlainListStyle())  // Remove default List styling that may add extra spacing
            .navigationTitle("\(loggedInUser.name)'s Lists")
            
            .toolbar {
                NavigationLink(destination: ShoppingListProperties(isAddingNew: true, shoppingList: $newList)) {
                        Image(systemName: "plus")

                                            
                }
            }
            .alert("Confirm Delete", isPresented: $showingDeleteConfirmation, presenting: itemToDelete) { item in
                Button("Delete", role: .destructive) {
                    deleteItem(item)
                }
                Button("Cancel", role: .cancel) {}
            } message: { item in
                Text("Are you sure you want to delete this item?")
            }

        }
    }
    
    private func fetchLists() {
        
        APIController.shared.performRequest(
            endpoint: "shopping_lists/all",
            method: "GET"
        ) {   (response: APIResponse<[ShoppingList]>) in
            DispatchQueue.main.async {
                switch response {
                case .success(let fetchedLists):
                    lists.removeAll()
                    lists.append(contentsOf: fetchedLists.data)
                    print("sucessfully fetched shopping lists")
                    
                    
                case .failure(_):
                    errorMessage = "Failed to query API"
                }
            }
        }
    }
    
    private func deleteItem(_ item: ShoppingList) {
        if let id = item.id {
            APIController.shared.performMessageRequest(
                endpoint: "shopping_list/\(id)",
                method: "DELETE"
            ) {   result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            if let index = lists.firstIndex(where: { $0.id == item.id }) {
                                lists.remove(at: index)
                            }
                        }
                        
                        
                    case .failure(_):
                        print("delete failed, unfortunately we don't handle this")
                    }
                }
            }
        }


        
        

    }
}

struct ListItem: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

struct ListsView_Previews: PreviewProvider {
    static let loggedInUser = LoggedUser()
    
    static var previews: some View {
        ListsView()
            .environmentObject(loggedInUser)
    }
}
