//
//  NewsModel.swift
//  project2_NewsFeed
//
//  Created by Tenny on 12/10/17.
//  Copyright © 2017 Tenny. All rights reserved.
//
// bb: add burger,

import Foundation
import UIKit

struct weatherIcon {
    static let rainy: UIImage = #imageLiteral(resourceName: "rainy")
    static let cloudy: UIImage = #imageLiteral(resourceName: "Sunny")
    static let snowy: UIImage = #imageLiteral(resourceName: "Snowy")
    static let stormy: UIImage = #imageLiteral(resourceName: "Stormy")
 }

struct TableViewCells {
    static let titleCell = "titleCell"
    static let titleCellClassName = "TitleTableViewCell"
    static let topStoryCell = "topStoryCell"
    static let topStoryClassName = "TopStoryTableViewCell"
    static let sideBysideCell = "sideBysideCell"
    static let sideBysideClassName = "SideBySideTableViewCell"
    static let landTopStoryCell = "landTopCell"
    static let landTopStoryClassName = "LandTopStoryTableViewCell"
    static let keywordCell = "keywordCell"
    static let keywordCellClassName = "SearchTableViewCell"
    static let emptyCell = "empty"
    static let emptyCellClassName = "SuperUITableViewCell"
}


struct newsJSON: Decodable {
    var status: String
    var articles: [articles]
}

struct articles: Decodable {
    var source: [String:String?]
    var author: String?
    var title: String?
    var description: String?
    var url: String?
    var urlToImage: String?
    var publishedAt: String?
}

protocol weatherUpdateProtocol{
    func updateWeatherIcon()
    func willShareNews(url: String)
    func blurTheBackground()
}

// detect : https://api.datamuse.com/words?ml=politics
//enum articleCategory: [String] {
//    case business = ["business","biz", , entertainment, gaming, general, health-and-medical, music, politics, science-and-nature, sport, technology
//}


class News {
    static let sharedINstance = News()
    var weatherIcon: UIImage
    private var _headlineEndPoint: String
    private var _everythingEndPoint: String
    
    var delegate: weatherUpdateProtocol?
    var news: newsJSON?

    private var _defaultQuery: String
    private var _key: String
    var keywords: [String]
    var keyword: String
    var category: String
    var sources: [String]
    var sortBy: sortArticleBy
    
    var headlineEndPointDefault: String {
        get {
            return self._headlineEndPoint + self._defaultQuery + self.category + self._key
            //return "http://beta.newsapi.org/v2/top-headlines?q=&category=&language=en&apiKey=c188228c97e74dae82be78d444b65bb9"
        }
    }
    
    var everythingEndPointDefault: String {
        get {
            return self._everythingEndPoint + self._defaultQuery + self._key
            //return "http://beta.newsapi.org/v2/top-headlines?q=&category=&language=en&apiKey=c188228c97e74dae82be78d444b65bb9"
        }
    }
    
    enum sortArticleBy: String {
        case relevancy="relevancy", popularity="popularity",publishedAt="publishedAt"
    }
    
    private init() {
        self.weatherIcon = #imageLiteral(resourceName: "emptyPhoto")
        self._headlineEndPoint = "http://beta.newsapi.org/v2/top-headlines?"
        self._everythingEndPoint = "http://beta.newsapi.org/v2/everything?"
        //http://beta.newsapi.org/v2/top-headlines?&q=Donald%20Trump,North%20Korea&sources=CNN,the-new-york-times&category=Business&language=en&apiKey=c188228c97e74dae82be78d444b65bb9
        self._defaultQuery = "q=&category=&language=en"
        self._key = "&apiKey=c188228c97e74dae82be78d444b65bb9"
        self.keyword = ""
        self.category = ""
        self.sources = [""]
        self.keywords = []
        self.sortBy = News.sortArticleBy.init(rawValue: "publishedAt")!
    }
    
    var getEverythingQueryURLString: () -> String = {
            var q = News.sharedINstance.keyword
        
        if q == "" {
            return "must choose a keyword"
        }
            let src = News.sharedINstance.sources
            let cat = News.sharedINstance.category
            let sortBy = News.sharedINstance.sortBy.rawValue
        
            var urlToQueryAPI = News.sharedINstance._everythingEndPoint
            urlToQueryAPI = urlToQueryAPI + "q=" + q
            urlToQueryAPI = urlToQueryAPI + "&sources=" + (src.isEmpty ? "" : src.joined(separator: ","))
             urlToQueryAPI = urlToQueryAPI + "&sortBy=" + sortBy
             urlToQueryAPI = urlToQueryAPI + "&language=en" 
            urlToQueryAPI = urlToQueryAPI + News.sharedINstance._key
        
            return urlToQueryAPI
    }
    
    var getHeadlinesQueryURLString: () -> String = {
        
        var q = ""

        // this is: 1) Replacing spaces for %20. 2) Separating elements by +. 3) Cutting off the first + (cause this sucks: q=+startups+tech)
        
        // concatenates with + and replaces space occurrences with %20
        q = String((News.sharedINstance.keywords.flatMap({$0 + "+"}).joined()).characters.dropLast()).replacingOccurrences(of: " ", with: "%20")

        let src = News.sharedINstance.sources
        let cat = News.sharedINstance.category
        
        var urlToQueryAPI = News.sharedINstance._headlineEndPoint
        urlToQueryAPI = urlToQueryAPI + "q=" + q
        urlToQueryAPI = urlToQueryAPI + "&sources=" + (src.isEmpty ? "" : src.joined(separator: ","))
        urlToQueryAPI = urlToQueryAPI + "&category=" + cat
        urlToQueryAPI = urlToQueryAPI + "&language=en"
        urlToQueryAPI = urlToQueryAPI + News.sharedINstance._key
        
        
        return urlToQueryAPI
    }
    
    
    func updateWeatherIcon() {
        delegate?.updateWeatherIcon()
    }
    
    func shareNews(urlToShare: String) {
        delegate?.willShareNews(url: urlToShare)
    }
    
    func blurBackground() {
        delegate?.blurTheBackground()
    }
    
}

//MARK: CORE DATA layer




