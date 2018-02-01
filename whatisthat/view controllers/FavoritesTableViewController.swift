//
//  FavoritesTableViewController.swift
//  whatisthat
//
//  Created by 靳亚芳 on 11/30/17.
//  Copyright © 2017 yafangjin. All rights reserved.
//

import UIKit

class FavoritesTableViewController: UITableViewController {
    
    var transitTitle: String?
    var favImage: UIImage?
    var favs:[FavModel]!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let persistManager = PersistanceManager()
        self.favs = persistManager.fetchFav()
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return favs.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FavTableViewCell") as! FavoritesTableViewCell
        
        // Configure the cell...
        let fav = favs![indexPath.row]
        
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filename = path.appendingPathComponent((fav.imageName)).path
        
        cell.favName.text = fav.title
        cell.favImage.image = UIImage.init(contentsOfFile: filename)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = favs?[indexPath.row]
        transitTitle = model?.title
        performSegue(withIdentifier: "DetailsSegue", sender: self)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "DetailsSegue"{
            let detVC = segue.destination as! DetailsViewController            
            detVC.transitTitle = transitTitle
        }
    }
}
