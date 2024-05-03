//
//  Swift_BusApp.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 3/5/2024.
//

import SwiftUI

@main
struct Swift_BusApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            // Initialise the Store
            
           // let busStore = BusStore()
           // let toDoStore = TodosStore()
            
            LaunchingView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            
            // Load from DB or Trigger Stop API and store in the DB
            //let busStopViewModel = BusStopViewModel(controller: FetchController())
            
            // Load from DB or Trigger Route API and store in the DB
            //let busStopViewModel = BusStopViewModel(controller: FetchController())
            
            // Set the BusStopName List and the RouteList onto the Store's published Var
            
            // set the Store object into HomeView's Env Obj
            
            //let _ = BusStopViewModel()
            //let busRouteDataModel = BusRouteViewModel()
            //BusStopView()//.environment(busStopViewModel)
            //BusStopView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            //BusRouteView().environment(\.managedObjectContext, persistenceController.container.viewContext)
            //
            
            //HomeView().environment(\.managedObjectContext, persistenceController.container.viewContext)
           // LaunchingView().environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
