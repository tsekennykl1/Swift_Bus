//
//  BusEtaDetailDataModel.swift
//  bus_ride_plan_app
//
//  Created by Kwok Leung Tse on 6/2/2024.
//

import Foundation


class BusEtaDetailViewModel :BusDataModel,ObservableObject {
    @Published var status = Status.notStarted
    override init(){
        super.init()
        
    }
    override init(_ type: String, _ version: String, _ generated_timestamp: String) {
        super.init(type, version, generated_timestamp)
    }
    
    override func setData(_ data: [BusData?]){
        self.data = (data as! [EtaDetailData?])
       // _ = self.data.map{self.dataDict.updateValue($0!, forKey: ($0! as! StopRouteData).route)}
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
    
    func geETADetail(stopCode: String, route: String, service_type: Int) async {
        
        let controller =  FetchController()
        status = .fetching
        do {
            let urlString = "\(K.Urls.eTADetail_URL)/\(stopCode)/\(route)/\(service_type)"
            let eTAList = try await controller.fetch(URL(string: urlString)!)
            //   allStops.sort { $0.id < $1.id }
            try parseJSON(eTAList)
            status = .success
        } catch {
            status = .failed(error: error)
        }
        
    }
    
    func parseJSON(_ busData: Data) throws{
        let decoder = JSONDecoder()
        do {
            
            let decodedData = try decoder.decode(BusEtaDetailData.self, from: busData)
            self.version = decodedData.version
            self.type = decodedData.type
            self.generated_timestamp = decodedData.generated_timestamp
            self.data = decodedData.data
        } catch {
            throw NetworkError.decodingError
        }
    }
}
