import Foundation

struct GameLine: Identifiable, Decodable {
    let id: Int?
    let season: Int?
    let seasonType: String?
    let week: Int?
    let startDate: String?
    let homeTeam: String?
    let homeConference: String?
    let homeScore: Int?
    let awayTeam: String?
    let awayConference: String?
    let awayScore: Int?
    let lines: [Line]?

    struct Line: Identifiable, Decodable {
        let id = UUID()
        let provider: String?
        let spread: Double?
        let formattedSpread: String?
        let spreadOpen: Double?
        let overUnder: Double?
        let overUnderOpen: Double?
        let homeMoneyline: Double?
        let awayMoneyline: Double?

        enum CodingKeys: String, CodingKey {
            case provider
            case spread
            case formattedSpread
            case spreadOpen
            case overUnder
            case overUnderOpen
            case homeMoneyline
            case awayMoneyline
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            provider = try? container.decode(String.self, forKey: .provider)
            formattedSpread = try? container.decode(String.self, forKey: .formattedSpread)
            spread = GameLine.Line.doubleValue(from: container, forKey: .spread)
            spreadOpen = GameLine.Line.doubleValue(from: container, forKey: .spreadOpen)
            overUnder = GameLine.Line.doubleValue(from: container, forKey: .overUnder)
            overUnderOpen = GameLine.Line.doubleValue(from: container, forKey: .overUnderOpen)
            homeMoneyline = GameLine.Line.doubleValue(from: container, forKey: .homeMoneyline)
            awayMoneyline = GameLine.Line.doubleValue(from: container, forKey: .awayMoneyline)
        }

        private static func doubleValue(from container: KeyedDecodingContainer<CodingKeys>, forKey key: CodingKeys) -> Double? {
            if let doubleValue = try? container.decode(Double.self, forKey: key) {
                return doubleValue
            }
            if let stringValue = try? container.decode(String.self, forKey: key) {
                return Double(stringValue)
            }
            return nil
        }
    }
}





