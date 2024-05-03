//
//  HomeView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 22/5/2024.
//

import Foundation
import SwiftUI
import _MapKit_SwiftUI

struct HomeView: View {
//    @Environment(\.managedObjectContext) private var viewContext
    //@StateObject var toDoStore = TodosStore()
//    @StateObject var store = Store(state: AppState())
    @EnvironmentObject var store : BusStore
    @EnvironmentObject var toDoStore : TodosStore
    @EnvironmentObject var locManager : LocationManager
    @Environment(\.managedObjectContext) private var viewContext
    
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Stop.stop, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Stop>
        
    
    var body: some View {
        //NavigationView {
            
            VStack {
                NavigationLink {
                    BusRouteView()
                } label: {
                    Text("Bus Route")
                }
                
                NavigationLink {
                    BusStopView()
                } label: {
                    Text("Bus Stop")
                }
                
                NavigationLink {
                    BusRouteStopView(route: "1A", selectedRouteStr: "1A 尖沙咀碼頭 -> 中秀戊坪", direction: "O", service_type: "1")
                } label: {
                    Text("Bus Route Stop")
                }
                NavigationLink {
                    BusStopEtaView(stopName: "九龍灣", stopCode: ["8C09B3648DCDAF3C"])
                } label: {
                    Text("Bus Stop ETA")
                }
                NavigationLink {
                 
                    BusEtaDetailView(stopName: "九龍灣", stopCode: "8C09B3648DCDAF3C", route: "17", service_type: "1")
                } label: {
                    Text("Bus ETA Detail")
                }
                NavigationLink {
                 
                    BusRouteDetailView()
                } label: {
                    Text("Bus Route Detail")
                }
                NavigationLink {
                    TodosView()
                } label: {
                    Text("Bus Plan")
                }
                Text("Location: (\(locManager.location.lat),\(locManager.location.long))")
//                Map(coordinateRegion: $manager.region, showsUserLocation: true)
//                            .edgesIgnoringSafeArea(.all)
            }
            .task {
                store.setupDetail()
                //store.setupRouteView()
                //store.setupRouteStopView()
                
                
            }.navigationBarBackButtonHidden(true)
            //.onDelete(perform: deleteItems)
            
            
            // Button("Bus Stops", action: {BusStopView()})
            //Button("Bus Routes", action: {BusRouteView()})
        //.environmentObject(toDoStore)
        //    .environmentObject(store)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                EditButton()
            }
            ToolbarItem {
                Button(action: addItem) {
                    Label("Add Item", systemImage: "plus")
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
