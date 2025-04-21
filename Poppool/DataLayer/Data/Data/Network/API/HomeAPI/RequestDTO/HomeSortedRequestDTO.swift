import Foundation

struct HomeSortedRequestDTO: Encodable {
    var page: Int32?
    var size: Int32?
    var sort: String?
}
