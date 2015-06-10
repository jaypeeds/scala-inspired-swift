protocol Enumerable {
	static var values:[Move] {get}
}
extension Move: Enumerable {
	static var values:[Move] {
		var moves = [Move]()
		for g in glasses {
    		moves.append(Move.Empty(g))
		}
		for g in glasses {
    		moves.append(Move.Fill(g))	
		}
		for g in glasses {
    		for h in glasses.filter({x in x != g}) {
        		moves.append(Move.Pour(g,h))
    		}
		}
		return moves
	}
}
Move.values
