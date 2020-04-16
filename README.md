# gusto-demo

Gusto Demo - iOS app fetching products from Gusto API, displaying them using a simple UI and making the items persist locally using CoreData.

Author: Robert Tanase

Pods used:
- Kingfisher for downloading and caching the images locally
- OHHTTPStubs/Swift for networking tests

CoreData was chosen for this project over Realm or SQL because of the simplicity of database structure and the ease of persistence implementation. It requires more attention with threads, but it is also more elegant, having the Codable protocol implemented in the same object (no need for additional model).

Native URLSession was chosen over Alamofire because the complexity of the API is very low and the features requested are just a few.

The project contains Unit and UI Tests for the basic functionalities.

The project can be improved by:
- Adding more Unit Tests
- Adding a filter for products
- Displaying more data about the products
- Using different images (sizes) for menu and product details screen
- Changing UI/UX 
