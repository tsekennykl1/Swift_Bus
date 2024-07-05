//
//  RouteDetail.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 22/6/2024.
//
import Foundation

struct RouteDetail : Identifiable{
    let id : String
    let co : String?
    let route : String
    let bound : String
    let service_type : String
    let orig_en: String
    let orig_tc: String
    let orig_sc: String
    let dest_en : String
    let dest_tc : String
    let dest_sc : String
    var seqData = [RouteStopData?]()
    
    var dest:String {
        let lang = LocalizationManager.shared.language
        switch lang{
            case .english: return dest_en
            case .t_chinese: return dest_tc
            case .s_chinese: return dest_sc
        }
    }
    
    var orig:String {
        let lang = LocalizationManager.shared.language
        switch lang{
            case .english: return orig_en
            case .t_chinese: return orig_tc
            case .s_chinese: return orig_sc
        }
    }
    
    init(route: RouteData, routeStop: [RouteStopData]){
        self.id = route.id
        self.co = route.co
        self.route = route.route
        self.bound = route.bound
        self.service_type = route.service_type
        self.orig_en = route.orig_en
        self.orig_tc = route.orig_tc
        self.orig_sc = route.orig_sc
        self.dest_en = route.dest_en
        self.dest_tc = route.dest_tc
        self.dest_sc = route.dest_sc
        self.seqData = routeStop
    }
    
    func toStr() -> String {
        return self.id + " has seq of " + String(seqData.count)
    }
    
    func toHeader() -> String {
        return "\(route) - \(orig)->\(dest)"
    }
}


