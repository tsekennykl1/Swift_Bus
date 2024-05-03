//
//  BusRouteDetailView.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 22/6/2024.
//

import SwiftUI

struct BusRouteDetailView: View {
    
    @EnvironmentObject var store : BusStore
    
    var body: some View {
        List{
            ForEach(store.routeDetail,id: \.?.id) { item in
                VStack{
                    Section(header:
                        Text(item!.toHeader()).multilineTextAlignment(.leading).font(.title2).fontWeight(.bold)){
                        ForEach(item!.seqData.sorted(by:{ $0!.seq < $1!.seq }),id: \.?.seq ){ seq in
                                Text((seq?.toSeqRow())!).frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topLeading)
                        }
                    }
                    Spacer()
                }.frame(maxWidth: .infinity,maxHeight: .infinity,alignment: .topLeading)
            }
        }.listStyle(GroupedListStyle())
    }
}

//#Preview {
//    BusRouteDetailView()
//}
