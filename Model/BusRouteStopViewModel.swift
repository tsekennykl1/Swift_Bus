//
//  BusRouteStopDataModel.swift
//  bus_ride_plan_app
//
//  Created by Kwok Leung Tse on 3/2/2024.
//

import Foundation


class BusRouteStopViewModel :BusDataModel,ObservableObject {
    @Published var status = Status.notStarted
    //@Published var RouteStopData: [RouteStopData]
    override init(){
        super.init()
    }
    
    override init(_ type: String, _ version: String, _ generated_timestamp: String) {
        super.init(type, version, generated_timestamp)
    }
    
    override func setData(_ data: [BusData?]){
        self.data = (data as! [RouteStopData?])
        self.data.forEach{self.dataDict.updateValue($0!, forKey: ($0! as! RouteStopData).route)}
    }
    
    var dataString: String {
        var str :String = ""
        for route in data {
            
            str = str + (route?.toStr() ?? "") + "\n"
        }
        return str
    }
    
    var dataStringList: [String]{
        var strList : [String] = []
        for dataElement in data {
            strList.append((dataElement?.toStr())!)
        }
        return strList
    }
    func getBusRouteStops(route: String = "", direction: String="", service_type: String="") async {
        
        let controller =  FetchController()
        status = .fetching
        do {
            var urlString = "\(K.Urls.routeStopURL)"
            if (route != "" && direction != "" && service_type != "")
            {
                urlString = "\(K.Urls.routeStopURL)/\(String(route))/\(String(direction=="O" ? "outbound" : "inbound"))/\(String(service_type))"
            }

            let allRouteStops = try await controller.fetch(URL(string: urlString)!)
            //   allStops.sort { $0.id < $1.id }
            try parseJSON(allRouteStops)
            status = .success
        } catch {
            status = .failed(error: error)
        }
        
    }
    func parseJSON(_ busData: Data) throws{
        let decoder = JSONDecoder()
        do {
            
            let decodedData = try decoder.decode(BusRouteStopData.self, from: busData)
            self.version = decodedData.version
            self.type = decodedData.type
            self.generated_timestamp = decodedData.generated_timestamp
            self.data = decodedData.data
        } catch {
            throw NetworkError.decodingError
        }
    }
}
