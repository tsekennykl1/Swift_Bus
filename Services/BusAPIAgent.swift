//
//  Agent.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 13/6/2024.
//
import Foundation
import Combine

enum NetworkError: Error {
    case badURL
    case decodingError
    case noData
    case badResponse
}

struct BusAPIAgent {
    func ping() throws -> AnyPublisher<Bool,Error>{
        URLSession.shared.dataTaskPublisher(for: URL(string: K.Urls.baseURL)! )
          //  .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .tryMap({ (data, response) -> Bool in
                 guard
                     let response = response as? HTTPURLResponse,
                     response.statusCode >= 200 else {
                     throw URLError(.badServerResponse)
                 }
                return true
             })
            .retry(3)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        //return Just(true).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func run<T: Decodable>(_ request: URLRequest, _ decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: request)
        //  .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .tryMap({ (data, response) -> Data in
                print("Debug tryMap: ****  \(data)")
                guard
                    let response = response as? HTTPURLResponse,
                    response.statusCode == 200 else {
                    throw URLError(.badServerResponse)
                }
                return data
            })
            .retry(3)
            .tryMap { result -> T in
                return try decoder.decode(T.self, from: result)
            }
          .catch { error -> AnyPublisher<T, Error> in
                return Just([] as! T).setFailureType(to: Error.self).eraseToAnyPublisher()
           }.delay(for: 0.5, scheduler: RunLoop.main)
            .share()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func fetch(_ baseURL: URL) async throws -> Data {
        let fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        guard let fetchURL = fetchComponents?.url else {
            throw
            NetworkError.badURL
        }
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("NetworkError.badResponse")
            throw NetworkError.badResponse
        }
        return data
    }
    
    func multiFetch(_ baseURL: [URL]) async throws -> [Data]{
        var returnData = [Data]()
        let dispatchGroup = DispatchGroup()
        for i in 0...baseURL.count-1 {
            dispatchGroup.enter()
            let fetchComponents = URLComponents(url: baseURL[i], resolvingAgainstBaseURL: true)
            //fetchComponents?.queryItems = [URLQueryItem(name: "limit", value "386")]
            guard let fetchURL = fetchComponents?.url else {
                throw
                NetworkError.badURL
            }
            let (data, response) = try await URLSession.shared.data(from: fetchURL)
            print("data, response")
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("NetworkError.badResponse")
                throw NetworkError.badResponse
            }
            dispatchGroup.leave()
            //dispatchGroup.wait()
            returnData.append(data)
        }
            return returnData
    }
}

enum BusAPI {
    static let agent = BusAPIAgent()
}

extension BusAPI {
    static func pingServer() -> AnyPublisher<Bool,Error>{
        return try! agent.ping()
    }
    static func getStopData() -> AnyPublisher<BusStopData, Error> {
        let request = URLRequest(url: URL(string: K.Urls.stopURL)!)
        return agent.run(request)
    }
    static func getRouteData(route: String = "") -> AnyPublisher<BusRouteData, Error> {
        var urlString = "\(K.Urls.routeURL)"
        if (route != "")
        {
            urlString = "\(K.Urls.routeStopURL)/\(String(route))"
        }
        let request = URLRequest(url: URL(string: urlString)!)
        return agent.run(request)
    }
    static func getRouteStopData(_ route: String = "", _ direction: String = "", _ service_type: String = "") -> AnyPublisher<BusRouteStopData, Error> {
        var urlString = "\(K.Urls.routeStopURL)"
        if (route != "" && direction != "" && service_type != "")
        {
            urlString = "\(K.Urls.routeStopURL)/\(String(route))/\(String(direction=="O" ? "outbound" : "inbound"))/\(String(service_type))"
        }
        let request = URLRequest(url: URL(string: urlString)!)
        return agent.run(request)
    }
    static func getStopEtaData(_ stopCode: String) -> AnyPublisher<BusStopEtaData, Error> {
        let urlString = K.Urls.stopETA_URL + (stopCode != "" ? "/\(stopCode)" : "")
            let request = URLRequest(url: URL(string: urlString)!)
        return agent.run(request)
    }
    static func getEtaDetailData(_ route: String, _ stopCode: String, _ service_type: String) -> AnyPublisher<BusEtaDetailData, Error> {
        var urlString = "\(K.Urls.eTADetail_URL)"
        if (route != "" && stopCode != "" && service_type != "")
        {
            urlString = "\(K.Urls.eTADetail_URL)/\(String(stopCode))/\(String(route))/\(String(service_type))"
        }
        let request = URLRequest(url: URL(string: urlString)!)
        return agent.run(request)
    }
}
