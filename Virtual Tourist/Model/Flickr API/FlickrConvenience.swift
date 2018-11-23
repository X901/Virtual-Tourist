
import UIKit
import Foundation


extension FlickrClient {
    

    
    func getPhotosFormFlicker(latitude:Double ,longitude:Double, _ completionHandlerForFlickerPhoto: @escaping (_ success: Bool,_ photoData: [Any]?,_   :String?, _ errorString: String?) -> Void) {
        
        
        let bBox = self.bboxString(latitude: latitude, longitude: longitude)

        let parameters = [
            FlickrClient.ParameterKeys.Method           : FlickrClient.ParameterValues.SearchMethod
            , FlickrClient.ParameterKeys.APIKey         : FlickrClient.ParameterValues.APIKey
            , FlickrClient.ParameterKeys.Format         : FlickrClient.ParameterValues.ResponseFormat
            , FlickrClient.ParameterKeys.Extras         : FlickrClient.ParameterValues.MediumURL
            , FlickrClient.ParameterKeys.NoJSONCallback : FlickrClient.ParameterValues.DisableJSONCallback
            , FlickrClient.ParameterKeys.SafeSearch     : FlickrClient.ParameterValues.UseSafeSearch
            , FlickrClient.ParameterKeys.BoundingBox    : bBox
            , FlickrClient.ParameterKeys.PhotosPerPage  : FlickrClient.ParameterValues.PhotosPerPage
            ] as [String : Any]
        
        /* 2. Make the request */
        
        _ = taskForGETMethod( parameters: parameters as [String : AnyObject] , decode: FlikerResbonse.self) { (result, error) in
            
            
            if let error = error {
                
                completionHandlerForFlickerPhoto(false ,nil ,nil,"\(error.localizedDescription)")
            }else {
                
             let newResult = result as! FlikerResbonse
                
               let resultData = newResult.photos.photo
                
                if newResult.photos.photo.isEmpty {

                    let noPhotoMessage = "This pin has no images!"

                    completionHandlerForFlickerPhoto(true ,nil ,noPhotoMessage,nil)

                } else {
                    completionHandlerForFlickerPhoto(true ,resultData,nil,nil)

                }
                

                
                
            }
        }
        
    }
    
    
    
    
    
}


