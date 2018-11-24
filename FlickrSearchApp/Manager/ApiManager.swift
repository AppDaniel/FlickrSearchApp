//
//  ApiManager.swift
//  FlickrSearchApp
//
//  Created by Daniels Air on 2018-11-17.
//  Copyright © 2018 hemprojekt. All rights reserved.
//

import UIKit

protocol DataDelegate {
    func reloadTalbeView()
}

class APIManager {
    
    var dataDel: DataDelegate?
    
    struct APIPhoto {
        var id = ""
        var owner = ""
        var secret = ""
        var server = ""
        var farm = 0
        var title = ""
    }

    var photoArray: [APIPhoto] = []
    var photoImage: [UIImage] = []
    static var shared = APIManager()
    
    fileprivate let apiKey = ApiKey.apiKey
    fileprivate let url = "https://api.flickr.com/services/rest/?method=flickr.photos.search"
    
    func fetchDataFormApi(serchText: String, completion: @escaping () -> () ) {
        let dataSession = URLSession.shared
        photoArray.removeAll()
        guard let decodeSerchText: String = serchText.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed) else { return }
        if let readURL = URL(string: "\(url)&api_key=\(apiKey)&text=\(decodeSerchText)&format=json&nojsoncallback=1") {
            
            let fetchData = URLRequest(url: readURL)
            
            let dataFetch = dataSession.dataTask(with: fetchData, completionHandler: {
                (data, response, error) -> () in
                
                do {
                    guard let data = data,
                        let parsedData = try JSONSerialization.jsonObject(with: data) as? NSDictionary,
                        let currentCon = parsedData.object(forKey: "photos") as? NSDictionary else { return }
                    
                    guard let currentPhotos = currentCon.object(forKey: "photo") as? NSArray else { return }
                    
                    for currentPhoto in currentPhotos {
                        
                        if let photo = currentPhoto as? NSDictionary {
                            
                            guard let currentPhotoID = photo["id"] as? String,
                                let currentOwner = photo["owner"] as? String,
                                let currentSecret = photo["secret"] as? String,
                                let currentServer = photo["server"] as? String,
                                let currentFarm = photo["farm"] as? Int,
                                let currentTitle = photo["title"] as? String
                                else { return }
                            
                            let photoForUrl = APIPhoto(id: currentPhotoID, owner: currentOwner, secret: currentSecret, server: currentServer, farm: currentFarm, title: currentTitle)
                            self.photoArray.append(photoForUrl)
                            
                            
                            
                        }
                    }
                    completion()
                    
                } catch {
                    print(error.localizedDescription)
                }
                
            })
            dataFetch.resume()
            
        }
    }
    
    func downloadPhotoWhitURL(completion: @escaping () -> ()) {
        
        photoImage.removeAll()
        DispatchQueue.main.async {
            var photoUrlArray: [String] = []
            
            for photo in self.photoArray {
                
                let photoID = photo.id
                let photoFarm = photo.farm
                let photoServer = photo.server
                let photoSecret = photo.secret
                
                let urlsForPhotos =  "https://farm\(photoFarm).staticflickr.com/\(photoServer)/\(photoID)_\(photoSecret)_m.jpg"
                
                photoUrlArray.append(urlsForPhotos)
            }
            
            for url in photoUrlArray {
                guard let photos = URL(string: url) else { return }
                
                do {
                    let photoData = try Data(contentsOf: photos)
                    guard let photo = UIImage(data: photoData) else { continue }
                    self.photoImage.append(photo)
                    
                    
                } catch {
                    print(error.localizedDescription)
                }
            }
            completion()
            self.dataDel?.reloadTalbeView()
        }
    }
    
    func getOwnerName(owner: String, completion: @escaping (String) -> ()) {
        let dataSession = URLSession.shared
        
        if let urlForOwner = URL(string: "https://api.flickr.com/services/rest/?method=flickr.people.getInfo&api_key=\(apiKey)&user_id=\(owner)&format=json&nojsoncallback=1") {
            
            let fetchData = URLRequest(url: urlForOwner)
            
            let dataFetch = dataSession.dataTask(with: fetchData, completionHandler: {
                (data, response, error) -> () in
                DispatchQueue.main.async {
                    do {
                        guard let data = data,
                            let parsedData = try JSONSerialization.jsonObject(with: data) as? NSDictionary,
                            let currentOwner = parsedData.object(forKey: "person") as? NSDictionary else { return }
                        
                        guard let owner = currentOwner.object(forKey: "realname") as? NSDictionary else { return }
                        guard let ownerName = owner.object(forKey: "_content") as? String else { return }
                        
                        completion(ownerName)
                    } catch {
                        print(error.localizedDescription)
                    }
                }
            })
            dataFetch.resume()
        }
        
    }
}
