//
//  BusEtaDetailData.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 7/6/2024.
//
import Foundation
struct BusEtaDetailData: BusData, Codable{
    func toStr() -> String {
        return "Version:\(version),Last Modified:\(generated_timestamp)"
    }
    let type: String
    let version: String
    let generated_timestamp: String
    var data : [EtaDetailData?] = []
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.type = try container.decode(String.self, forKey: .type)
        self.version = try container.decode(String.self, forKey: .version)
        self.generated_timestamp = try container.decode(String.self, forKey: .generated_timestamp)
        
        do{
            let dataArray = try container.decodeIfPresent([EtaDetailData].self, forKey: .data)
            self.data = dataArray!
        } catch{
            let dataDict = try container.decodeIfPresent(EtaDetailData.self, forKey: .data)
            let dataDictList = [dataDict]
            self.data = dataDictList
        }
    }
}

struct EtaDetailData: BusData , Codable, Identifiable{
    let id : String
    let co : String?
    let route : String
    let dir : String
    let service_type : Int
    let seq : Int
    let stop : String?
    var stopName: String?
    let dest_en : String
    let dest_tc : String
    let dest_sc : String
    let eta_seq : Int?
    let eta : String?
    let rmk_en : String?
    let rmk_tc : String?
    let rmk_sc : String?
    let data_timeStamp : String?
    
    enum ConfigKeys: String, CodingKey {
        case co
        case route
        case dir
        case service_type
        case seq
        case stop
        case dest_en
        case dest_tc
        case dest_sc
        case eta_seq
        case eta
        case rmk_en
        case rmk_tc
        case rmk_sc
        case data_timeStamp
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.co = try container.decodeIfPresent(String.self, forKey: .co)
        self.route = try container.decode(String.self, forKey: .route)
        self.dir = try container.decode(String.self, forKey: .dir)
        self.service_type = try container.decode(Int.self, forKey: .service_type)
        self.seq = try container.decode(Int.self, forKey: .seq)
        self.stop = try container.decodeIfPresent(String.self, forKey: .stop)
        self.stopName = self.stop ?? ""
        self.dest_en = try container.decode(String.self, forKey: .dest_en)
        self.dest_tc = try container.decode(String.self, forKey: .dest_tc)
        self.dest_sc = try container.decode(String.self, forKey: .dest_sc)
        self.eta_seq = try container.decodeIfPresent(Int.self, forKey: .eta_seq)
        self.eta = try container.decodeIfPresent(String.self, forKey: .eta)
        self.rmk_en = try container.decodeIfPresent(String.self, forKey: .rmk_en)
        self.rmk_tc = try container.decodeIfPresent(String.self, forKey: .rmk_tc)
        self.rmk_sc = try container.decodeIfPresent(String.self, forKey: .rmk_sc)
        self.id = "\(route)_\(dir)_\(service_type)_\(seq)_\(String(describing: stop))_\(dest_en)_\(String(describing: eta_seq))"
        self.data_timeStamp = try container.decodeIfPresent(String.self, forKey: .data_timeStamp)
    }
    
    func toStr() -> String {
        let lang = LocalizationManager.shared.language
        var eta_rmk_str = ""
        if eta != nil{
            let etaTime = Calendar.current.dateComponents([.hour, .minute, .second], from:Date() ,to:ISO8601DateFormatter().date(from: eta!)! )
            eta_rmk_str = "\n\t\(etaTime.hour!) hr \(etaTime.minute!) min \(etaTime.second!) sec".localized(lang)
        }
        if rmk_tc != "" {
            eta_rmk_str += " - \(rmk_tc!)"
        }
        return "\(route): \(dir=="O" ? "從" : "到") \(dest_tc) \(dir=="O" ? "出發" : "總站")  \(eta_rmk_str)".localized(lang)
    }
    
    func toDetail() -> String{
        return "Company:\(co!)\nRoute:\(route),\(dir),\(String(service_type))\nStop:\(String(describing: stop != nil ? stop : ""))\nDest:\(dest_tc)\neta:\(eta_seq != nil ? eta_seq! : 1 ) - \(eta != nil ? eta! : "")\nRemark:\(rmk_tc != nil ? rmk_tc! : "")"
    }
}


