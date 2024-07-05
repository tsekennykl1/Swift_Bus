//
//  HomeView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 22/5/2024.
//

import Foundation
import SwiftUI
import _MapKit_SwiftUI
import GoogleMaps

struct HomeView: View {
//    @Environment(\.managedObjectContext) private var viewContext
    //@StateObject var toDoStore = TodosStore()
//    @StateObject var store = Store(state: AppState())
    @AppStorage("selectedLanguage") private var language = LocalizationManager.shared.language
    @State(initialValue: "en") var lang: String
    @EnvironmentObject var store : BusStore
    @EnvironmentObject var toDoStore : TodosStore
    @EnvironmentObject var locManager : LocationManager
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Stop.stop, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Stop>
    @State private var contentSize: CGSize = .zero
    
    var body: some View {
        //NavigationView {
        
        VStack {
            // Text("Location: (\(locManager.location.lat),\(locManager.location.long))".localized(language))
            // Text("Your current location is".localized(language))
            
            TabView{
                
                //  ZStack{
                BusRouteView().tabItem {
                    NavigationLink(destination: BusRouteView()){
                        //                    TodosView().tabItem {
                        //                        NavigationLink(destination: TodosView()){
                        Image(systemName: "bus.doubledecker")
                        Text("Bus Route".localized(language))
                    }.tag(1)
                }.getSizeOfView { contentSize = $0 }
                    .padding(.horizontal)
                BusStopView().tabItem {
                    NavigationLink(destination: BusStopView()){
                        //                    TodosView().tabItem {
                        //                        NavigationLink(destination: TodosView()){
                        Image(systemName: "figure.wave")
                        Text("Bus Stop".localized(language))
                    }.tag(2)
                }.getSizeOfView { contentSize = $0 }
                    .padding(.horizontal)
                BusRouteDetailView().tabItem {
                    NavigationLink(destination: BusRouteDetailView()){
                        //                    TodosView().tabItem {
                        //                        NavigationLink(destination: TodosView()){
                        Image(systemName: "info.windshield")
                        Text("Bus Route Detail".localized(language))
                    }.tag(3)
                }.getSizeOfView { contentSize = $0 }
                    .padding(.horizontal)
                //  }
            }
            //.frame(minHeight: 80, idealHeight: contentSize.height)
            //    .tabViewStyle(.page(indexDisplayMode: .never))
        }.task {
                store.setupDetail()
        }.navigationBarBackButtonHidden(true)
            //.onDelete(perform: deleteItems)
            .environment(\.locale, .init(identifier: lang))
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                //EditButton()
                if (LocalizationManager.shared.language == .english){
                    Button("Chi") {
                        LocalizationManager.shared.language = .t_chinese
                    }.foregroundColor(.blue)
                } else {
                    Button("Eng") {
                        LocalizationManager.shared.language = .english
                    }.foregroundColor(.blue)
                }
            }
            ToolbarItem {
                Button(action: addItem) {
                    //Label("Add Item", systemImage: "plus")
                    TodosView()
                }
            }
        }
    }
    
    private func addItem() {
        withAnimation {
            let newItem = Item(context: viewContext)
            newItem.timestamp = Date()

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

 /*   private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { items[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }*/
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

//#Preview {
//    HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
