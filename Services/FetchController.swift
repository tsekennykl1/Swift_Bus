//
//  FetchController.swift
//  Swift_Bus
//
//  Created by Kwok Leung Tse on 3/5/2024.
//

import Foundation
struct FetchController {
    enum NetworkError: Error {
        case badURL, badResponse, badData
    }
    
    func fetch(_ baseURL: URL) async throws -> Data {
        //    func FetchAllBusStop() async throws {
        //   var allBusStop: [StopData] = []
        let fetchComponents = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        //fetchComponents?.queryItems = [URLQueryItem(name: "limit", value "386")]
        print("URL = \(String(describing: fetchComponents?.url!))")
        guard let fetchURL = fetchComponents?.url else {
            throw
            NetworkError.badURL
        }
        print("after fetchURL")
        //let (data, response) = try await URLSession.shared.data(from: fetchURL)
        let (data, response) = try await URLSession.shared.data(from: fetchURL)
        print("data, response")
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            print("NetworkError.badResponse")
            throw NetworkError.badResponse
        }
        print("after response")
        print(data)
        
        return data

         
    }
    func multiFetch(_ baseURL: [URL]) async throws -> [Data]{
        var returnData = [Data]()
        
        let dispatchGroup = DispatchGroup()

                    
        for i in 0...baseURL.count-1 {
            dispatchGroup.enter()
            let fetchComponents = URLComponents(url: baseURL[i], resolvingAgainstBaseURL: true)
            //fetchComponents?.queryItems = [URLQueryItem(name: "limit", value "386")]
            print("URL = \(String(describing: fetchComponents?.url!))")
            guard let fetchURL = fetchComponents?.url else {
                throw
                NetworkError.badURL
            }
            print("after fetchURL")
            //let (data, response) = try await URLSession.shared.data(from: fetchURL)
            let (data, response) = try await URLSession.shared.data(from: fetchURL)
            print("data, response")
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("NetworkError.badResponse")
                throw NetworkError.badResponse
            }
            print("after response")
            print(data)
            dispatchGroup.leave()
            //dispatchGroup.wait()
            returnData.append(data)
        
        }
            
            print("All return Data = \n \(returnData)")
            return returnData
        

    }
    
    
}
