//
//  MovieDetailsViewController.swift
//  Flicks
//
//  Created by Gonzalo Maldonado Martinez on 9/15/17.
//  Copyright © 2017 WanderTap. All rights reserved.
//

import UIKit
import AFNetworking

class MovieDetailsViewController: UIViewController {
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var movieTitle: UILabel!
    @IBOutlet weak var releaseDate: UILabel!
    @IBOutlet weak var rating: UILabel!
    @IBOutlet weak var duration: UILabel!
    @IBOutlet weak var overview: UILabel!
    @IBOutlet weak var container: UIView!

    var movie: NSDictionary!
    let inputDateFormatter = DateFormatter()
    let outputDateFormatter = DateFormatter()

    override func viewDidLoad() {
        super.viewDidLoad()

        inputDateFormatter.locale = Locale(identifier: "US_en")
        inputDateFormatter.dateFormat = "yyyy-mm-dd"

        let usDateFormat = DateFormatter.dateFormat(fromTemplate: "MMMM dd, yyyy", options: 0, locale: NSLocale(localeIdentifier: "en-US") as Locale)

        outputDateFormatter.dateFormat = usDateFormat

        var posterPath = movie.value(forKey: "poster_path") as! String
        posterPath.remove(at: posterPath.startIndex)
        let imageUrlString = "https://image.tmdb.org/t/p/w500/\(posterPath)"
        let imageUrl = URL(string: imageUrlString)!
        self.posterImageView.setImageWith(imageUrl)
        self.movieTitle.text = movie["title"] as? String
        let releaseDateString = movie["release_date"] as? String
        let relaseDate = inputDateFormatter.date(from: releaseDateString!)
        self.releaseDate.text = outputDateFormatter.string(from: relaseDate!)
        if let voteAverage = movie["vote_average"] as? Float {
            self.rating.text = String(voteAverage)
        }
        self.overview.text = movie["overview"] as? String
        self.overview.adjustsFontSizeToFitWidth = false
        self.overview.numberOfLines = 0
        self.overview.lineBreakMode = NSLineBreakMode.byTruncatingTail
        self.overview.sizeToFit()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
