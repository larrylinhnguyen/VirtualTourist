//
//  VLTFlickerConvienience.swift
//  VirtualTourist
//
//  Created by Moath_Othman on 8/27/15.
//  Copyright (c) 2015 Moba. All rights reserved.
//

import Foundation


let SAFE_SEARCH = "1"
let EXTRAS = "url_m"
let DATA_FORMAT = "json"
let NO_JSON_CALLBACK = "1"
var randomindex: Int = -1
// Session
extension VLTFlickerClient {

    func getphotosOfLocation(_ latitude: Float,longitude: Float, completionHandler: @escaping CommonAPICompletionHandler) {
        getphotosOfLocation(latitude, longitude: longitude, page: 1, completionHandler: completionHandler)
    }

    func getphotosOfLocation(_ latitude: Float,longitude: Float,page: Int, completionHandler: @escaping CommonAPICompletionHandler) {
        let methodArguments = [
            "method": VLTFlickerClient.Methods.search,
            "api_key": VLTFlickerClient.Constants.ApiKey,
            "lat": latitude,
            "lon": longitude,
            "accuracy": 3,
            "safe_search": SAFE_SEARCH,
            "extras": EXTRAS,
            "format": DATA_FORMAT,
            "nojsoncallback": NO_JSON_CALLBACK,
            "page":page,
            "per_page":20,
            "sort": randomSorting(),
        ] as [String : Any]

        taskForMethodParameters(methodArguments as [String : AnyObject], completionHandler: { (response, error) -> Void in
            print("response is \(response)", terminator: "" )

            if let photosDictionary = response!.value(forKey: "photos") as? [String:AnyObject] {

                if let photos = photosDictionary["photo"] as? [AnyObject], let pages = photosDictionary["pages"] as? Int {
                    completionHandler(["photos":photos,"pages":pages] as AnyObject?, nil)
                    
                } else {
                    print("Cant find key 'pages' in \(photosDictionary)")
                }
            } else {
                print("Cant find key 'photos' in \(response)")
            }
            
        })
    }


    func taskForImageWithURL(_ url: String, completionHandler: @escaping (_ imageData: Data?, _ error: NSError?) ->  Void) -> URLSessionTask {

         let url = URL(string: url)!
         print(url)

        let request = URLRequest(url: url)

        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in

            if let error = downloadError {
                completionHandler(nil, error as NSError?)
            } else {
                completionHandler(data, nil)
            }
        }) 

        task.resume()

        return task
    }

    func randomSorting() -> String{
        //its a way of randomizing the images
        //using the different sorting types
        //in this way we have only seven posibilities
        //since Its not a good idea for me to use page numbers since in some cases they are limited (e.g desert)
        // hence we will load empty results some way
        // another way is to check the number of pages for some lat/lon and randomize through them
        //lets take a cese 
        /*where we have 10 pages from the first request by defult we will get results from page 1 but we will get the number of pages anyhow
        then when the user click new collection next time we should preserve that total pages for this pin so we pick another random page*/
        //this is not perfect but the simplest
        let sortTypes = ["date-posted-asc",
            "date-posted-desc",
            "date-taken-asc",
            "date-taken-desc",
            "interestingness-desc",
            "interestingness-asc",
            "relevance",
        ]
        var randomPhotoIndex = Int(arc4random_uniform(UInt32(sortTypes.count)))
        while randomPhotoIndex == randomindex {
            randomPhotoIndex = Int(arc4random_uniform(UInt32(sortTypes.count)))
        }
        randomindex = randomPhotoIndex
        return sortTypes[randomPhotoIndex]
    }

}
