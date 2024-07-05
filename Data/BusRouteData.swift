//
//  BusRouteData.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 7/6/2024.
//
import Foundation
import CoreData
struct BusRouteData: BusData , Codable{

    let type: String
    let version: String
    let generated_timestamp: String
    var data : [RouteData?] = []
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.version = try container.decode(String.self, forKey: .version)
        self.generated_timestamp = try container.decode(String.self, forKey: .generated_timestamp)
        
        do{
            let dataArray = try container.decodeIfPresent([RouteData].self, forKey: .data)
            self.data = dataArray!
        } catch{
            let dataDict = try container.decodeIfPresent(RouteData.self, forKey: .data)
            let dataDictList = [dataDict]
            self.data = dataDictList
        }
    }

    func toStr() -> String {
        return "Version:\(version),Last Modified:\(generated_timestamp)"
    }
    
    static func loadRouteFromDB() -> Dictionary<String,RouteData> {
        var routeData = Dictionary<String,RouteData>()
        do {
            
            let request = NSFetchRequest<Route>(entityName: "Route")
            let itemArray = try PersistenceController.shared.container.viewContext.fetch(request)
            if !itemArray.isEmpty{
                itemArray.forEach{
                    routeData.updateValue(RouteData(co: $0.co, route: $0.route!, bound: $0.bound!, service_type: $0.service_type!, orig_en: $0.orig_en!, orig_tc: $0.orig_tc!, orig_sc: $0.orig_sc!, dest_en: $0.dest_en!, dest_tc: $0.dest_tc!, dest_sc: $0.dest_sc!, data_timeStamp: nil), forKey: "\(String(describing: $0.route))-\(String(describing: $0.bound))-\(String(describing: $0.service_type))")}
            }
        } catch {
            print("Error fetching Routedata from context \(error)")
        }
        return routeData
    }
    
    static func saveRouteToDB(data: [RouteData?]) {
        var dataToBeInsert = [Route]()
        data.forEach {
            let dataItem = Route(context: PersistenceController.shared.container.viewContext)
            dataItem.route = $0?.route
            dataItem.bound = $0?.bound
            dataItem.dest_en = $0?.dest_en
            dataItem.dest_tc = $0?.dest_tc
            dataItem.dest_sc = $0?.dest_sc
            dataItem.orig_en = $0?.orig_en
            dataItem.orig_tc = $0?.orig_tc
            dataItem.orig_sc = $0?.orig_sc
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

struct RouteData: BusData, Codable, Identifiable {
    
    let co : String?
    let route: String
    let bound: String
    let service_type: String
    let orig_en: String
    let orig_tc: String
    let orig_sc: String
    let dest_en : String
    let dest_tc : String
    let dest_sc : String
    let data_timeStamp : String?
        
    var dest:String {
        switch LocalizationManager.shared.language{
            case .english: return dest_en
            case .t_chinese: return dest_tc
            case .s_chinese: return dest_sc
        }
    }
    
    var orig:String {
        switch LocalizationManager.shared.language{
            case .english: return orig_en
            case .t_chinese: return orig_tc
            case .s_chinese: return orig_sc
        }
    }
    
    var id : String {
        return "\(self.route)-\(self.bound)-\(self.service_type)".trimOptional()
    }
    
    init(co: String?, route: String, bound: String, service_type: String, orig_en: String ,orig_tc: String, orig_sc: String, dest_en: String, dest_tc : String, dest_sc : String, data_timeStamp : String?){
        self.co = co
        self.route = route
        self.bound = bound
        self.service_type = service_type
        self.orig_en = orig_en
        self.orig_tc = orig_tc
        self.orig_sc = orig_sc
        self.dest_en = dest_en
        self.dest_tc = dest_tc
        self.dest_sc = dest_sc
        self.data_timeStamp = data_timeStamp
    }
    enum ConfigKeys: String, CodingKey {
        case co
        case route
        case bound
        case service_type
        case orig_en
        case orig_tc
        case orig_sc
        case dest_en
        case dest_tc
        case dest_sc
        case data_timeStamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.co = try container.decodeIfPresent(String.self, forKey: .co)
        self.route = try container.decode(String.self, forKey: .route)
        self.bound = try container.decode(String.self, forKey: .bound)
        self.service_type = try container.decode(String.self, forKey: .service_type)
        self.orig_en = try container.decode(String.self, forKey: .orig_en)
        self.orig_tc = try container.decode(String.self, forKey: .orig_tc)
        self.orig_sc = try container.decode(String.self, forKey: .orig_sc)
        self.dest_en = try container.decode(String.self, forKey: .dest_en)
        self.dest_tc = try container.decode(String.self, forKey: .dest_tc)
        self.dest_sc = try container.decode(String.self, forKey: .dest_sc)
        self.data_timeStamp = try container.decodeIfPresent(String.self, forKey: .data_timeStamp)
    }
    
    func toStr() -> String {
        return "\(route) - \(orig)->\(dest)"
    }
}
