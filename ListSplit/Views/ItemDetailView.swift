import SwiftUI

// Item detail view where you can edit the name and description
struct ItemDetailView: View {
    @Binding var item: ShoppingItem   // Binding to the selected item
    @Binding var showItemView: Bool   // Binding to control visibility of the detail view
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Item Details")) {
                    // Editable Name field
                    TextField("Name", text: $item.name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    
                    // Editable Description field
                    TextField("Description", text: $item.description)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                
                Section {
                    Button("Save") {
                        // Save button: just dismiss the view because the changes are automatically applied via Binding
                        showItemView = false
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationBarTitle("Item Details", displayMode: .inline)
            .navigationBarItems(leading: Button("Cancel") {
                // Cancel button: dismiss without saving changes
                showItemView = false
            })
        }
    }
}

