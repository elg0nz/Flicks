//
//  MoviesViewController.swift
//  Flicks
//
//  Created by Gonzalo Maldonado Martinez on 9/14/17.
//  Copyright © 2017 WanderTap. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftSpinner
import SystemConfiguration

let DEFAULT_ROW_HEIGHT = CGFloat(178)
class MoviesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var networkStatusBar: UILabel!

    var movies: [NSDictionary] = []
    var endpoint: String = "now_playing"


    override func viewDidLoad() {
        super.viewDidLoad()
        hideNetworkStatusBar()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = DEFAULT_ROW_HEIGHT

        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(_:)), for: UIControlEvents.valueChanged)
        refreshControl.tintColor = UIColor.clear
        tableView.insertSubview(refreshControl, at: 0)
        makeNetworkRequest(refreshControl: nil)
    }

    func refreshControlAction(_ refreshControl: UIRefreshControl) {
        makeNetworkRequest(refreshControl: refreshControl)
    }

    func hideNetworkStatusBar() {
        self.networkStatusBar.isHidden = true
        self.networkStatusBar.frame = CGRect()
    }

    func showNetworkStatusBar() {
        self.networkStatusBar.isHidden = false
        self.networkStatusBar.frame = CGRect(x: 0, y: 0, width: self.tableView.frame.width, height: DEFAULT_ROW_HEIGHT / 2)
    }

    func makeNetworkRequest(refreshControl : UIRefreshControl?) {
        SwiftSpinner.show("FFFinding Flicks")
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = URL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        var request = URLRequest(url: url!)
        request.timeoutInterval = 5
        request.cachePolicy = .reloadIgnoringLocalCacheData
        let session = URLSession(
            configuration: URLSessionConfiguration.default,
            delegate:nil,
            delegateQueue:OperationQueue.main
        )

        let task : URLSessionDataTask = session.dataTask(
            with: request as URLRequest,
            completionHandler: { (data, response, error) in
                if (error != nil) {
                    self.showNetworkStatusBar()
                }

                if let data = data {
                    if let responseDictionary = try! JSONSerialization.jsonObject(
                        with: data, options:[]) as? NSDictionary {

                        self.movies = responseDictionary["results"] as! [NSDictionary]
                        self.hideNetworkStatusBar()
                        refreshControl?.endRefreshing()
                        self.tableView.reloadData()
                    }
                }
                SwiftSpinner.hide()
        });
        task.resume()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MoviesTableViewCell") as! MoviesTableViewCell
        let result = self.movies[indexPath.row]
        if let title = result.value(forKey: "original_title") {
            cell.movieTitle?.text = title as? String
        }
        if let overview = result.value(forKey: "overview") {
            cell.movieOverview.text = overview as? String
            cell.movieOverview.adjustsFontSizeToFitWidth = false
            cell.movieOverview.lineBreakMode = NSLineBreakMode.byTruncatingTail
            cell.movieOverview.numberOfLines = 6
            cell.movieOverview.sizeToFit()
        }

        var posterPath = result.value(forKey: "poster_path") as! String
        posterPath.remove(at: posterPath.startIndex)
        let imageUrlString = "https://image.tmdb.org/t/p/w500/\(posterPath)"
        if let imageUrl = URL(string: imageUrlString) {
            cell.moviePosterImageView.setImageWith(imageUrl)
        }

        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as? MoviesTableViewCell
        let indexPath = tableView.indexPath(for: cell!)
        let movie = movies[indexPath!.row]
        let detailViewController = segue.destination as! MovieDetailsViewController
        detailViewController.movie = movie
    }
}
