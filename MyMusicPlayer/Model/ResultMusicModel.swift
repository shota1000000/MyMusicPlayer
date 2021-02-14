//
//  ResultMusicModel.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2021/02/14.
//  Copyright © 2021 葛西　翔太. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class ResultMusicModel {
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    
    func startParse(keyword:String){
        let urlString = "https://itunes.apple.com/search?term=\(keyword)&country=jp"
        let encodeUrlString:String = urlString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        //AlamoFireを使ってリクエストを投げる
        AF.request(encodeUrlString, method: .get, parameters: nil, encoding: JSONEncoding.default).responseJSON{
            (response) in
            
            switch response.result{
                
            case .success:
                let json:JSON = JSON(response.data as Any)
                //print(json)
                
                let resultCount:Int = json["resultCount"].int!
                
                for i in 0 ..< resultCount{
                    //ジャケット写真
                    var artWorkUrl = json["results"][i]["artworkUrl60"].string
                    //音声URL
                    let previewURL = json["results"][i]["previewUrl"].string
                    //アーティスト名
                    let artistName = json["results"][i]["artistName"].string
                    //曲名
                    let trackCensoredName = json["results"][i]["trackCensoredName"].string
                    
                    if let range = artWorkUrl!.range(of: "60x60bb"){
                        artWorkUrl?.replaceSubrange(range, with: "320x320bb")
                    }
                    
                    if artWorkUrl != nil{
                        self.imageStringArray.append(artWorkUrl!)
                    }
                    if previewURL != nil{
                        self.previewURLArray.append(previewURL!)
                    }
                    if artistName != nil{
                        self.artistNameArray.append(artistName!)
                    }
                    if trackCensoredName != nil{
                        self.musicNameArray.append(trackCensoredName!)
                    }
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}
