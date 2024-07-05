//
//  BusData.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 7/6/2024.
//
import Foundation
import CoreData

struct BusStopData: BusData , Codable{
    let type: String
    let version: String
    let generated_timestamp: String
    var data : [StopData?] = []

    init(from decoder: Decoder) throws {
       // let decoder = JSONDecoder()
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.version = try container.decode(String.self, forKey: .version)
        self.generated_timestamp = try container.decode(String.self, forKey: .generated_timestamp)
        
        do{
            let dataArray = try container.decodeIfPresent([StopData].self, forKey: .data)
            self.data = dataArray!
        } catch{
            let dataDict = try container.decodeIfPresent(StopData.self, forKey: .data)
            let dataDictList = [dataDict]
            self.data = dataDictList
        }
    }
    func toStr() -> String {
        return "Version:\(version),Last Modified:\(generated_timestamp)"
    }
    
    static func loadStopFromDB() -> Dictionary<String,StopData> {
        var stopDataDict = Dictionary<String,StopData>()
        do{
            let request = NSFetchRequest<Stop>(entityName: "Stop")
            let itemArray = try PersistenceController.shared.container.viewContext.fetch(request)
            if !(itemArray.isEmpty) {
                itemArray.forEach{
                    stopDataDict.updateValue(StopData(stop: $0.stop!, name_en: $0.name_en!, name_tc: $0.name_tc!, name_sc: $0.name_sc!, lat: $0.lat, long: $0.long, data_timeStamp: ""),forKey: $0.stop!)
                }
            }
        } catch {
            print("Error fetching Stopdata from context \(error)")
        }
        return stopDataDict
    }
    
    static func saveStopToDB(data: [StopData?]) {
        var dataToBeInsert = [Stop]()
        data.forEach {
            let dataItem = Stop(context: PersistenceController.shared.container.viewContext)
            dataItem.stop = $0?.stop
            dataItem.name_en = $0?.name_en
            dataItem.name_tc = $0?.name_tc
            dataItem.name_sc = $0?.name_sc
            dataItem.lat = Double($0?.lat ?? 0)
            dataItem.long = Double($0?.long ?? 0)
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

struct StopData: BusData , Codable, Identifiable{
    
    let id : String
    let stop : String
    let name_en: String
    let name_tc: String
    let name_sc: String
    let lat : Double
    let long : Double
    let data_timeStamp : String?
    
    var stopName:String {
        switch LocalizationManager.shared.language{
            case .english: return name_en
        case .t_chinese: return name_tc
        case .s_chinese: return name_sc
        }
        
    }
    
    init(stop: String, name_en: String,name_tc: String,name_sc: String, lat : Double, long: Double, data_timeStamp: String){
        self.stop = stop
        self.id = self.stop
        self.name_en = name_en
        self.name_tc = name_tc
        self.name_sc = name_sc
        self.lat = lat
        self.long = long
        self.data_timeStamp = data_timeStamp
    }
    
    enum ConfigKeys: String, CodingKey {
        case stop
        case name_en
        case name_tc
        case name_sc
        case lat
        case long
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.stop = try container.decode(String.self, forKey: .stop)
        self.id = self.stop
        self.name_en = try container.decode(String.self, forKey: .name_en)
        self.name_tc = try container.decode(String.self, forKey: .name_tc)
        self.name_sc = try container.decode(String.self, forKey: .name_sc)
        self.lat = try container.decode(String.self, forKey: .lat).toDouble() ?? 0.0
        self.long = try container.decode(String.self, forKey: .long).toDouble() ?? 0.0
        self.data_timeStamp = try container.decodeIfPresent(String.self, forKey: .data_timeStamp)
    }

    func toStr() -> String {
        return stopName
    }
    
    func toBusStop() -> (String,String){
        return (stop,stopName)
    }
}
