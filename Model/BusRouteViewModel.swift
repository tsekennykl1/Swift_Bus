import Foundation
import CoreData


class BusRouteViewModel :BusDataModel,ObservableObject {
    @Published var status = Status.notStarted
    var busRouteList = [(String, String)]()// "route,bound,service_type": "toStr"
    var dataString: String {
        var str :String = ""
        for route in data {
            
            str = str + (route?.toStr() ?? "") + "\n"
        }
        return str
    }
    
    var dataStringList: [(String,String)]{
        var strList : [(String,String)] = []
        let routeData = (data as! [RouteData])
        for route in routeData{
            strList.append( ( "\(route.route),\(route.bound),\(route.service_type)" ,"\(route.route) - \(route.orig_tc)->\(route.dest_tc)") )
        }
        return strList
    }
    
    override init(_ type: String, _ version: String, _ generated_timestamp: String) {
        super.init(type, version, generated_timestamp)
    }
    
    override func setData(_ data: [BusData?]){
        self.data = (data as! [RouteData?])
        _ = self.data.map{self.dataDict.updateValue($0!, forKey: ($0! as! RouteData).route)}
    }
    
    override init(){
        super.init()
//        Task {
//            if !( await load_from_DB()){
//                await getAllRoutes()
//            }
//        }
    }
    
    
    func setupRoute() -> [RouteData?] {
        Task {
            print("Setting up Bus Route")
            if !(load_from_DB()){
                await getAllRoutes()
            }
            return self.data as! [RouteData?]
        }
        return self.data as! [RouteData?]
    }
    
    func getAllRoutes() async {
        let controller =  FetchController()
        status = .fetching
        do {
            let allRoutes = try  await controller.fetch(URL(string: K.Urls.routeURL)!)
            //   allStops.sort { $0.id < $1.id }
            try parseJSON(allRoutes)
            status = .success
             save()
        } catch {
            status = .failed(error: error)
        }

        
    }

    func parseJSON(_ busData: Data) throws{
        let decoder = JSONDecoder()
        do {
            print("decode BusRoute data")
            let decodedData = try decoder.decode(BusRouteData.self, from: busData)
            self.version = decodedData.version
            self.type = decodedData.type
            self.generated_timestamp = decodedData.generated_timestamp
            self.data = decodedData.data
        } catch {
            print("decode Error")
            throw NetworkError.decodingError
        }
    }
    
    func load_from_DB() -> Bool {
        var load_success = false
        do {
            print("loading")
            let request = NSFetchRequest<Route>(entityName: "Route")
            let itemArray = try PersistenceController.shared.container.viewContext.fetch(request)
            if !itemArray.isEmpty{
                itemArray.forEach{self.data.append(RouteData(co: $0.co, route: $0.route!, bound: $0.bound!, service_type: $0.service_type!, orig_en: $0.orig_en!, orig_tc: $0.orig_tc!, orig_sc: $0.orig_sc!, dest_en: $0.dest_en!, dest_tc: $0.dest_tc!, dest_sc: $0.dest_sc!, data_timeStamp: nil))}
                
                self.busRouteList = itemArray.map{(String("\($0.route),\($0.bound == "O" ? "outbound" : "inbound"),\($0.service_type)"),$0.toStr!)}
                print("loaded")
                load_success = true
            }
        } catch {
            print("Error fetching Routedata from context \(error)")
        }
        return load_success
    }
    
    func save() {
        var dataToBeInsert = [Route]()
        (self.data as! [RouteData]).forEach {
            let dataItem = Route(context: PersistenceController.shared.container.viewContext)
            dataItem.route = $0.route
            dataItem.bound = $0.bound
            dataItem.dest_en = $0.dest_en
            dataItem.dest_tc = $0.dest_tc
            dataItem.dest_sc = $0.dest_sc
            dataItem.orig_en = $0.orig_en
            dataItem.orig_tc = $0.orig_tc
            dataItem.orig_sc = $0.orig_sc
            dataItem.co = $0.co
            dataItem.service_type = $0.service_type
            dataItem.toStr = $0.toStr()
            dataToBeInsert.append(dataItem)
        }
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Error during saving  \(error)")
        }
        print("inserted Route Data")
    }
    
}
