//
//  NewsTableViewController.swift
//  project2_NewsFeed
//
//  Created by Tenny on 12/10/17.
//  Copyright © 2017 Tenny. All rights reserved.
// 

import UIKit
import CoreLocation
import MapKit


class NewsTableViewController: UITableViewController, CLLocationManagerDelegate, weatherUpdateProtocol {

    var news: newsJSON?
    var selectedArticleIndexPath: Int?
    var headersCount = 1
    var elapsedMin: Int?
    let locationManager = CLLocationManager()
    var latitude: Double?
    var longitude: Double?
    let indicator:UIActivityIndicatorView = UIActivityIndicatorView  (activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    var errorMessage: String?
    var errorMessageRows = 2
    

    func updateWeatherIcon() {
         self.tableView.reloadData()

    }
    
    func willShareNews(url: String) {
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            self.present(vc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        
        locationManager.delegate = self
        News.sharedINstance.delegate = self
        
//        DeleteAllData()
        
        
	   if CLLocationManager.authorizationStatus() == .notDetermined {
            self.locationManager.requestWhenInUseAuthorization()
        }
        
        iconForWeatherConditions()
        self.createCellNibs()
        loadStartAnimating()
        getJsonAndSerialize()
        

    }
    
    //called in the return of the keyword search menu
    @objc func loadList(notification: NSNotification){

        loadStartAnimating()
        getJsonAndSerialize()
        iconForWeatherConditions()
    }
    
    

    override func viewWillAppear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.black
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
       // self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        self.tableView.reloadData()
    }
    
    func blurTheBackground() {
        let blurEffect = UIBlurEffect(style: .light)
        let blurredEffectView = UIVisualEffectView(effect: blurEffect)
        blurredEffectView.frame = self.view.bounds
        blurredEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurredEffectView)
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        if news?.articles.count == 0 {
            return 2
        }
        return (news?.articles.count) ?? 2

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        // MARK: Header row
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.titleCell, for: indexPath) as? TitleTableViewCell
            
            cell?.weekDay.text = weekMonthDayNum().0.uppercased()
            cell?.monthDay.text = weekMonthDayNum().1.uppercased()

            cell?.weatherIcon.image = News.sharedINstance.weatherIcon
            
