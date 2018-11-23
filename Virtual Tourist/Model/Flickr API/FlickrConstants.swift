
// MARK: - OTMParseClient (Constants)

extension FlickrClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey = "af9404d9cb059882f7c1ca214100d462"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.flickr.com"
        static let ApiPath = "/services/rest"
        
    }
    
    static let SearchBBoxHalfWidth = 0.2
    static let SearchBBoxHalfHeight = 0.2
    static let SearchLatRange = (-90.0, 90.0)
    static let SearchLonRange = (-180.0, 180.0)

    
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Extras = "extras"
        static let SafeSearch = "safe_search"
        static let PhotosPerPage = "per_page"
        static let BoundingBox = "bbox"

        
    }
    
    // MARK: Parameter Values
    struct ParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "af9404d9cb059882f7c1ca214100d462"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1" 
        static let PhotosPerPage = "21"
        
    }
    
    
}
