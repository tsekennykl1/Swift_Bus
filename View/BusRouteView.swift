//
//  BusRouteView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 22/5/2024.
//

import Foundation
import SwiftUI
import Combine

struct BusRouteView: View {
    @EnvironmentObject var store : BusStore
    @ObservedObject var routeViewModel: RouteViewModel = RouteViewModel()
//    @Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \Route.route, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<Route>
    var body: some View {
        let displayRouteList = store.busRouteDict.values.sorted(by: {$0.id < $1.id})
        VStack{
            HStack {
                TextField("Enter Search Text", text: $routeViewModel.searchText)
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
                        }
                    )
                Spacer()
            }.padding()
            List{
                if (routeViewModel.searchText.count < 1){
                    ForEach(displayRouteList, id: \.id) {  item in
                        NavigationLink {
                            BusRouteStopView(route: item.route, selectedRouteStr: item.toStr(), direction: item.bound, service_type: item.service_type)
                        } label: {
                            Text(item.toStr())
                        }
                    }
                }
                else{
                    ForEach(routeViewModel.searchedRoute, id: \.id) {  item in
                        NavigationLink {
                            BusRouteStopView(route: item.route, selectedRouteStr: item.toStr(), direction: item.bound, service_type: item.service_type)
                        } label: {
                            Text(item.toStr())
                        }
                    }
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
            routeViewModel.setRouteDict(routeDict: store.busRouteDict)
        }).navigationTitle("All Bus Routes")
            .navigationBarTitleDisplayMode(.inline)
    }
}

class RouteViewModel: ObservableObject {
    
    var subscription: Set<AnyCancellable> = []
    var routeDict = Dictionary<String, RouteData>()
    @Published private (set) var searchedRoute: [RouteData] = []
    @Published var searchText: String = String()
    private let queue = DispatchQueue(label: "SearchFetch", qos: .userInitiated)
    init() {
//        queue.async {
            self.$searchText
                .debounce(for: 1,scheduler: RunLoop.main) // debounces the string publisher, such that it delays the process of sending request to remote server.
                .removeDuplicates()
                .map({ (string) -> String? in
                    if string.count < 1 {
                        self.searchedRoute = self.routeDict.values.sorted(by: {$0.route < $1.route})
                        return nil
                    }
                    return string
                }) // prevents sending numerous requests and sends nil if the count of the characters is less than 1.
                .compactMap{ $0} // removes the nil values so the search string does not get passed down to the publisher chain
                .sink { (_) in
                    //
                } receiveValue: { [self] (searchField : String) in
                    //searchItems(searchText: searchField)
                    self.searchedRoute = routeDict.filter({
                        $0.value.route.contains(searchField.uppercased()) ||
                        $0.value.dest_tc.contains(searchField) || $0.value.dest_en.contains(searchField.uppercased()) ||
                        $0.value.orig_tc.contains(searchField) ||  $0.value.orig_en.contains(searchField.uppercased())
                    }).map{$0.value}
                    self.searchedRoute.sort(by: {$0.route<$1.route})
                }.store(in: &self.subscription)
//        }
    }
    func setRouteDict(routeDict: Dictionary<String, RouteData>){
        self.routeDict = routeDict
    }
}

//#Preview {
//    BusRouteView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

