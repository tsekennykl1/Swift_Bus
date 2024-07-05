//
//  BusRouteStopView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 22/5/2024.
//

import Foundation
import SwiftUI
struct BusRouteStopView: View {
        
    @EnvironmentObject var store : BusStore
    let route : String
    let selectedRouteStr : String
    let direction : String
    let service_type : String
    
//    Environment(\.managedObjectContext) private var viewContext
//    @FetchRequest(
//        sortDescriptors: [NSSortDescriptor(keyPath: \RouteStop.route, ascending: true)],
//        animation: .default)
//    private var items: FetchedResults<RouteStop>
    
    @State var routeStopList: [RouteStopData] = []
    var body: some View {
        //        let key = "\(self.route)-\(self.direction)-\(self.service_type)"
        //        let matchedRotueStop = store.routeDetail.filter{
        //            $0?.route == route && $0?.bound == direction && $0?.service_type == service_type
        //        }
        //        let matchedRouteStopList = matchedRotueStop.map{$0?.seqData}.first
        VStack{
            List{
                if (store.busRouteStopResult.isEmpty){
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(1.5, anchor: .center)
                }
                ForEach(store.busRouteStopResult,id: \.?.seq){ item in
                    NavigationLink {
                        //Text("Item at \(item.toDetail()) ")
                        BusEtaDetailView(stopName: item!.stopName, stopCode: item!.stop, route: String(item!.route), service_type: String(item!.service_type))
                    } label: {
                        Text(item!.toSeqRow())
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
        }.task( {
            store.getRouteStops(self.route, self.direction, self.service_type)
        })
        .navigationTitle(selectedRouteStr)
        .navigationBarTitleDisplayMode(.inline)
    }
}
    
//#Preview {
//    BusRouteStopView(route: "1A", selectedRouteStr: "1A 尖沙咀碼頭 -> 中秀戊坪", direction: "O", service_type: "1").environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}

