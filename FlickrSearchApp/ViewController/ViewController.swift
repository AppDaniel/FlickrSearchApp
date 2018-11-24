//
//  ViewController.swift
//  FlickrSearchApp
//
//  Created by Daniels Air on 2018-11-17.
//  Copyright © 2018 hemprojekt. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var loadSpinner: UIActivityIndicatorView!

    var ownerName = "" 
    
    @IBOutlet weak var buttonOutlet: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.separatorStyle = .none
        APIManager.shared.dataDel = self
        
        buttonOutlet.layer.cornerRadius = 20
        buttonOutlet.clipsToBounds = true
    }
    
    @IBAction func button(_ sender: Any) {
        dismissKeyboard()
        
        loadSpinner.isHidden = false
        tableView.alpha = 0.5
        
        guard let searchText = searchField.text else { return }
        let searchTextFinal = searchText.trimmingCharacters(in: .whitespaces)
        
        APIManager.shared.fetchDataFormApi(serchText: searchTextFinal) {
            self.reloadAndDisplayPhoto()
        }
    }
    
    fileprivate func reloadAndDisplayPhoto() {
        APIManager.shared.downloadPhotoWhitURL {    
            self.tableView.reloadData()
        }
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

extension ViewController : UITableViewDelegate, UITableViewDataSource, DataDelegate {
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "imageCell", for: indexPath) as? DisplayImageCell else { return UITableViewCell() }
        let row = indexPath.row
        
        DispatchQueue.main.async {
            let array = APIManager.shared.photoImage
            cell.showSearchImage.image = array[row]
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let row = indexPath.row
        let ownerName = APIManager.shared.photoArray[row]
        let owner = ownerName.owner
        loadSpinner.isHidden = false
        tableView.alpha = 0.5
        
        APIManager.shared.getOwnerName(owner: owner, completion: { (ownersName) in
                if ownersName == "" {
                    self.ownerName = "unknown"
                } else {
                    self.ownerName = ownersName
                }
                self.performSegue(withIdentifier: "showInformation", sender: row)
                self.loadSpinner.isHidden = true
                self.tableView.alpha = 1
        })
        
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showInformation" {
            if let restPage = segue.destination as? PhotoInformationViewController {
                if let indx = sender as? Int {
                    
                    let senderInfo = APIManager.shared.photoArray[indx]
                    let senderPhoto = APIManager.shared.photoImage[indx]
                    
                    restPage.owner = self.ownerName
                    restPage.photo = senderPhoto
                    restPage.photoTitle = senderInfo.title
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return APIManager.shared.photoImage.count
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func reloadTalbeView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        self.loadSpinner.isHidden = true
        self.tableView.alpha = 1.0
        
    }
}


