//
//  feedVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 22.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import Firebase
import SDWebImage

class feedVC: UITableViewController {

        var netService = NetworkingService()
    
    var storageRef: FIRStorageReference! {
        
        return FIRStorage.storage().reference()
    }
    
    
    var databaseRef: FIRDatabaseReference! {
        
        return FIRDatabase.database().reference()
    }
    
    
    // UI objects
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    var refresher = UIRefreshControl()
    
    // arrays to hold server data
    var usernameArray = [String]()
    var avaArray = [PFFile]()
    var dateArray = [Date?]()
    var picArray = [PFFile]()
    var titleArray = [String]()
    var uuidArray = [String]()
    
    var followArray = [String]()
    
    var usersArray = [User]()
    
    var postsArray = [Post]()
    var posts = [Post]()
    var following = [String]()
   
    // page size
    var page : Int = 10
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // title at the top
        self.navigationItem.title = "FEED"
        
        // automatic row height - dynamic cell
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 450
        
        // pull to refresh
        refresher.addTarget(self, action: #selector(feedVC.loadPosts), for: UIControlEvents.valueChanged)
        tableView.addSubview(refresher)
        
        // receive notification from postsCell if picture is liked, to update tableView
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.refresh), name: NSNotification.Name(rawValue: "liked"), object: nil)
        
        // indicator's x(horizontal) center
        indicator.center.x = tableView.center.x
        
        // receive notification from uploadVC
        NotificationCenter.default.addObserver(self, selector: #selector(feedVC.uploaded(_:)), name: NSNotification.Name(rawValue: "uploaded"), object: nil)
        
        // calling function to load posts
       loadPosts()
    }
    
    
    // refreshign function after like to update degit
    func refresh() {
        tableView.reloadData()
    }
    
    
    // reloading func with posts  after received notification
    func uploaded(_ notification:Notification) {
        loadPosts()
    }
    
    
    // load posts
 
    

        func loadPosts(){
            
          print("entras")
            //  netService.fetchAllPosts {(posts) in
            //let currentUser = FIRAuth.auth()!.currentUser!
            
           // self.postsArray.removeAll(keepingCapacity: false)
            

            
            self.netService.fetchPosts2 {(Post) in
              print("post desde aqui")
                
                print(self.postsArray.count)
                self.postsArray = Post
                
                  print (self.postsArray)
                //self.postsArray.sort(by: { (post1, post2) -> Bool in
               ///     Int(post1.postDate) > Int(post2.postDate)
               // })
                
                self.tableView.reloadData()
                self.refresher.endRefreshing()
            }

            
         
                  }
                   //     self.tableView.reloadData()
               //         self.refresher.endRefreshing()
        //
    
    
    // scrolled down
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= scrollView.contentSize.height - self.view.frame.size.height * 2 {
            //loadMore()
        }
    }
    
    
    // pagination/
    /*
    func loadMore() {
        
        // if posts on the server are more than shown
        if page <= uuidArray.count {
            
            // start animating indicator
            indicator.startAnimating()
            
            // increase page size to load +10 posts
            page = page + 10
            
            // STEP 1. Find posts realted to people who we are following
            let followQuery = PFQuery(className: "follow")
            followQuery.whereKey("follower", equalTo: PFUser.current()!.username!)
            followQuery.findObjectsInBackground (block: { (objects, error) -> Void in
                if error == nil {
                    
                    // clean up
                    self.followArray.removeAll(keepingCapacity: false)
                    
                    // find related objects
                    for object in objects! {
                        self.followArray.append(object.object(forKey: "following") as! String)
                    }
                    
                    // append current user to see own posts in feed
                    self.followArray.append(PFUser.current()!.username!)
                    
                    // STEP 2. Find posts made by people appended to followArray
                    let query = PFQuery(className: "posts")
                    query.whereKey("username", containedIn: self.followArray)
                    query.limit = self.page
                    query.addDescendingOrder("createdAt")
                    query.findObjectsInBackground(block: { (objects, error) -> Void in
                        if error == nil {
                            
                            // clean up
                            self.usernameArray.removeAll(keepingCapacity: false)
                            self.avaArray.removeAll(keepingCapacity: false)
                            self.dateArray.removeAll(keepingCapacity: false)
                            self.picArray.removeAll(keepingCapacity: false)
                            self.titleArray.removeAll(keepingCapacity: false)
                            self.uuidArray.removeAll(keepingCapacity: false)
                            
                            // find related objects
                            for object in objects! {
                                self.usernameArray.append(object.object(forKey: "username") as! String)
                                self.avaArray.append(object.object(forKey: "ava") as! PFFile)
                                self.dateArray.append(object.createdAt)
                                self.picArray.append(object.object(forKey: "pic") as! PFFile)
                                self.titleArray.append(object.object(forKey: "title") as! String)
                                self.uuidArray.append(object.object(forKey: "uuid") as! String)
                            }
                            
                            // reload tableView & stop animating indicator
                            self.tableView.reloadData()
                            self.indicator.stopAnimating()
                            
                        } else {
                            print(error!.localizedDescription)
                        }
                    })
                } else {
                    print(error!.localizedDescription)
                }
            })
            
        }
        
    }
*/

    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print("cantidad row \(postsArray.count)")
        return postsArray.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // define cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! postCell
        
        // connect objects with our information from arrays
        cell.usernameBtn.setTitle(postsArray[indexPath.row].username, for: UIControlState())
        cell.usernameBtn.sizeToFit()
        cell.uuidLbl.text = postsArray[indexPath.row].userId!
        cell.titleLbl.text! = postsArray[indexPath.row].username
        print("dato necesario: \(cell.titleLbl.text!)")
        cell.titleLbl.sizeToFit()
        
        GlobalVariable.userName = postsArray[indexPath.row].username
        
          cell.picImg.sd_setImage(with: URL(string: self.postsArray[indexPath.row].postImageURL), placeholderImage: UIImage(named: "default-thumbnail"))
        
        
        let fromDate = NSDate(timeIntervalSince1970: TimeInterval(self.postsArray[indexPath.row].postDate))
        let toDate = NSDate()
        
        let differenceOfDate = Calendar.current.dateComponents([.second,.minute,.hour,.day,.weekOfMonth], from: fromDate as Date, to: toDate as Date)
        if differenceOfDate.second! <= 0 {
            cell.dateLbl.text = "now"
        } else if differenceOfDate.second! > 0 && differenceOfDate.minute! == 0 {
            cell.dateLbl.text = "\(differenceOfDate.second!)secs."
            
        }else if differenceOfDate.minute! > 0 && differenceOfDate.hour! == 0 {
            cell.dateLbl.text = "\(differenceOfDate.minute!)mins."
            
        }else if differenceOfDate.hour! > 0 && differenceOfDate.day! == 0 {
            cell.dateLbl.text = "\(differenceOfDate.hour!)hrs."
            
        }else if differenceOfDate.day! > 0 && differenceOfDate.weekOfMonth! == 0 {
            cell.dateLbl.text = "\(differenceOfDate.day!)dys."
            
        }else if differenceOfDate.weekOfMonth! > 0 {
            cell.dateLbl.text  = "\(differenceOfDate.weekOfMonth!)wks."
            
        }
   
        /*
        
        // manipulate like button depending on did user like it or not
        let didLike = PFQuery(className: "likes")
        didLike.whereKey("by", equalTo: PFUser.current()!.username!)
        didLike.whereKey("to", equalTo: cell.uuidLbl.text!)
        didLike.countObjectsInBackground { (count, error) -> Void in
            // if no any likes are found, else found likes
            if count == 0 {
                cell.likeBtn.setTitle("unlike", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "unlike.png"), for: UIControlState())
            } else {
                cell.likeBtn.setTitle("like", for: UIControlState())
                cell.likeBtn.setBackgroundImage(UIImage(named: "like.png"), for: UIControlState())
            }
        }
        
        // count total likes of shown post
        let countLikes = PFQuery(className: "likes")
        countLikes.whereKey("to", equalTo: cell.uuidLbl.text!)
        countLikes.countObjectsInBackground { (count, error) -> Void in
            cell.likeLbl.text = "\(count)"
        }
        
        
        // asign index
        cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        cell.commentBtn.layer.setValue(indexPath, forKey: "index")
        cell.moreBtn.layer.setValue(indexPath, forKey: "index")
        
        
        // @mention is tapped
        cell.titleLbl.userHandleLinkTapHandler = { label, handle, rang in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            
            // if tapped on @currentUser go home, else go guest
            if mention.lowercased() == PFUser.current()?.username {
                let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
                self.navigationController?.pushViewController(home, animated: true)
            } else {
                guestname.append(mention.lowercased())
                let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
                self.navigationController?.pushViewController(guest, animated: true)
            }
        }
        
        // #hashtag is tapped
        cell.titleLbl.hashtagLinkTapHandler = { label, handle, range in
            var mention = handle
            mention = String(mention.characters.dropFirst())
            hashtag.append(mention.lowercased())
            let hashvc = self.storyboard?.instantiateViewController(withIdentifier: "hashtagsVC") as! hashtagsVC
            self.navigationController?.pushViewController(hashvc, animated: true)
        }
        */
        
           cell.usernameBtn.layer.setValue(indexPath, forKey: "index")
        
        return cell
    }
    
    
    // clicked username button
   // @IBAction func usernameBtn_click(_ sender: AnyObject) {
      //  let currentUser = FIRAuth.auth()!.currentUser!
        
 
        // call index of button
     //   let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
      //  let cell = tableView.cellForRow(at: i) as! postCell
        
       // print( cell.titleLbl.text)
       
        // if user tapped on himself go home, else go guest
        
      //  print(currentUser.displayName)
      /*  print("mira:\(cell.usernameBtn.titleLabel?.text)")
        
        if postsArray[indexPath.row].username == currentUser.displayName! {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
           // guestname.append(cell.usernameBtn.titleLabel!.text!)
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }*/
        
  //  }
    
    @IBAction func usernameBtn_click(_ sender: AnyObject) {
         let currentUser = FIRAuth.auth()!.currentUser!
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // if user tapped on himself go home, else go guest
        
        let usernameLabel = cell.usernameBtn.titleLabel?.text!
        print("postusername titleLabel es igual :\(usernameLabel!)")
        
              print("postusername curriend es igual :\(currentUser.displayName!)")
        
        if usernameLabel! == currentUser.displayName! {
            let home = self.storyboard?.instantiateViewController(withIdentifier: "homeVC") as! homeVC
            self.navigationController?.pushViewController(home, animated: true)
        } else {
            guestname.append(cell.usernameBtn.titleLabel!.text!)
             guestid.append(cell.uuidLbl.text!)
            
            let guest = self.storyboard?.instantiateViewController(withIdentifier: "guestVC") as! guestVC
            self.navigationController?.pushViewController(guest, animated: true)
        }
        
    }
    
    
    
    // clicked comment button
    @IBAction func commentBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell data
        let cell = tableView.cellForRow(at: i) as! postCell
        
        // send related data to global variables
        commentuuid.append(cell.uuidLbl.text!)
        commentowner.append(cell.usernameBtn.titleLabel!.text!)
        
        // go to comments. present vc
        let comment = self.storyboard?.instantiateViewController(withIdentifier: "commentVC") as! commentVC
        self.navigationController?.pushViewController(comment, animated: true)
    }
    
    
    // clicked more button
    @IBAction func moreBtn_click(_ sender: AnyObject) {
        
        // call index of button
        let i = sender.layer.value(forKey: "index") as! IndexPath
        
        // call cell to call further cell date
        let cell = tableView.cellForRow(at: i) as! postCell
        
        
        // DELET ACTION
        let delete = UIAlertAction(title: "Delete", style: .default) { (UIAlertAction) -> Void in
            
            // STEP 1. Delete row from tableView
            self.usernameArray.remove(at: i.row)
            self.avaArray.remove(at: i.row)
            self.dateArray.remove(at: i.row)
            self.picArray.remove(at: i.row)
            self.titleArray.remove(at: i.row)
            self.uuidArray.remove(at: i.row)
            
            // STEP 2. Delete post from server
            let postQuery = PFQuery(className: "posts")
            postQuery.whereKey("uuid", equalTo: cell.uuidLbl.text!)
            postQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteInBackground(block: { (success, error) -> Void in
                            if success {
                                
                                // send notification to rootViewController to update shown posts
                                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                                
                                // push back
                                _ = self.navigationController?.popViewController(animated: true)
                            } else {
                                print(error!.localizedDescription)
                            }
                        })
                    }
                } else {
                    print(error?.localizedDescription ?? String())
                }
            })
            
            // STEP 2. Delete likes of post from server
            let likeQuery = PFQuery(className: "likes")
            likeQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            likeQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // STEP 3. Delete comments of post from server
            let commentQuery = PFQuery(className: "comments")
            commentQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            commentQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
            
            // STEP 4. Delete hashtags of post from server
            let hashtagQuery = PFQuery(className: "hashtags")
            hashtagQuery.whereKey("to", equalTo: cell.uuidLbl.text!)
            hashtagQuery.findObjectsInBackground(block: { (objects, error) -> Void in
                if error == nil {
                    for object in objects! {
                        object.deleteEventually()
                    }
                }
            })
        }
        
        
        // COMPLAIN ACTION
        let complain = UIAlertAction(title: "Complain", style: .default) { (UIAlertAction) -> Void in
            
            // send complain to server
            let complainObj = PFObject(className: "complain")
            complainObj["by"] = PFUser.current()?.username
            complainObj["to"] = cell.uuidLbl.text
            complainObj["owner"] = cell.usernameBtn.titleLabel?.text
            complainObj.saveInBackground(block: { (success, error) -> Void in
                if success {
                    self.alert("Complain has been made successfully", message: "Thank You! We will consider your complain")
                } else {
                    self.alert("ERROR", message: error!.localizedDescription)
                }
            })
        }
        
        // CANCEL ACTION
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        // create menu controller
        let menu = UIAlertController(title: "Menu", message: nil, preferredStyle: .actionSheet)
        
        
        // if post belongs to user, he can delete post, else he can't
        
           let currentUser = FIRAuth.auth()!.currentUser!
        
        if cell.usernameBtn.titleLabel?.text ==   currentUser.displayName{
            menu.addAction(delete)
            menu.addAction(cancel)
        } else {
            menu.addAction(complain)
            menu.addAction(cancel)
        }
        
        // show menu
        self.present(menu, animated: true, completion: nil)
    }
    
    
    // alert action
    func alert (_ title: String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        let ok = UIAlertAction(title: "OK", style: .cancel, handler: nil)
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
    struct GlobalVariable{
        static var myStruct = [String]();
        static var UserId = String();
        static var ImagenPic = UIImage();
        static var ImagenUser = UIImage();
        static var ImagenUserUrl = String();
        static var userName = String();
        static var Fullname = String();
        
    }
}
