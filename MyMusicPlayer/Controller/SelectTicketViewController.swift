//
//  SelectTicketViewController.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2020/06/08.
//  Copyright © 2020 葛西　翔太. All rights reserved.
//

import UIKit
import Alamofire
import SwiftSoup

class SelectTicketViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    var searchText = String()
    
    @IBOutlet weak var selectTicketTableView: UITableView!
    
    var liveNameArray = [String]()
    var liveDateArray = [String]()
    var livePlaceArray = [String]()
    var liveImageURLArray = [String]()
    var liveImageArray = [String]()
    
    var image = ""
    var name = ""
    var date = ""
    var place = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectTicketTableView.delegate = self
        selectTicketTableView.dataSource = self
        
        self.overrideUserInterfaceStyle = .dark
        
        getTicketInfo()
    }
    
    
    func getTicketInfo(){
        
        AF.request("https://ticket.rakuten.co.jp/?s=&q=\(searchText)").responseString{response in
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
                    
                    self.selectTicketTableView.reloadData()
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
                    
                    self.selectTicketTableView.reloadData()
                }catch let error{
                    print("Error: \(error)")
                }
            }
        }
    }
    
    
    func moveToSelect(){
        
        performSegue(withIdentifier: "ticketDetail", sender: nil)
        
    }
    
    //値を持たせて遷移
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "ticketDetail"{
            
            //インスタンス化
            let ticketDetail = segue.destination as! TicketDetailViewController
            ticketDetail.image = self.image
            ticketDetail.name = self.name
            ticketDetail.date = self.date
            ticketDetail.place = self.place
            
        }
        
    }
    
    
    

    func numberOfSections(in tableView: UITableView) -> Int {
        
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 150
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return liveNameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ticketCell", for: indexPath)
        
        let liveImageView = cell.contentView.viewWithTag(1) as! UIImageView
        let liveNameLabel = cell.contentView.viewWithTag(2) as! UILabel
        let liveDateLabel = cell.contentView.viewWithTag(3) as! UILabel
        
        if liveImageArray[safe: indexPath.row] != nil{
        liveImageView.sd_setImage(with: URL(string: liveImageArray[indexPath.row]), placeholderImage: UIImage(named: "noimage"), options: .continueInBackground, context: nil, progress: nil, completed: nil)
        }
        liveNameLabel.text = liveNameArray[indexPath.row]
        liveDateLabel.text = liveDateArray[indexPath.row]
        
        print("aaaa")
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        image = liveImageArray[indexPath.row]
        name = liveNameArray[indexPath.row]
        date = liveDateArray[indexPath.row]
        place = livePlaceArray[indexPath.row]
        
        moveToSelect()
    }
    

}

extension Array {
    subscript (safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
