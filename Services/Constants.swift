//
//  Constants.swift
//  Bus_ride_swift
//
//  Created by Kwok Leung Tse on 18/4/2024.
//
import Foundation
struct K {
    struct ApiKeys{
        static let omdbIdKey = "198f0849"
    }
    struct Urls{
        static let baseURL = "https://data.etabus.gov.hk/v1/transport/kmb"
        static let stopURL = baseURL + "/stop"
        static let routeURL = baseURL + "/route"
        static let routeStopURL = baseURL + "/route-stop"
        static let stopETA_URL = baseURL + "/stop-eta"
        static let eTADetail_URL = baseURL + "/eta"
    }
    struct Location{
        static let lat = 22.325485
        static let long = 114.214337
    }
}
protocol BusData: Codable {
    func toStr() -> String
}
protocol BusResponseData: Codable {
    var type: String { get }
    var version: String { get }
    var generated_timestamp: String { get }
    var data : [BusData?] { get }
    func toStr() -> String
}

enum Status{
    case notStarted
    case fetching
    case success
    case failed(error: Error)
}
