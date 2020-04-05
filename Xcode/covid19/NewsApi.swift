//
//  NewsApi.swift
//  covid19
//
//  Created by Daniel on 3/30/20.
//  Copyright © 2020 dk. All rights reserved.
//

import Foundation

class NewsApi {
    public func get(_ urlString: String, completion: @escaping ([Article]) -> Void) {
        guard let url = URL.init(string: urlString) else {

            return
        }

        let session = URLSession.shared
        let task = session.dataTask(with: url) { data, _, error in
            if let error = error {
                //                DispatchQueue.main.async {
                //                    completion(.failure(error))
                //                }

                print(error)
                return
            }

            guard let unwrapped = data else {
                print("error unwrapping data")
                //                DispatchQueue.main.async {
                //                    completion(.failure(NetError.data))
                //                }

                return
            }

            if let result = try? JSONDecoder().decode(Headline.self, from: unwrapped) {
                DispatchQueue.main.async {
                    completion(result.articles)
                }
            }
            //            } else {
            //                DispatchQueue.main.async {
            //                    completion(.failure(NetError.json))
            //                }
            //            }
        }

        task.resume()
    }
}
