//
//  File.swift
//  Bus_ride_swift
//
//  Created by Kwok Leung Tse on 12/4/2024.
//

import Foundation

typealias Dispatcher = (Action) -> Void
typealias Reducer<State: ReduxState> = (_ state: State, _ action: Action) -> State
typealias Middleware<StoreState: ReduxState> = (StoreState, Action, @escaping Dispatcher) -> Void

protocol ReduxState {}

struct AppState: ReduxState{
    
    //var busStops = BusStopState()
    var busStops = "1A"
}


struct BusStopState: ReduxState {
   // var busStops = [StopData]()
    var busStops = "2"
}
protocol Action {}


struct SetBusStops : Action{
    let busStops : [StopData]
}

struct AddAction : Action{
    let value: Int
    
}
struct FetchAllBusStop : Action{
    //let search : String
}

class Store<StoreState: ReduxState>: ObservableObject{
    
    @Published var state: StoreState
    
    init(state: StoreState) {
        self.state = state
    }
    
}
