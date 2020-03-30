//
//  ViewController.swift
//  covid19
//
//  Created by Daniel on 3/30/20.
//  Copyright © 2020 dk. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet var tableView: UITableView!

    var articles: [Article] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self

        let api = Api.init(apiKey: "8815d577462a4195a64f6f50af3ada08")

        loadData(api)
    }

    private func loadData(_ api: Api) {
        api.get("https://newsapi.org/v2/top-headlines?country=us&apiKey=8815d577462a4195a64f6f50af3ada08&category=health") { articles in
            self.articles = articles
            self.tableView.reloadData()
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let t = UITableViewCell()

        let a = articles[indexPath.row]
        if let source = a.source {
            let text = "\(source.name ?? ""): \(a.title ?? "")"

            t.textLabel?.text = text

        }
        return t
    }

}

class Api {
    /// API key.
    public var apiKey: String

    /**
     Initializes the TMDb API.

     - Parameters apiKey: API key.
     */
    public init(apiKey: String) {
        self.apiKey = apiKey
    }

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

struct Headline: Codable {
    var status: String?
    var totalResults: Int?
    var articles: [Article]
}

struct Article: Codable {
    var title: String?
    var url: String?

    var source: Source?
}

struct Source: Codable {
    var name: String?
}
