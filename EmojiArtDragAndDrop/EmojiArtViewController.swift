//
//  EmojiArtViewController.swift
//  EmojiArtDragAndDrop
//
//  Created by Boppo on 02/05/19.
//  Copyright © 2019 MB. All rights reserved.
//

import UIKit

class EmojiArtViewController: UIViewController,UIDropInteractionDelegate {
    @IBOutlet weak var dropZone: UIView! {
        didSet{
            dropZone.addInteraction(UIDropInteraction(delegate: self))
            
        }
    }
    
    //canHandle -> sessionUpdate -> PerformDrop
    
    func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        
       // session.canLoadObjects(ofClass: <#T##_ObjectiveCBridgeable.Protocol#>)
        //NSURL this whole thing is objective-c compatible and in swift it's called URL it's a struct
        //And in objective C its a NSURL it's a class , now those things are automatically bridged to eachother So you can always as 1 to other
        //but here is one of few places in diversity where you have to use Objective C thing
        //Thats because we are specifying the actual class here NSURL.self
        //we are not taking any instance where swift can kind of figure out whqat you want it's the actual class NSURL
        return session.canLoadObjects(ofClass: NSURL.self) && session.canLoadObjects(ofClass: UIImage.self)
        // So I want both the image and Url or i am not interested in drag so if you drag an NSAttributedString on me I dont care that's I only interested in me you can drag something that's both an image and the url for the image maybe that URL maybe you would drag something that's an image any URL and it's not a URL of that image but we are gonna find that out
    }
    // So this is saying we can handle a drag like  that
    //So this is basically just saying if you are not that kind of drag then don't even talk with me , So if it is that kind of drag then it's gonna talk to us and it's gonna do updateSession
    
    func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        //gonna copy has it's always gonna copy from outside my app , So there's no reason  I would ever cancel it I am always happy to accept an image
        return UIDropProposal(operation: .copy)
    }
    
    
    var imageFetcher : ImageFetcher!
    
    //here I am gonna do is go tell the drag And drop system , let that guy know I want that data and give it to me and call this closure
    func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        
        
//        imageFetcher = ImageFetcher(handler: { (<#URL#>, <#UIImage#>) in
//            <#code#>
//        })
        imageFetcher = ImageFetcher(){ (url,image) in
            DispatchQueue.main.async {
                self.emojiArtView.backgroundImage = image
            }
        }
        
        
        session.loadObjects(ofClass: NSURL.self) { (nsurls) in
            if let url = nsurls.first as? URL{
            self.imageFetcher.fetch(url)
            }
        }
        //what i am gonna do with URl with images well eventually I need to hold on to that URL because I gonna create a document which is emojiArt document  and it's background is gonna be a URL , because I dont wanna store that hugh image with all my documents
        //I am just gonna store the URL and anytime to display document I will just go get the image off the network
        session.loadObjects(ofClass: UIImage.self) { (images) in
            //has yo do as? because type of images and nsurls is NSItemProviders , so we have to convert it to actual kind of a provider that we are expecting here
            if let image = images.first as? UIImage{
            self.imageFetcher.backup = image
            }
        }
    }
    
    @IBOutlet weak var emojiArtView: EmojiArtView!
    
 //Why did I just dont make emojiArtView the dropZone?
    /*
     Well that's because of 2 reasons
     (1) I need to keep track of at the controller level what's dropped in because I am actually  going to rememer the URL of what's dropped in ,
     And all the keeping tracking of the document has to happen in controller level
     we dont want view doing that
     (2) Sometimes I am going to eventually put this view in scrollView and it might be small it might not be filling the space anymore and so I want the drop zone to be as big as possible
     So when I drop stuff in , it always works
     So that's why I need those separate but it's not really that big a deal not really  that much of a requirement to do it
     I didn't want you to think there's some special reason like you have to make your drop zone be a separate generic View  you dont have to
 */
}



//Ctrl + shift + left click for menu of list of items in a viewcontrollers in storyboard


// bigger images takes longer time as it fetches the image asynchronously
//put a spinning wheel when we have gonna off to fetch that image
