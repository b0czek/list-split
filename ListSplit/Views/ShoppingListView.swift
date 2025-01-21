import SwiftUI

struct ShoppingListView: View {
    
    @State private var items: [ShoppingItem] = [
        ShoppingItem(name:"Banana")
    ]
    @Binding var shoppingList: ShoppingList
    
    @State private var searchText = ""
    @State private var showAddItem = false
    @State private var newItemName = ""
    
    @State private var showItemView = false
    
    @State private var selectedItem: ShoppingItem = ShoppingItem(name: "unavailable")
    
    @State private var selectedTab = 0
    
    @State private var summaries: [BillSummary] = []
    @State private var bills: [Bill] = []
    
    @State private var showAddBillSheet: Bool = false
    @State private var addBillName: String = ""
    @State private var addBillAmount: String = ""
    @State private var addBillDate: Date = Date()
    @State private var addBillRemoveSelected : Bool = false
    
    
    private var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        return dateFormatter
    }
    

    private var anyChecked: Bool {
        items.contains(where: { $0.isChecked })
    }
    
    
    
    // Filter items based on search text
    var filteredItems: [ShoppingItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
    }
    
    var body: some View {
        
        TabView(selection: $selectedTab) {
            
            Tab("List", systemImage: "basket", value: 0)  {
                VStack {
                    
                    
                    // List of items with checkmarks
                    List {
                        ForEach(filteredItems) { item in
                            HStack {
                                Image(systemName: item.isChecked ? "checkmark.circle.fill" : "circle")
                                    .foregroundColor(item.isChecked ? .blue : .gray)
                                    .onTapGesture {
                                        if let index = items.firstIndex(where: { $0.uuid == item.uuid }) {
                                            items[index].isChecked.toggle()
                                        }
                                    }
                                    .padding(.vertical, 10)
                                VStack {
                                    Text(item.name)
                                    if !item.description.isEmpty {
                                        Text(item.description)
                                            .font(.subheadline)
                                            .foregroundColor(.gray)
                                    }
                                    
                                }
                                .onTapGesture {
                                    // Show item detail view when item is tapped
                                    selectedItem = item
                                    showItemView.toggle()
                                }
                                
                            }
                        }
                        
                        Button(action: {
                            showAddItem.toggle()
                        } ){
                            HStack {
                                Image(systemName: "plus")
                                Text("Add Item")
                            }
                            .foregroundStyle(Color.blue)
                            .frame(maxWidth: .infinity)
                            
                        }
                    }
                    .listStyle(GroupedListStyle())
                    
                    .refreshable(action: {
                        fetchItems()
                    })
                    
                    
                    
                    
                }
                
                .alert("Add an Item to the List", isPresented: $showAddItem) {
                    TextField("Item name", text: $newItemName)
                        .textInputAutocapitalization(.never)
                    HStack {
                        Button("Cancel" ) {
                            newItemName = ""
                        }
                        Button("Add") {
                            if newItemName != "" {
                                addItem(name: newItemName)
                                
                                newItemName = ""
                            }
                            
                        }
                    }
                }
                .sheet(isPresented: $showItemView) {
                    
                    NavigationStack {
                        Form {
                            Section(header: Text("Item Details")) {
                                // Editable Name field
                                TextField("Name", text: $selectedItem.name)
                                
                                // Editable Description field
                                TextField("Description", text: $selectedItem.description)
                            }
                            
                            Section {
                                Button("Save") {
                                    
                                    updateItem(item: &selectedItem)
                                    
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
            
            Tab("Expenses", systemImage: "banknote", value: 1) {
                VStack(alignment: .leading) {
                    
                    Section(header: Text("SUMMARY")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal))
                    {
                        List {
                            ForEach(summaries) { data in
                                VStack {
                                    HStack {
                                        Text(data.user)
                                            .font(.body)
                                        Spacer()
                                        Text(String(format: "$%.2f", data.amount))
                                            .font(.body)
                                    }
                                    
                                    ProgressView(value: data.amount, total: summaries.map(\.amount).reduce(0, +))
                                        .accentColor(.blue)
                                }
                                
                                .padding(.vertical, 8)
                            }
                        }
                        .listStyle(PlainListStyle())
                        .padding(.bottom, 8)
                    }
                    
                    
                    Section(header: Text("PREVIOUS")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.horizontal))
                    {
                        
                        
                        Button(action: {
                            showAddBillSheet.toggle()
                        } ){
                            HStack {
                                Image(systemName: "plus")
                                Text("Add a Bill")
                            }
                            .foregroundStyle(Color.blue)
                            .frame(maxWidth: .infinity)
                        }
                        
                        List {
                            
                            
                            
                            ForEach(bills) { bill in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(bill.name)
                                            .font(.body)
                                        Text("by \(bill.userName!) on \(dateFormatter.string(from: bill.date))")
                                            .font(.caption)
                                            .foregroundColor(.gray)
                                    }
                                    Spacer()
                                    Text(String(format: "$%.2f", bill.amount))
                                        .font(.body)
                                }
                                //.padding(.vertical, 4)
                            }
                        }
                        .listStyle(PlainListStyle())
                        
                        

                        
                    }
                }
                
                .refreshable(action: {
                    fetchBills()
                    fetchSummary()
                })
                
                
                
                
                
                
                
            }
            
        }
        
        
        .navigationTitle(shoppingList.name)
        
        
        .onAppear() {
            fetchItems()
            fetchBills()
            fetchSummary()
        }
        
        .sheet(isPresented: $showAddBillSheet) {
            
            NavigationStack {
                Form {
                    Section(header: Text("BILL DETAILS")) {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Name", text: $addBillName)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                        }
                        
                        HStack {
                            Text("Date")
                            Spacer()
                            DatePicker("", selection: $addBillDate, displayedComponents: .date)
                                .labelsHidden()
                        }
                        
                        HStack {
                            Text("Amount")
                            Spacer()
                            TextField("Amount", text: $addBillAmount)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.leading)
                                .padding(.horizontal)
                            
                            Text(shoppingList.currency)
                        }

                    }
                    
                    Section {
                        Button("Add") {

                            addBill(shouldDeleteItems: addBillRemoveSelected)

                            showAddBillSheet = false
                            addBillRemoveSelected = false
                            addBillName = ""
                            addBillAmount = ""
                            addBillDate = Date()
                        }
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.blue)
                    }
                }
                .navigationBarTitle("Add a Bill", displayMode: .inline)
                .navigationBarItems(leading: Button("Cancel") {
                    showAddBillSheet = false
                    addBillName = ""
                    addBillAmount = ""
                    addBillDate = Date()
                    addBillRemoveSelected = false
                })
            }
            
        }
        
        .toolbar() {
            if selectedTab == 0 {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            // Handle select all action
                            for index in items.indices {
                                items[index].isChecked = true
                            }
                        }) {
                            Label("Select All", systemImage: "checkmark.circle.fill")
                        }
                        
                        
                        if anyChecked  {
                            Button(action: {
                                // Handle clear all action
                                for index in items.indices {
                                    items[index].isChecked = false
                                }
                            }) {
                                Label("Clear All", systemImage: "circle")
                            }
                            Button(action: {
                                // Handle delete checked action
                                deleteItems(deletedItems: items.filter {$0.isChecked})
                            }) {
                                Label("Delete Checked", systemImage: "trash")
                            }
                            
                            
                            Button(action: {
                                addBillRemoveSelected = true
                                showAddBillSheet = true
                            }) {
                                Label("Add bill and delete", systemImage: "basket")
                            }
                        }
                        
                        
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.blue)
                    }
                }
            }

        }
        
    }
    
    
    func fetchItems() {
        if let id = shoppingList.id {
            APIController.shared.performRequest(
                endpoint: "items/\(id)",
                method: "GET"
            ) {   (response: APIResponse<[ShoppingItem]>) in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let fetchItems):
                        items.removeAll()
                        items.append(contentsOf: fetchItems.data)
                        print("sucessfully fetched shopping items")
                        
                        
                    case .failure(_):
                        print("unhandled, too bad")
                    }
                }
            }
        }
        
    }
    
    
    func addItem(name : String) {
        var newItem = ShoppingItem(name: name)
        if let id = shoppingList.id {
            newItem.shoppingListId = id
            guard let body = try? JSONEncoder().encode(newItem) else { return }
            
            
            APIController.shared.performMessageRequest(
                endpoint: "item",
                method: "POST",
                body: body
            ) {   result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.statusCode == 201 {
                            fetchItems()
                        }
                        
                        
                    case .failure(_):
                        print("failed, too bad")
                    }
                }
            }
        }
        
        
        
        
    }
    
    func updateItem(item: inout ShoppingItem) {
        
        if let itemId = item.id {
            guard let body = try? JSONEncoder().encode(["name": item.name, "description": item.description]) else { return }
            
            APIController.shared.performMessageRequest(
                endpoint: "item/\(itemId)",
                method: "PUT",
                body: body
            ) {   result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let res):
                        if res.statusCode == 200 {
                            fetchItems()
                        }
                        
                        
                    case .failure(_):
                        print("failed, too bad")
                    }
                }
            }
            
        }
        
        
    }
    
    // Delete items from the list
    func deleteItems(deletedItems: [ShoppingItem]) {
        var success = true
        for item in deletedItems {
            
            if let itemId = item.id {
                
                APIController.shared.performMessageRequest(
                    endpoint: "item/\(itemId)",
                    method: "DELETE"
                ) {   result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let res):
                            if res.statusCode == 200 {
                                
                            }
                            else {
                                success = false
                            }
                            
                        case .failure(_):
                            print("failed, too bad")
                        }
                    }
                }
                
            }
        }
        if success {
            items.removeAll { $0.isChecked }
        }
        else {
            fetchItems()
        }
    }
    
    func fetchSummary() {
        if let id = shoppingList.id {
            APIController.shared.performRequest(
                endpoint: "bill/summary/\(id)",
                method: "GET"
            ) {   (response: APIResponse<[BillSummary]>) in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let billSummaries):
                        
                        summaries.removeAll()
                        summaries.append(contentsOf: billSummaries.data.sorted { $0.percent > $1.percent })
                        print("sucessfully fetched bill summaries")
                        
                        
                    case .failure(_):
                        print("unhandled, too bad")
                    }
                }
            }
        }
    }
    
    func fetchBills() {
        if let id = shoppingList.id {
            APIController.shared.performRequest(
                endpoint: "bills/\(id)",
                method: "GET"
            ) {   (response: APIResponse<[Bill]>) in
                DispatchQueue.main.async {
                    switch response {
                    case .success(let fetchedBills):
                        bills.removeAll()
                        bills.append(contentsOf: fetchedBills.data.sorted(by:{ $0.date > $1.date } ))
                        print("sucessfully fetched bills")
                        
                        
                    case .failure(let reason):
                        print("unhandled, too bad \(reason)")
                    }
                }
            }
        }
    }
    
    func addBill(shouldDeleteItems: Bool = false) {
        
               
        var bill: Bill = Bill(name: addBillName, date: addBillDate, amount : Float(addBillAmount.replacingOccurrences(of: ",", with: ".")) ?? 0)
        if let id = shoppingList.id {
            bill.shoppingListId = id


            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .custom { date, encoder in
                var container = encoder.singleValueContainer()
                
                let formatter = ISO8601DateFormatter()
                formatter.formatOptions = [.withInternetDateTime] 
                
                // Convert "Z" to "+00:00" for Python compatibility
                let dateString = formatter.string(from: date).replacingOccurrences(of: "Z", with: "+00:00")
                
                try container.encode(dateString)
            }

            guard let body = try? encoder.encode(bill) else { return }

            print(String(data:body, encoding: .utf8)!)
            
            APIController.shared.performMessageRequest(
                endpoint: "bill",
                method: "POST",
                body: body
            ) {   result in
                    DispatchQueue.main.async {
                        switch result {
                        case .success(let res):
                            if res.statusCode == 201 {
                                if(shouldDeleteItems) {
                                    deleteItems(deletedItems: items.filter {$0.isChecked})

                                }
                                fetchBills()
                                fetchSummary()
                            }
                            
                            
                        case .failure(_):
                            print("failed, too bad")
                        }
                    }
                }
                
        }
    }
    
    
}



struct ShoppingListView_Previews: PreviewProvider {
    static var previews: some View {
        @State var shoppingList = ShoppingList(name: "Shopping List")
        
        NavigationStack() {
            ShoppingListView(shoppingList: $shoppingList)
        }
        
    }
}
