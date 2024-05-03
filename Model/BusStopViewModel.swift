import Foundation
import CoreData

class BusStopViewModel : BusDataModel,ObservableObject{
    @Published var status = Status.notStarted
    var bustStopsName : Dictionary <String, String> = Dictionary()
    var dataString: String {
        var str :String = ""
        for route in data {
            str += (route?.toStr() ?? "") + "\n"
        }
        return str
    }
    
    var dataStringList: [(String,String)]{
        var strList : [(String,String)] = []
        for stop in data {
            strList.append((stop as! StopData).toBusStop())
        }
        return strList
    }
    
    
    
    override init(_ type: String, _ version: String, _ generated_timestamp: String) {
        super.init(type, version, generated_timestamp)
    }
    
    override func setData(_ data: [BusData?]){
        self.data = data as! [StopData?]
        data.forEach{
            self.dataDict.updateValue($0!, forKey: ($0! as! StopData).stop)
        }
    }
    
    override init(){
        super.init()
      //  Task{
      //      await setupBusStop()
      //  }

        
    }
    
    func setupBusStop() -> [StopData?] {
        Task {
            print("Setting up Bus Stop")
            if !( await load_from_DB()){
                return await getBusStops()
            }
        }
        return self.data as! [StopData?]
    }
    
    func getBusStops() async  {
        
        let controller =  FetchController()
        status = .fetching
        do {
            let allStops = try await controller.fetch(URL(string: K.Urls.stopURL)!)
            //   allStops.sort { $0.id < $1.id }
            try parseJSON(allStops)
            status = .success
            save()
        } catch {
            status = .failed(error: error)
        }
        
    }
    
    func parseJSON(_ busData: Data) throws{
        let decoder = JSONDecoder()
        do {
            print("decode BusStop data")
            let decodedData = try decoder.decode(BusStopData.self, from: busData)
            self.version = decodedData.version
            self.type = decodedData.type
            self.generated_timestamp = decodedData.generated_timestamp
            self.data = decodedData.data
        } catch {
            print("decode error")
            throw NetworkError.decodingError
        }
    }
    
    func load_from_DB() -> Bool {
        var load_success = false
        do{
            print("loading")
            let request = NSFetchRequest<Stop>(entityName: "Stop")
            let itemArray = try PersistenceController.shared.container.viewContext.fetch(request)
            if !(itemArray.isEmpty) {
                itemArray.forEach{
                    self.data.append(StopData(stop: $0.stop!, name_en: $0.name_en!, name_tc: $0.name_tc!, name_sc: $0.name_sc!, lat: $0.lat, long: $0.long, data_timeStamp: ""))
                }
                itemArray.forEach{self.bustStopsName.updateValue($0.name_tc!, forKey: $0.stop!)}
                print("loaded")
                load_success = true
            }
        } catch {
            print("Error fetching Stopdata from context \(error)")
        }
        return load_success
    }
    
    func save() {
        var dataToBeInsert = [Stop]()
        (self.data as! [StopData]).forEach {
            let dataItem = Stop(context: PersistenceController.shared.container.viewContext)
            dataItem.stop = $0.stop
            dataItem.name_en = $0.name_en
            dataItem.name_tc = $0.name_tc
            dataItem.name_sc = $0.name_sc
            dataItem.lat = Double($0.lat)
            dataItem.long = Double($0.long)
            dataItem.toStr = $0.toStr()
            dataToBeInsert.append(dataItem)
        }
        do {
            try PersistenceController.shared.container.viewContext.save()
        } catch {
            print("Error during saving  \(error)")
        }
        print("inserted Stop Data")
    }
}

