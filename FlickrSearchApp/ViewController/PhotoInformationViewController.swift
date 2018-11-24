//
//  PhotoInformationViewController.swift
//  FlickrSearchApp
//
//  Created by Daniels Air on 2018-11-18.
//  Copyright © 2018 hemprojekt. All rights reserved.
//

import UIKit

class PhotoInformationViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var ownerLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    var owner = ""
    var photo: UIImage?
    var photoTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imageView.image = photo
        titleLabel.text = photoTitle
        ownerLabel.text = "Photo by: \(owner)"
    }
}
