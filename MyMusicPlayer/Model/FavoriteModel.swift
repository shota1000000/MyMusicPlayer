//
//  FavoriteModel.swift
//  MyMusicPlayer
//
//  Created by 葛西　翔太 on 2021/02/14.
//  Copyright © 2021 葛西　翔太. All rights reserved.
//

import Foundation
import Firebase

class FavoriteModel {
    var artistNameArray = [String]()
    var musicNameArray = [String]()
    var previewURLArray = [String]()
    var imageStringArray = [String]()
    var messageStringArray = [String]()
    var autoIDArray = [String]()
    let ref = Database.database().reference()
    
    func loadDataFirebase(){
        ref.child("Users").observeSingleEvent(of: .value){(snap, error) in
            let snapdata = snap.value as? [String:NSDictionary]
            if snapdata == nil {
                return
            }
            //snapdata!.keys : 階層
            //key : 階層
            for key in snapdata!.keys.sorted(){
                let snap = snapdata![key]
                if let imageName = snap!["image"] as? String{
                    self.imageStringArray.append(imageName)
                }
                if let artistName = snap!["artist"] as? String{
                    self.artistNameArray.append(artistName)
                }
                if let musicName = snap!["music"] as? String{
                    self.musicNameArray.append(musicName)
                }
                if let previewName = snap!["preview"] as? String{
                    self.previewURLArray.append(previewName)
                }
                if let message = snap!["message"] as? String{
                    self.messageStringArray.append(message)
                }
                if let autoID = snap!["autoID"] as? String{
                    self.autoIDArray.append(autoID)
                }
            }
        }
    }
}
