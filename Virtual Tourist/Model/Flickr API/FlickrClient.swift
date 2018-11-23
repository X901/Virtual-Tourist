

import Foundation


class FlickrClient : NSObject {

    // MARK: Properties

    // shared session
    var session = URLSession.shared

    // MARK: Initializers

    override init() {
        super.init()
    }
    
    
  

      func bboxString(latitude: Double, longitude: Double) -> String {
    
        let minimumLon = max(longitude - FlickrClient.SearchBBoxHalfWidth, FlickrClient.SearchLonRange.0)
        let minimumLat = max(latitude  - FlickrClient.SearchBBoxHalfHeight, FlickrClient.SearchLatRange.0)
        let maximumLon = min(longitude + FlickrClient.SearchBBoxHalfWidth, FlickrClient.SearchLonRange.1)
        let maximumLat = min(latitude  + FlickrClient.SearchBBoxHalfHeight, FlickrClient.SearchLatRange.1)
        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }

    func taskForGETMethod<D: Decodable>(parameters: [String:AnyObject],decode:D.Type, completionHandlerForGET: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        /* 1. Set the parameters */
        var parametersWithApiKey = parameters
        /* 2/3. Build the URL, Configure the request */
        
        
        var request = NSMutableURLRequest(url: tmdbURLFromParameters(parametersWithApiKey))
        
        
        /* 4. Make the request */
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("\(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            
            /* 5/6. Parse the data and use the data (happens in completion handler) */
            self.convertDataWithCompletionHandler(data, decode:decode,completionHandlerForConvertData: completionHandlerForGET)
            
        }
        /* 7. Start the request */
        task.resume()
        
        return task
        
        
    }




    private func convertDataWithCompletionHandler<D: Decodable>(_ data: Data,decode:D.Type, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {


        do {
            let obj = try JSONDecoder().decode(decode, from: data)
            completionHandlerForConvertData(obj as AnyObject, nil)

        } catch {
            let userInfo = [NSLocalizedDescriptionKey : "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }

    }

    // create a URL from parameters
    private func tmdbURLFromParameters(_ parameters: [String:AnyObject]) -> URL {

        var components = URLComponents()
        components.scheme = FlickrClient.Constants.ApiScheme
        components.host = FlickrClient.Constants.ApiHost
        components.path = FlickrClient.Constants.ApiPath

        components.queryItems = [URLQueryItem]()

        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)

        }

           let url = components.url!
       

        return url
    }




    // MARK: Shared Instance

    class func sharedInstance() -> FlickrClient {
        struct Singleton {
            static var sharedInstance = FlickrClient()
        }
        return Singleton.sharedInstance
    }
}
