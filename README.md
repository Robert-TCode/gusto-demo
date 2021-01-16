## Gousto Demo
Gousto Demo - iOS app fetching products from the Gusto API, displaying them using a neat and modern UI.

Author: Robert Tanase

# Dependencies
- Kingfisher for downloading and caching the images locally
- OHHTTPStubs/Swift for networking stubbing

# Database and Networking
`CoreData` was chosen for this project over `Realm` or `SQL` because of the structure's simplicity and the ease of implementation for persistence. `CoreData` requires more attention for threading, but it's more elegant. The `Codable` protocol is of great use for ease of parsing from the API's response to out model(s).

Native `URLSession` was chosen over` Alamofire` because the complexity of the networking layer is low and `AF` is coming in the same package with a lot of functionalities that are not neceesary in this case.

The project contains Unit and UITests for the base functionalities.

# Improvements
The project can be improved by:
- Adding more Unit Tests
- Adding a filter for products
- Displaying more information about the products
- Using different images (as size) for menu and product details screen
- Better UI/UX 
