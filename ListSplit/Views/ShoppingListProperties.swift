//
//  ShoppingListProperties.swift
//  ListSplit
//
//  Created by Dariusz Majnert on 15/01/2025.
//

import SwiftUI

struct ShoppingListProperties: View {
    var isAddingNew = false
    @Binding var shoppingList: ShoppingList
    @State private var sharedWith: [User] = []

    @State private var title: String = ""
    @State private var description: String = ""
    @State private var currency: String = ""
    
    @State private var errorMessage: String?
    
    @State private var showShareAlert: Bool = false
    @State private var shareWithEmail: String = ""
    
    @State private var showDeleteShareAlert: Bool = false
    @State private var deleteShareWithId = 0
    
    @State private var showErrorAlert: Bool = false
    @State private var errorAlertTitle: String = ""
    @State private var errorAlertMessage: String = ""
    
    //@State private var
    
    let defaultName = "My List"
    let defaultCurrency: String = "$"
    let defaultDescription: String = "Used to shop at ALDI's"
    
    @Environment(\.dismiss) private var dismiss

    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("LIST")) {
                    HStack {
                        Text("Title")
                        Spacer()
                        TextField(defaultName, text: $title)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Currency")
                        Spacer()
                        TextField(defaultCurrency, text: $currency)
                            .multilineTextAlignment(.trailing)
                    }
                    HStack {
                        Text("Description")
                        Spacer()
                        TextField(defaultDescription, text: $description)
                            .multilineTextAlignment(.trailing)
                        
                    }
                    
                    
                }
                
                
                if !isAddingNew {
                    Section(header: Text("SHARED WITH")) {
                        ForEach(sharedWith) { user in
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(user.name)
                                    Text(user.email).font(.subheadline).foregroundColor(.secondary)
                                }
                                Spacer()

                                
                                Button(action: {
                                    if let id = user.id {
                                     
                                        showDeleteShareAlert = true
                                        deleteShareWithId = id
                                    }
                                }) {
                                    Image(systemName: "minus.circle.fill")
                                        .foregroundColor(.red)
                                }
                                .frame(width: 44, height: 44)
                            }
                        }
                        
                        Button(action: {
                            showShareAlert = true
                        }) {
                            Text("Share")
                                .foregroundColor(.blue)
                        }
                    }
                }

                

                
            }
            
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
                    .padding(.top, 10)
            }
            Button(action: execButton) {
                Text(isAddingNew ? "Add List" : "Save")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .padding(.bottom)
            }
            
        }
        .navigationTitle(isAddingNew ? "Add New List" : "List Settings")
        
        
        
        
        .alert("Share the List", isPresented: $showShareAlert) {
            TextField("\("user@example.com")", text: $shareWithEmail)
                .textInputAutocapitalization(.never)

            HStack {
                Button("Cancel" ) {
                    shareWithEmail = ""
                }
                Button("Add") {
                    shareList(email: shareWithEmail)
                    shareWithEmail = ""
                }
            }
        } message: {
            Text("Enter the email of a Person that you wish to share the list with.")
        }
        
        
        .alert("Confirm Unshare", isPresented: $showDeleteShareAlert, presenting: deleteShareWithId) { item in
            Button("Unshare", role: .destructive) {
                unshareList(withId: item)
            }
            Button("Cancel", role: .cancel) {}
        } message: { item in
            Text("Are you sure you want to unshare the list with selected user?")
        }
        
        .alert(errorAlertTitle, isPresented: $showErrorAlert) {


            HStack {
                Button("Ok" ) {
                }
            }
        } message: {
            Text(errorAlertMessage)
        }
        
        
        .onAppear() {
            currency = shoppingList.currency
            title = shoppingList.name
            description = shoppingList.description
            
            fetchSharedWith()
        }
        
            
        
    }
    
    private func fetchSharedWith() {
        if let id = shoppingList.id  {
            APIController.shared.performRequest(
                endpoint: "list_share/\(id)",
                method: "GET"
            ) {   (response: APIResponse<[User]>) in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let fetchedLists):
                        sharedWith.removeAll()
                        sharedWith.append(contentsOf: fetchedLists.data)
                        
                        
                    case .failure(_):
                        errorMessage = "Failed to query API"
                    }
                }
            }
        }

    }
    
    private func shareList(email: String) {
        if let id = shoppingList.id  {
            let listShareCreate = ListShareCreate(email: email, shoppingListId: id)
            guard let body = try? JSONEncoder().encode(listShareCreate) else { return }
            
            
            
            APIController.shared.performMessageRequest(
                endpoint: "list_share",
                method: "POST",
                body: body
            ) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            fetchSharedWith()
                        }
                        else {
                            showErrorAlert = true
                            errorAlertTitle = "Error Sharing List"
                            errorAlertMessage = res.data.message
                        }
                    
                    case .failure(_):
                        showErrorAlert = true
                        errorAlertTitle = "Error Sharing List"
                        errorAlertMessage = "Failed to query API"
                    }
                }
            }
        }
    }
    
    private func unshareList(withId: Int) {
            if let sid = shoppingList.id{
            
            APIController.shared.performMessageRequest(
                endpoint: "list_share/\(sid)/\(withId)",
                method: "DELETE"
            ) { (result) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            fetchSharedWith()
                        }
                        else {
                            showErrorAlert = true
                            errorAlertTitle = "Error Removing User"
                            errorAlertMessage = res.data.message
                        }
                    
                    case .failure(_):
                        showErrorAlert = true
                        errorAlertTitle = "Error Removing User"
                        errorAlertMessage = "Failed to query API"
                    }
                }
            }
        }
        
    }
    
    private func execButton() {
        var listData = ShoppingList()
        listData.name = currency.isEmpty ? defaultName : title
        listData.currency = currency.isEmpty ? defaultCurrency : currency
        listData.description = description.isEmpty ? defaultDescription : description
        
        guard let body = try? JSONEncoder().encode(listData) else { return }
        errorMessage = ""
        
        var endpoint = "shopping_list"
        
        if !isAddingNew {
            if let id = shoppingList.id {
                endpoint += "/\(id)"
            }
            else {
                errorMessage = "Invalid shopping list selected"
            }
        }
        
        

        
        
        
        APIController.shared.performMessageRequest(
            endpoint: endpoint,
            method: isAddingNew ? "POST" : "PUT",
            body: body
        ) { (result) in
            DispatchQueue.main.async {
                switch result {
                case .success(let res):

                    if res.statusCode != 201 && isAddingNew || res.statusCode != 200 && !isAddingNew {
                        errorMessage = res.data.message
                        return
                    }
                    print("sucessfully saved/modified")

                    shoppingList.name = listData.name
                    shoppingList.currency = listData.currency
                    shoppingList.description = listData.description
                    
                    title = ""
                    currency = ""
                    description = ""
                    
                    dismiss()
                    
                    
                    
                    
                case .failure(_):
                    errorMessage = "Failed to query API"
                }
            }
        }
    }
}

struct ListSettingsView_Previews: PreviewProvider {

    static var previews: some View {
        @State var shoppingList = ShoppingList()
        
        NavigationStack {
            
            ShoppingListProperties(isAddingNew: false, shoppingList: $shoppingList)
        }
    }
}
