//
//  HTTPClient.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 15/6/2024.
//

import Foundation
import Combine



class HTTPClient {
    
    func fetch<T: Decodable>(URLStr: String) -> AnyPublisher<T, Error> {
        
        guard let encodedURLStr = URLStr.urlEncoded,
              let url = URL(string: encodedURLStr)
        else {
            return Fail(error: NetworkError.badURL).eraseToAnyPublisher()
        }
                
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            .print("Data Debug")
            //.decode(type: T.self, decoder: JSONDecoder())
            .tryMap { result -> T in
                return try JSONDecoder().decode(T.self, from: result)
            }
            .receive(on: DispatchQueue.main)
            .print("debug")
           .catch { error -> AnyPublisher<T, Error> in
               return Just([] as! T).setFailureType(to: Error.self).eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    func fetchBusStops() -> AnyPublisher<BusStopData, Error> {
    
        return URLSession.shared.dataTaskPublisher(for: URL(string: K.Urls.stopURL)!)
            .map(\.data)
            .decode(type: BusStopData.self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
          // .catch { error -> AnyPublisher< [StopData?], Error> in
          //     return Just([] as! [StopData?]).setFailureType(to: Error.self).eraseToAnyPublisher()
          //  }
            .eraseToAnyPublisher()
    }
    
    func fetchBusRoutes() -> AnyPublisher<BusRouteData, Error> {
    
        return URLSession.shared.dataTaskPublisher(for: URL(string: K.Urls.routeURL)!)
            .map(\.data)
            .print("Debug Route:")
            .decode(type: BusRouteData.self, decoder: JSONDecoder())
            .print("debug decode")
            .receive(on: DispatchQueue.main)
          // .catch { error -> AnyPublisher< [StopData?], Error> in
          //     return Just([] as! [StopData?]).setFailureType(to: Error.self).eraseToAnyPublisher()
          //  }
            .eraseToAnyPublisher()
    }
    
    func fetchBusRouteStops() -> AnyPublisher<BusRouteStopData, Error> {
    
        return URLSession.shared.dataTaskPublisher(for: URL(string: K.Urls.routeStopURL)!)
            .map(\.data)
            .print("Debug Route:")
            .decode(type: BusRouteStopData.self, decoder: JSONDecoder())
            .print("debug decode")
            .receive(on: DispatchQueue.main)
          // .catch { error -> AnyPublisher< [StopData?], Error> in
          //     return Just([] as! [StopData?]).setFailureType(to: Error.self).eraseToAnyPublisher()
          //  }
            .eraseToAnyPublisher()
    }
    
    //httpClient.fetch(URLStr: K.Urls.stopURL)
   // httpClient.fetchBusStops()
    
//var stopPublisher = PassthroughSubject<BusStopData, Error>()
//var routePublisher = PassthroughSubject<BusRouteData, Error>()
//        Publishers.CombineLatest(BusAPI.getRouteData(),BusAPI.getStopData())
//            .receive(on: DispatchQueue.main)
//            .sink(receiveCompletion: { completion in
//                switch completion{
//                case .finished:
//                    print("finished")
//                case .failure(let error):
//                    print(error)
//                }
//            }, receiveValue: { result , result2 in
//                print(result2)
//                print(result)
//
//            }).store(in: &cancellables)
}

