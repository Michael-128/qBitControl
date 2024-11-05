//


import Foundation

struct File: Decodable {
    let index: Int // File index
    let name: String // File name (including relative path)
    let size: Int64 // File size (bytes)
    let progress: Float // File progress (percentage/100)
    let priority: Int // File priority. See possible values here below
    let is_seed: Bool? // True if file is seeding/complete
    let piece_range: [Int]// The first number is the starting piece index and the second number is the ending piece index (inclusive)
    let availability: Float // Percentage of file pieces currently available (percentage/100)
    
    /**
     Possible values of priority:
     Value      Description
     0             Do not download
     1             Normal priority
     6             High priority
     7             Maximal priority
     */
}