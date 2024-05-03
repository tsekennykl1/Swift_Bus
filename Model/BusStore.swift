import Foundation
import Combine
import CoreData

class BusStore: ObservableObject{
    @Published var busStopDictByCode = Dictionary<String, StopData>()
    @Published var busStopDictByName = Dictionary<String, [StopData]>()
    @Published var busRouteDict = Dictionary<String, RouteData>()
    @Published var routeDetail = [RouteDetail?]()
        
    @Published var busRouteStopResult = [RouteStopData?]()
    @Published var busStopEtaResult = [StopEtaData?]()
    @Published var busEtaDetailResult = [EtaDetailData?]()
    
    @Published var isStopDataCompleted = false
    @Published var isRouteDataCompleted = false
    @Published var isRouteStopDataCompleted = false
 
    private var busRouteStopDict = Dictionary<String, [RouteStopData]>()
    private var cancellables: Set<AnyCancellable> = []
    init(){}
    
    func pingServer(){
        _ = BusAPI.pingServer()
    }
    
    func setupStopView(){
        if self.busStopDictByCode.isEmpty{
            let dbStopData = BusStopData.loadStopFromDB()
            if !dbStopData.isEmpty || isStopDataCompleted{
                self.busStopDictByCode = dbStopData
                self.isStopDataCompleted = true
            } else{
                BusAPI.getStopData()
                    .sink { completion in
                        switch completion{
                        case .finished:
                            print("finished")
                        case .failure(let error):
                            print("Error occurred:\(error)\n")
                        }
                    } receiveValue: { result in
                        result.data.forEach { stop in
                            self.busStopDictByCode.updateValue(stop!, forKey: stop!.stop)
                        }
                        BusStopData.saveStopToDB(data: result.data)
                        self.isStopDataCompleted = true
                    }.store(in: &self.cancellables)
            }
        }
    }
        
    func setupRouteView(){
        if !self.busStopDictByCode.isEmpty && (!self.isRouteDataCompleted || self.busRouteDict.isEmpty) {
            let dbRouteData = BusRouteData.loadRouteFromDB()
            if !dbRouteData.isEmpty{
                self.busRouteDict = dbRouteData
                self.isRouteDataCompleted = true
            } else {
                BusAPI.getRouteData()
                    .sink { completion in
                        switch completion{
                        case .finished:
                            print("finished")
                        case .failure(let error):
                            print("Error occurred:\(error)\n")
                        }
                    } receiveValue: { result in
                        result.data.forEach { route in
                            self.busRouteDict.updateValue(route!, forKey: route!.id)
                        }
                        BusRouteData.saveRouteToDB(data: result.data)
                        self.isRouteDataCompleted = true
                    }.store(in: &self.cancellables)
            }
        }
    }
    
    func setupRouteStopView(){
        if !self.busStopDictByCode.isEmpty && (!self.isRouteStopDataCompleted || self.busRouteStopDict.isEmpty){
            let dbRouteStopData = BusRouteStopData.loadRouteStopFromDB()
            if !dbRouteStopData.isEmpty{
                self.busRouteStopDict = dbRouteStopData
                self.isRouteStopDataCompleted = true
            } else {
                BusAPI.getRouteStopData()
                    .sink { completion in
                        switch completion{
                        case .finished:
                            print("finished")
                        case .failure(let error):
                            print("Error occurred:\(error)\n")
                        }
                    } receiveValue: { result in
                        var data = result.data
                        for index in 0...data.count-1{
                            data[index]!.stopName = self.getBusStopName(stopCode: result.data[index]!.stop)
                            let id = data[index]?.id
                            if self.busRouteStopDict.keys.contains(id!){
                                var newList_routeStop = (self.busRouteStopDict[id!])!
                                newList_routeStop.append(data[index]!)
                                self.busRouteStopDict.updateValue(newList_routeStop, forKey: id!)
                            } else{
                                self.busRouteStopDict.updateValue([data[index]!], forKey: id!)
                            }
                        }
                        BusRouteStopData.saveRouteStopToDB(data: data)
                        self.isRouteStopDataCompleted = true
                    }.store(in: &self.cancellables)
            }
        }
    }
    
    func setupDetail(){
        self.busRouteDict.forEach{ key, value in
            if self.busRouteStopDict.keys.contains(key.trimOptional()) {
                let routeDetail = RouteDetail(route: value, routeStop: self.busRouteStopDict[key.trimOptional()]!)
                self.routeDetail.append(routeDetail)
            }
      }
        let keysAndValues = self.busStopDictByCode.values.map { ($0.name_tc, [$0]) }
         let busStopDict = Dictionary(keysAndValues, uniquingKeysWith: { $0 + $1 })
        self.busStopDictByName = busStopDict
    }
    
    func getRouteStops(_ route: String = "", _ direction: String="", _ service_type: String = ""){
        BusAPI.getRouteStopData(route, direction, service_type)
            .sink { completion in
                switch completion{
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error occurred:\(error)\n")
                }
            } receiveValue: { result in
                var data = result.data
                if !data.isEmpty {
                    for index in 0...data.count-1{
                        data[index]?.stopName = self.getBusStopName(stopCode: result.data[index]!.stop)
                    }
                }
                self.busRouteStopResult = data
            }.store(in: &self.cancellables)
    }
    
    func getStopEta(_ stopCode: String = "") {

        BusAPI.getStopEtaData(stopCode)
            .sink { completion in
                switch completion{
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error occurred:\(error)\n")
                }
            } receiveValue: { result in
                self.busStopEtaResult = result.data
            }.store(in: &self.cancellables)
    }
    
    func getEtaDetail(_ route: String, _ stopCode: String, _ service_type: String = ""){
        var etaDetailData = [EtaDetailData?]()
        BusAPI.getEtaDetailData(route, stopCode, service_type)
            .sink { completion in
                switch completion{
                case .finished:
                    print("finished")
                case .failure(let error):
                    print("Error occurred:\(error)\n")
                }
            } receiveValue: { result in
                var data = result.data
                if !data.isEmpty{
                    for index in 0...data.count-1{
                        data[index]?.stopName = self.getBusStopName(stopCode: result.data[index]?.stop ?? "")
                    }
                }
                etaDetailData = data
                self.busEtaDetailResult = etaDetailData
            }.store(in: &self.cancellables)
    }
    
    func getBusStopName(stopCode: String) -> String {
        return self.busStopDictByCode[stopCode]?.name_tc ?? ""
    }
    
    func getRouteKey(routeData: RouteData)->String{
        return "\(routeData.route)-\(routeData.bound)-\(routeData.service_type)"
    }
    
    func getRouteStopKey(routeStopData: RouteStopData)->String{
        return "\(routeStopData.route)-\(routeStopData.bound)-\(routeStopData.service_type)"
    }
    
    func getRouteInfo(routeKey: String) -> (orig: String, dest: String){
        let route = self.busRouteDict[routeKey]
        return(route?.orig_tc ?? "",route?.dest_tc ?? "")
    }
}
