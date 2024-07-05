//
//  LaunchingView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 19/6/2024.
//

import SwiftUI

struct LaunchingView: View {
    @EnvironmentObject var store : BusStore
    var body: some View {
        NavigationStack{
            NavigationView {
                VStack {
                    ProgressView(label: {
                        Text(store.isRouteStopDataCompleted ? "Done" : "Loading BusStop data.......")
                    }).progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(1.5, anchor: .center)
                }
            }.navigationDestination(isPresented: $store.isStopDataCompleted){
                LoadRouteView()}
            .navigationBarBackButtonHidden(true)
            .onAppear(perform: {
                store.setupStopView()
            })
        }
    }
}

struct LoadRouteView: View {
    @EnvironmentObject var store : BusStore
    var body: some View {
        VStack {
            ProgressView(label: {
                Text(store.isRouteDataCompleted ? "Done" : "Loading Route data.......")
            }).progressViewStyle(CircularProgressViewStyle(tint: .blue))
            .scaleEffect(1.5, anchor: .center)
        }.task {
            store.setupRouteView()
        }
        .navigationDestination(isPresented: $store.isRouteDataCompleted){
            LoadRouteStopView()
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct LoadRouteStopView: View {
    @EnvironmentObject var store : BusStore
    var body: some View {
        VStack {
            ProgressView(label: {
                Text(store.isRouteStopDataCompleted ? "Done" : "Loading RouteStop data.......")
            }).progressViewStyle(CircularProgressViewStyle(tint: .blue))
            .scaleEffect(1.5, anchor: .center)
        }.task {
            store.setupRouteStopView()
        }
        .navigationDestination(isPresented: $store.isRouteStopDataCompleted){
            HomeView()
        }
        .navigationBarBackButtonHidden(true)
    }
}

//#Preview {
//    LaunchingView()
//}
