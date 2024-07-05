//
//  BusStopETAView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 5/6/2024.
//
import Foundation
import SwiftUI
import Combine

struct BusStopEtaView: View {
    @EnvironmentObject var store : BusStore
    @Environment(\.scenePhase) var scenePhase
    let stopName: String
    let stopCode: [String]
    let timer1 = Timer.publish(every: 10, tolerance: 0.5, on: .main, in: .common).autoconnect()
    //let initial = Just(Date.init())
    @ObservedObject var busStopEtaVM = BusStopEtaViewModel()
    
    var body: some View {
        List(busStopEtaVM.listOfResult.sorted{$0.route < $1.route}){listItem in
            Text(listItem.toDetail())
        }
        //        .task( {
        //            busStopEtaVM.getStopAPIs(listOfStopInput: stopCode)
        //        })
        .navigationTitle(stopName)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear(perform: {
            busStopEtaVM.getStopAPIs(listOfStopInput: stopCode)
        })
        .onReceive(timer1, perform: { _ in
            if scenePhase == .active{
                busStopEtaVM.getStopAPIs(listOfStopInput: stopCode)
            }
        })
        
    }
    
}
    
class BusStopEtaViewModel : ObservableObject{
    var subscription = [AnyCancellable]()
    private var listOfPublisher = [AnyPublisher<BusStopEtaData, Error>]()
    @Published private (set) var stopEta: [StopEtaData] = []
    @Published var listOfResult : [StopEtaData] = []

    init(){}
    
    func getStopAPIs(listOfStopInput: [String] ){
        listOfPublisher = []
        for i in 0...(listOfStopInput.count - 1) {
            listOfPublisher.append(BusAPI.getStopEtaData(listOfStopInput[i]))
        }
        Publishers.MergeMany(listOfPublisher).collect()
            .replaceError(with: [])
            .print("Debug Many Publisher")
            .sink{ value in
                let result = value.flatMap{$0.data}
                self.listOfResult = result.compactMap{$0}
            }.store(in: &subscription)
    }
}

//#Preview {
//    BusRouteStopView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
//

