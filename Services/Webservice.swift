//
//  Webservice.swift
//  Bus_ride_swift
//
//  Created by Kwok Leung Tse on 18/4/2024.
//

import Foundation



class Webservice {

    
    
    func getBusStop(search: String = "", completion: @escaping (Result<[StopData?], NetworkError>) -> Void) {
        
        guard let busURL = URL(string: K.Urls.stopURL) else {
            print("badURL")
            completion(.failure(.badURL))
            return
        }
        //        URLSession.shared.dataTask(with: moviesURL) completionHandler: (Data?, URLResponse?, Error?)-> Void)
        URLSession.shared.dataTask(with: busURL) { data, response, error in
            guard let data = data, error == nil else {
                print("noData")
                completion(.failure(.noData))
                return
            }
            print("Data = \(data)")
            let stopResponse = try? JSONDecoder ().decode(BusStopData.self, from: data)
            if let stopResponse = stopResponse {
                print("success=\(stopResponse.data)")
                completion(.success(stopResponse.data))
            } else {
                print("decodingError")
                completion(.failure(.decodingError))
            }
        }.resume()
    }
    
}
