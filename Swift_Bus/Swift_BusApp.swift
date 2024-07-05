//
//  Swift_BusApp.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 3/5/2024.
//
import SwiftUI
import GoogleMaps

@main
struct Swift_BusApp: App {
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            @ObservedObject var busStore = BusStore()
            @ObservedObject var toDoStore = TodosStore()
            let locManager = LocationManager()
            LaunchingView().environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(locManager)
                .environmentObject(busStore)
                .environmentObject(toDoStore)
              //  .environment(\.locale, .init(identifier: lang))
        }
    }
}
