//
//  TicketModel.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2021/02/14.
//  Copyright © 2021 葛西　翔太. All rights reserved.
//

import Foundation
import Alamofire
import SwiftSoup

class TicketModel {
    var liveNameArray = [String]()
    var liveDateArray = [String]()
    var livePlaceArray = [String]()
    var liveImageURLArray = [String]()
    var liveImageArray = [String]()
    
    func getTicketInfo(keyword:String){
        AF.request("https://ticket.rakuten.co.jp/?s=&q=\(keyword)").responseString{response in
            guard let html = response.value else{
                return
            }
            do{
                let doc: Document = try SwiftSoup.parse(html)
                let liveNameCount = try doc.select("div.list-tpl-title h2 a[href][style]").count
                
                for count in 0..<liveNameCount{
                    let liveName: Element = try doc.select("div.list-tpl-title h2 a[href][style]").get(count)
                    let liveDate: Element = try doc.select("div.list-tpl-title div.list-tpl-cst-fld-sec-1").get(count)
                    let livePlace: Element = try doc.select("div.list-tpl-title div.list-tpl-cst-fld-sec-2").get(count)
                    let liveImageURL: String = try liveName.attr("href")
                    
                    self.liveNameArray.append(try! liveName.text())
                    self.liveDateArray.append(try! liveDate.text())
                    self.livePlaceArray.append(try! livePlace.text())
                    self.liveImageURLArray.append(try! liveImageURL)
                    print(self.liveNameArray[count])
                    print(self.liveDateArray[count])
                    print(self.livePlaceArray[count])
                    print(self.liveImageURLArray[count])
                    
                }
            }catch let error{
                print("Error: \(error)")
            }
            self.getTicketImage()
        }
    }
    
    func getTicketImage(){
        for count in 0..<liveImageURLArray.count{
            AF.request(liveImageURLArray[count]).responseString{response in
                guard let html = response.value else{
                    return
                }
                do{
                    let doc: Document = try SwiftSoup.parse(html)
                    if try! doc.select("div.sow-image-container img.so-widget-image").count == 2{
                        let liveImagePath: Element = try! doc.select("div.sow-image-container img.so-widget-image").get(1)
                        let liveImage: String =  try! liveImagePath.attr("src")
                        self.liveImageArray.append(liveImage)
                    }else{
                        self.liveImageArray.append("noimage")
                    }
                    print(self.liveImageArray)
                }catch let error{
                    print("Error: \(error)")
                }
            }
        }
    }
}
