//
//  BusETADetail.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 5/6/2024.
//

import Foundation
import SwiftUI
struct BusEtaDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var store : BusStore
    let stopName: String
    let stopCode: String
    let route: String
    let service_type: String

    @State var StopETAList: [EtaDetailData?] = []
    var body: some View {
            List{
                ForEach(store.busEtaDetailResult,id: \.?.id) { item in
                        Text(item!.toDetail())
                }
        }.task ({
             store.getEtaDetail(self.route, self.stopCode, self.service_type)
        })
        .navigationTitle("\(route) - \(stopName)")
        .navigationBarTitleDisplayMode(.inline)
    }
}
                   
    
//#Preview {
//    BusRouteStopView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//}
//