            return cell!
        }
        // MARK: Top Story in Portrait mode.
        else if indexPath.row == 1 && (UIApplication.shared.statusBarOrientation.isPortrait)
        {

           if news?.articles.count != 0 && self.news != nil
            {
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.topStoryCell, for: indexPath) as? TopStoryTableViewCell
                
                cell?.headlineText.text = self.news?.articles[(indexPath.row - 1)].title
                let imageURL = URL(string: self.news?.articles[(indexPath.row - 1)].urlToImage ?? "")

                cell?.rowID = indexPath.row
                
                cell?.loading.startAnimating()
                
                if imageURL != nil {
                URLSession.shared.dataTask(with: imageURL!) {(data, response, error) in
                    guard let data = data else { return }
                    if error == nil {
                        DispatchQueue.main.async() {
                            if cell?.rowID == indexPath.row {
                                cell?.loading.stopAnimating()
                                if let receivedImg = UIImage(data: data) {
                                    cell?.newsImage.image = receivedImg
                                } else {
                                    cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                                }
                            }
                        }
                    } else {
                       cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                    }
                }.resume()
                
                } else {
                    cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                    cell?.loading.stopAnimating()
                }
                
                let datefromJson = self.news?.articles[(indexPath.row - 1)].publishedAt ?? ""
                var formatedDate = " - "
                if datefromJson != "" {
                    formatedDate = getElapsedTimeFromISO8601(pDate: (datefromJson))
                }
                cell?.minutesAgo.text = "\(formatedDate) ago"
                
                cell?.urlToShare = self.news?.articles[(indexPath.row - 1)].url ?? ""
                
                return cell!
            } else {
                // JSON returned empty
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.emptyCell, for: indexPath) as? SuperUITableViewCell
                //self.errorMessage = "Search returned 0 articles"
                cell?.searchResults.text =  self.errorMessage ?? ""
                return cell!
            }
        }
        // MARK: Top Story Landscape
        else if indexPath.row == 1 && !(UIApplication.shared.statusBarOrientation.isPortrait)
        {
        
            if news?.articles.count != 0 && self.news != nil
            {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.landTopStoryCell, for: indexPath) as? LandTopStoryTableViewCell
            
            cell?.headlineText.text = self.news?.articles[(indexPath.row - 1)].title 
            

            let imageURL = URL(string: self.news?.articles[(indexPath.row - 1)].urlToImage ?? "")
            cell?.rowID = indexPath.row
            
            cell?.loading.startAnimating()
            
            if imageURL != nil {
            URLSession.shared.dataTask(with: imageURL!) {(data, response, error) in
                guard let data = data else { return }
                if error == nil {
                DispatchQueue.main.async() {
                    if cell?.rowID == indexPath.row {
                        cell?.loading.stopAnimating()
                        if let receivedImg = UIImage(data: data) {
                            cell?.newsImage.image = receivedImg
                        } else {
                            cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                        }
                    }
                }
                } else {
                    cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                }
                }.resume()
            } else {
                cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                cell?.loading.stopAnimating()
            }

            
            let datefromJson = self.news?.articles[(indexPath.row - 1)].publishedAt ?? ""
            var formatedDate = " - "
            if datefromJson != "" {
                formatedDate = getElapsedTimeFromISO8601(pDate: (datefromJson))
            }
            cell?.minutesAgo.text = "\(formatedDate) ago"
            cell?.urlToShare = self.news?.articles[(indexPath.row - 1)].url ?? ""
            return cell!
            } else {
                 // JSON returned empty
                let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.emptyCell, for: indexPath) as? SuperUITableViewCell
                cell?.searchResults.text =  self.errorMessage ?? ""
                return cell!
            }
            
        }
        // MARK: Common rows
        else
        {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCells.sideBysideCell, for: indexPath) as? SideBySideTableViewCell

            cell?.headlineText.text = self.news?.articles[(indexPath.row - 1)].title
            
            let imageURL = URL(string: self.news?.articles[(indexPath.row - 1)].urlToImage ?? "")
            cell?.rowID = indexPath.row
            

            cell?.loading.startAnimating()
            
            if imageURL != nil {
                URLSession.shared.dataTask(with: imageURL!) {(data, response, error) in
                    guard let data = data else { return }
                    if error == nil {
                    DispatchQueue.main.async() {
                        if cell?.rowID == indexPath.row {
                            cell?.loading.stopAnimating()
                            if let receivedImg = UIImage(data: data) {
                                cell?.newsImage.image = receivedImg
                            } else {
                                cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                            }
                        }
                    }
                } else {
                     cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                }
                
                }.resume()
            } else {
                cell?.newsImage.image = #imageLiteral(resourceName: "placeholder")
                cell?.loading.stopAnimating()
            }
            
            let datefromJson = self.news?.articles[(indexPath.row - 1)].publishedAt ?? ""
            var formatedDate = " - "
            if datefromJson != "" {
                formatedDate = getElapsedTimeFromISO8601(pDate: (datefromJson))
            }
            cell?.minutesAgo.text = "\(formatedDate) ago"
            cell?.urlToShare = self.news?.articles[(indexPath.row - 1)].url ?? ""

              return cell!
        }
        
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }

    
    // MARK: - Navigation

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !(indexPath.row == 0) {
            self.selectedArticleIndexPath = (indexPath.row - 1)
            self.performSegue(withIdentifier: "newsClick", sender: self)
        }
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        guard let destinationController = segue.destination  as? ArticleViewController else {fatalError("Can't find destination control")}
        destinationController.receivedURL = self.news?.articles[((tableView.indexPathForSelectedRow!.row) - 1)].url
 
        destinationController.receivedFromCell = "Row # \(tableView.indexPathForSelectedRow!.row)"
        
        
    }

    // MARK: Creating Nibs
    func createCellNibs() {
        
        tableView.register(UINib.init(nibName: TableViewCells.titleCellClassName, bundle: nil), forCellReuseIdentifier: TableViewCells.titleCell)
        tableView.register(UINib.init(nibName: TableViewCells.topStoryClassName, bundle: nil), forCellReuseIdentifier: TableViewCells.topStoryCell)
        tableView.register(UINib.init(nibName: TableViewCells.sideBysideClassName, bundle: nil), forCellReuseIdentifier: TableViewCells.sideBysideCell)
        tableView.register(UINib.init(nibName: TableViewCells.landTopStoryClassName, bundle: nil), forCellReuseIdentifier: TableViewCells.landTopStoryCell)
        
    }
    
    func getLocalizationCoordinates() -> (String,String) {
        /*
         if CLLocationManager.locationServicesEnabled() {
         locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
         locationManager.distanceFilter = kCLDistanceFilterNone
         locationManager.startUpdatingLocation()
         //      print("Location:")
         //      print(locationManager.location?.coordinate.latitude.description ?? "No catch")
         //      print(locationManager.location?.coordinate.longitude.hashValue ?? 0)
         latitude = locationManager.location?.coordinate.latitude
         print(latitude ?? 0.0)
         latitude = latitude! + latitude!
         print(latitude ?? 0.0)
         locationManager.stopUpdatingLocation()
         }
         */
        return ("","")
    }
    
    // MARK: Request
    func getJsonAndSerialize() {
         self.news = nil
        if (isConnectedToNetwork()) {
                self.errorMessage = "Loading..."
                News.sharedINstance.sortBy = .publishedAt
            
                let jsonURLString = News.sharedINstance.getHeadlinesQueryURLString()
         
                guard let url = URL(string: jsonURLString) else {return}
            
                URLSession.shared.dataTask(with: url) { (data, response, error) in
                    guard let data = data else {
                        return}
                    
                    
                    if (error == nil ) {
                        do  {
                            
                            self.news = try
                                JSONDecoder().decode(newsJSON.self, from: data)
                            
                            // this says: Let me go back and call me when u have the data.
                            
                            if self.news?.articles.count == 0 || self.news == nil {
                                self.errorMessage = "Search resulted in 0 articles"
                            }
                            
                            DispatchQueue.main.async  {
                                //TODO: this should move to a delegation to separate the MVC
                                    self.tableView.reloadData()
                                    self.indicator.stopAnimating()
                            }
          
                        
                            
                        } catch let jsonErr {
                            print("Error serializing:", jsonErr)
                        }
                        
                    } else {
                        print("Networking Error: \(String(describing: error) )")
                    }
                    }.resume()
        } else {
            self.errorMessage = "No internet connection"
                self.tableView.reloadData()
                self.indicator.stopAnimating()
        }
    }
    
    // MARK: Animation
    func loadStartAnimating() {
        indicator.color = UIColor.black
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0)
        indicator.center = self.view.center
        self.view.addSubview(indicator)
        indicator.bringSubview(toFront: self.view)
        indicator.startAnimating()
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        animationSingleton.sharedInstance.prepareArrowForScroll()
    }
    
    override func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        scrollViewDidEndDecelerating(scrollView)

    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        animationSingleton.sharedInstance.fadeInArrowEndofScroll()
    }
}
