//
//  BusRouteStopData.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 7/6/2024.
//
import Foundation
import CoreData
struct BusRouteStopData: BusData , Codable{
    let type: String
    let version: String
    let generated_timestamp: String
    var data : [RouteStopData?] = []

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.version = try container.decode(String.self, forKey: .version)
        self.generated_timestamp = try container.decode(String.self, forKey: .generated_timestamp)
        do{
            let dataArray = try container.decodeIfPresent([RouteStopData].self, forKey: .data)
            self.data = dataArray!
        } catch{
            let dataDict = try container.decodeIfPresent(RouteStopData.self, forKey: .data)
            let dataDictList = [dataDict]
            self.data = dataDictList
        }
    }
    func toStr() -> String {
        return "Version:\(version),Last Modified:\(generated_timestamp)"
    }
    static func loadRouteStopFromDB() -> Dictionary<String, [RouteStopData]> {
        var routeStopDict = Dictionary<String,[RouteStopData]>()
        do {
            let request = NSFetchRequest<RouteStop>(entityName: "RouteStop")
            let itemArray = try PersistenceController.shared.container.viewContext.fetch(request)
            if !itemArray.isEmpty{
                itemArray.forEach{
                    let routeStopData = RouteStopData(co: $0.co ?? "", route: $0.route!, bound: $0.bound!, service_type: $0.service_type!, seq: $0.seq, stop: $0.stop!, stopName: $0.stopName ?? "", data_timeStamp: "")
                    if routeStopDict.keys.contains($0.id!){
                        var newList_routeStop = (routeStopDict[$0.id!])!
                        newList_routeStop.append(routeStopData)
                        routeStopDict.updateValue(newList_routeStop, forKey: $0.id!)
                    } else{
                        routeStopDict.updateValue([routeStopData], forKey: $0.id!)
                    }
                }
            }
        } catch {
            print("Error fetching Routedata from context \(error)")
        }
        return routeStopDict
    }
    
    static func saveRouteStopToDB(data: [RouteStopData?]) {
        var dataToBeInsert = [RouteStop]()
        data.forEach {
            let dataItem = RouteStop(context: PersistenceController.shared.container.viewContext)
            dataItem.route = $0?.route
            dataItem.bound = $0?.bound
            dataItem.seq = Int16($0?.seq ?? 0) 
            dataItem.stop = $0?.stop
            dataItem.stopName = $0?.stopName
            dataItem.co = $0?.co
            dataItem.service_type = $0?.service_type
            dataItem.id = $0?.id.trimOptional()
            dataItem.toStr = $0?.toStr()
            dataToBeInsert.append(dataItem)
        }
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Error during saving  \(error)")
        }
    }
}

struct RouteStopData: BusData , Codable, Identifiable{
    let co : String?
    let route : String
    let bound : String
    let service_type : String
    let seq : Int16
    let stop : String
    var stopName : String
    let data_timeStamp : String?

    var id : String {
        return "\(self.route)-\(self.bound)-\(self.service_type)".trimOptional()
    }
    
    enum ConfigKeys: String, CodingKey {
        case co
        case route
        case bound
        case service_type
        case seq
        case stop
        case data_timeStamp
    }

    init(co: String?, route: String, bound: String, service_type: String, seq: Int16 ,stop: String, stopName: String = "", data_timeStamp : String?)
    {
        self.co = co
        self.route = route
        self.bound = bound
        self.service_type = service_type
        self.seq = seq
        self.stop = stop
        self.stopName = stopName
        self.data_timeStamp = data_timeStamp
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.co = try container.decodeIfPresent(String.self, forKey: .co)
        self.route = try container.decode(String.self, forKey: .route)
        self.bound = try container.decode(String.self, forKey: .bound)
        self.service_type = try container.decode(String.self, forKey: .service_type)
        self.seq = Int16(try container.decode(String.self, forKey: .seq)) ?? 0
        self.stop = try container.decode(String.self, forKey: .stop)
        self.stopName = self.stop
        self.data_timeStamp = try container.decodeIfPresent(String.self, forKey: .data_timeStamp)
    }
    
    func toStr() -> String {
        return "\(route)(\(bound=="O" ? "outbound" : "inbound")) \(seq). \(stopName)"
    }
    
    func toSeqRow() -> String {
        return "\(seq). \(stopName)"
    }
}


