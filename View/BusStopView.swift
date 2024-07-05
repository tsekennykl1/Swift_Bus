//
//  BusStopView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 3/5/2024.
//

import Foundation
import SwiftUI
import Combine
import OrderedCollections

struct SubBusStopView : View {
    let displayStopList : [StopData]
    var body: some View {
        HStack{
            NavigationLink {
                BusStopEtaView(stopName: displayStopList.first!.stopName , stopCode: displayStopList.map{$0.stop})
            } label: {
                Text(displayStopList.first!.toStr())
            }
        }
    }
}

struct BusStopView: View {
    @AppStorage("selectedLanguage") private var language = LocalizationManager.shared.language
    @ObservedObject var stopViewModel = StopViewModel()
    @EnvironmentObject var store : BusStore
    @EnvironmentObject var locManager : LocationManager
//   @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Stop.stop, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Stop>
    
    var body: some View {
        let displayStopTuples = stopViewModel.getStopListByName(stopDict: store.busStopDictByCode, locManager: locManager)
        VStack{
            HStack {
                TextField("Enter Search Text".localized(language), text: $stopViewModel.searchText)
                    .padding(.horizontal, 40)
                    .frame(width: UIScreen.main.bounds.width - 30, height: 45, alignment: .leading)
                    .background(Color(#colorLiteral(red: 0.9, green: 0.9, blue: 0.9, alpha: 1)))
                    .clipped()
                    .cornerRadius(10)
                    .overlay(
                        HStack {
                            Image(systemName: "magnifyingglass")
                                .foregroundColor(.gray)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, 16)
                        })
                Spacer()
            }.padding()
            //Text("Current Location: (\(locManager.location.lat),\(locManager.location.long))")
            List{
                if(stopViewModel.searchText.count < 1){
                    ForEach(displayStopTuples, id:\.0){ item in
                        SubBusStopView(displayStopList: item.1)
                    }
                } else{
                    SubBusStopView(displayStopList: stopViewModel.searchedStop.sorted(by: {locManager.distDiff($0.lat,$0.long) < locManager.distDiff($1.lat,$1.long)}))
                }
            }
        }.background {
            GeometryReader { geometry in
                Color.clear.preference(
                    key: SizePreferenceKey.self,
                    value: geometry.size
                )
            }
        }.onAppear(perform: {
            stopViewModel.setStopVM(stopDict: store.busStopDictByCode)
        }).navigationTitle("All Bus Stops")
            .navigationBarTitleDisplayMode(.inline)
    }
}

class StopViewModel: ObservableObject {
    var subscription: Set<AnyCancellable> = []
    var stopDict = Dictionary<String, StopData>()
    @Published private (set) var searchedStop: [StopData] = []
    @Published var searchText: String = String()
//    var lat : Double
//    var long : Double
    @Published var displayStopList : [StopData] = []
    
    init() {
        $searchText
            .debounce(for: .milliseconds(1000), scheduler: RunLoop.main) // debounces the string publisher, such that it delays the process of sending request to remote server.
            .removeDuplicates()
            .map({ (string) -> String? in
                if string.count < 1 {
                    self.searchedStop = self.stopDict.values.sorted(by: {$0.id < $1.id})
                    return nil
                }
                return string
            }) // prevents sending numerous requests and sends nil if the count of the characters is less than 1.
            .compactMap{ $0} // removes the nil values so the search string does not get passed down to the publisher chain
            .sink { (_) in
            } receiveValue: { [self] (searchField : String) in
                self.searchedStop = stopDict.filter({
                    $0.value.name_tc.contains(searchField) ||
                    $0.value.name_sc.contains(searchField) ||
                    $0.value.name_en.contains(searchField.uppercased())
                }).map{$0.value}
                self.searchedStop.sort(by: {$0.id < $1.id})
            }.store(in: &subscription)
    }
    
    func setStopVM(stopDict: Dictionary<String, StopData>){
        self.stopDict = stopDict
    }
    
    func getStopListByName(stopDict: Dictionary<String,StopData>, locManager: LocationManager)-> [(String,[StopData])]{
        let keysAndValues = stopDict.values.sorted(by: {locManager.distDiff($0.lat, $0.long) < locManager.distDiff($1.lat, $1.long)}).map{ ($0.stopName, [$0])}  //Further check
        let newDict = OrderedDictionary<String, [StopData]>(keysAndValues, uniquingKeysWith: { $0 + $1 })
        var returnTuple = [(String,[StopData])]()
        newDict.forEach{ key, value in
            returnTuple.append((key,value))
        }
        return returnTuple
    }
}

//#Preview {
//    BusStopView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
