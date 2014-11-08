
protocol TextRepresentable {
    func asText() -> String
}
extension Move: TextRepresentable {
	    func asText() -> String {
        switch self {
        case .Empty(let glass): return "Empty(\(glass))"
        case .Fill(let glass): return "Fill(\(glass))"
        case let .Pour(from, to): return "Pour(\(from), \(to))"
        }
    }
}
Move.values.map({m in m.asText()})
