//
//  uploadVC.swift
//  Instragram
//
//  Created by Ahmad Idigov on 15.12.15.
//  Copyright © 2015 Akhmed Idigov. All rights reserved.
//

import UIKit
import Parse
import Firebase

class uploadVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var netService = NetworkingService()

    // UI objects
    @IBOutlet weak var picImg: UIImageView!
    @IBOutlet weak var titleTxt: UITextView!
    @IBOutlet weak var publishBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    
    // default func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable publish btn
        publishBtn.isEnabled = false
        publishBtn.backgroundColor = .lightGray
        
        // hide remove button
        removeBtn.isHidden = true
        
        // standart UI containt
        picImg.image = UIImage(named: "pbg.jpg")
        
        // hide kyeboard tap
        let hideTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.hideKeyboardTap))
        hideTap.numberOfTapsRequired = 1
        self.view.isUserInteractionEnabled = true
        self.view.addGestureRecognizer(hideTap)
        
        // select image tap
        let picTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.selectImg))
        picTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(picTap)
    }
    
    
    // preload func
    override func viewWillAppear(_ animated: Bool) {
        // call alignment function
        alignment()
    }
    
    
    // hide kyeboard function
    func hideKeyboardTap() {
        self.view.endEditing(true)
    }
    
    
    // func to cal pickerViewController
    func selectImg() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
    // hold selected image in picImg object and dissmiss PickerController()
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picImg.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
        
        // enable publish btn
        publishBtn.isEnabled = true
        publishBtn.backgroundColor = UIColor(red: 52.0/255.0, green: 169.0/255.0, blue: 255.0/255.0, alpha: 1)
        
        // unhide remove button
        removeBtn.isHidden = false
        
        // implement second tap for zooming image
        let zoomTap = UITapGestureRecognizer(target: self, action: #selector(uploadVC.zoomImg))
        zoomTap.numberOfTapsRequired = 1
        picImg.isUserInteractionEnabled = true
        picImg.addGestureRecognizer(zoomTap)
    }
    
    
    // zooming in / out function
    func zoomImg() {
        
        // define frame of zoomed image
        let zoomed = CGRect(x: 0, y: self.view.center.y - self.view.center.x - self.tabBarController!.tabBar.frame.size.height * 1.5, width: self.view.frame.size.width, height: self.view.frame.size.width)
        
        // frame of unzoomed (small) image
        let unzoomed = CGRect(x: 15, y: 15, width: self.view.frame.size.width / 4.5, height: self.view.frame.size.width / 4.5)
        
        // if picture is unzoomed, zoom it
        if picImg.frame == unzoomed {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = zoomed
                
                // hide objects from background
                self.view.backgroundColor = .black
                self.titleTxt.alpha = 0
                self.publishBtn.alpha = 0
                self.removeBtn.alpha = 0
            })
            
        // to unzoom
        } else {
            
            // with animation
            UIView.animate(withDuration: 0.3, animations: { () -> Void in
                // resize image frame
                self.picImg.frame = unzoomed
                
                // unhide objects from background
                self.view.backgroundColor = .white
                self.titleTxt.alpha = 1
                self.publishBtn.alpha = 1
                self.removeBtn.alpha = 1
            })
        }
        
    }
    
    
    // alignment
    func alignment() {
        
        let width = self.view.frame.size.width
        let height = self.view.frame.size.height
        
        picImg.frame = CGRect(x: 15, y: 15, width: width / 4.5, height: width / 4.5)
        titleTxt.frame = CGRect(x: picImg.frame.size.width + 25, y: picImg.frame.origin.y, width: width / 1.488, height: picImg.frame.size.height)
        publishBtn.frame = CGRect(x: 0, y: height / 1.09, width: width, height: width / 8)
        removeBtn.frame = CGRect(x: picImg.frame.origin.x, y: picImg.frame.origin.y + picImg.frame.size.height, width: picImg.frame.size.width, height: 20)
    }
    
    
    // clicked publish button
    @IBAction func publishBtn_clicked(_ sender: AnyObject) {
        
        // dissmiss keyboard
        self.view.endEditing(true)

        
        let postDate = NSDate().timeIntervalSince1970 as NSNumber
        let postText = titleTxt.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
       let postId = NSUUID().uuidString
        if let imageData = UIImageJPEGRepresentation(picImg.image!, CGFloat(0.35)){
            
            self.netService.uploadImageToFirebase(postId: postId, imageData: imageData, completion: { (url) in
                
                let post = Post(postId: postId, userId: FIRAuth.auth()!.currentUser!.uid, postText: postText, postImageURL: String(describing:url), postDate: postDate, type:"IMAGE")
                self.netService.savePostToDB(post: post, completed: {
                    self.dismiss(animated: true, completion: nil)
                })
                
                
                
            })
            
            
        }
        
  
    
        // send #hashtag to server
        let words:[String] = titleTxt.text!.components(separatedBy: CharacterSet.whitespacesAndNewlines)
        
        
      
        
        
        // define taged word
        for var word in words {
            
            // save #hasthag in server
            if word.hasPrefix("#") {
                
                // cut symbold
                word = word.trimmingCharacters(in: CharacterSet.punctuationCharacters)
                word = word.trimmingCharacters(in: CharacterSet.symbols)
                
            /*  let hashtagObj = PFObject(className: "hashtags")
                hashtagObj["to"] = "\(PFUser.current()!.username!) \(uuid)"
                hashtagObj["by"] = PFUser.current()?.username
                hashtagObj["hashtag"] = word.lowercased()
                hashtagObj["comment"] = titleTxt.text
             */
                let by  = FIRAuth.auth()!.currentUser!.displayName
                let too  = FIRAuth.auth()!.currentUser!.displayName
                let hashtag = word.lowercased()
                let comment = titleTxt.text
                                let imageData = UIImageJPEGRepresentation(picImg.image!, CGFloat(0.35))
                
                self.netService.uploadImageToFirebase2(postId: postId, imageData: imageData!, completion: { (url) in
      let hash = Hashtags(to: too!, by: by!, hashtag: hashtag, comment: comment!, postId: postId, userId: FIRAuth.auth()!.currentUser!.uid, postText: postText, postImageURL: String(describing:url), postDate: postDate, type:"IMAGE")
                    self.netService.saveHashtagsToDB(hashtags: hash, completed: {
                        self.dismiss(animated: true, completion: nil)
                    })
                    
                    
                    
                    
                })
                
                
                /*
                let hashtag = Hashtag(postId: postId, userId: FIRAuth.auth()!.currentUser!.uid, to: too,by: by,hashtag: hashtags, comment: comment)
                self.netService.saveHashtagsToDB(hashtag: hashtag, completed: {
                    self.dismiss(animated: true, completion: nil)
                })
                
               
                */
                
                
                
           /*     hashtagObj.saveInBackground(block: { (success, error) -> Void in
                    if success {
                        print("hashtag \(word) is created")
                    } else {
                        print(error!.localizedDescription)
                    }
                })*/
            }
        }
               // finally save information
       /* object.saveInBackground (block: { (success, error) -> Void in
            if error == nil {
                
                // send notification wiht name "uploaded"
                NotificationCenter.default.post(name: Notification.Name(rawValue: "uploaded"), object: nil)
                
                // switch to another ViewController at 0 index of tabbar
                self.tabBarController!.selectedIndex = 0
                
                // reset everything
                self.viewDidLoad()
                self.titleTxt.text = ""
            }
        })
        */
    }
    
    
    // clicked remove button
    @IBAction func removeBtn_clicked(_ sender: AnyObject) {
        self.viewDidLoad()
    }
    
}
