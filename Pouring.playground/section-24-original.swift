typealias Path = [Move]

func partition<T>(ar: [T], predicate: T->Bool) -> ([T],[T]) {
    func antiPredicate(value: T) -> Bool {
        return !(predicate(value))
    }
    return(ar.filter(predicate), ar.filter(antiPredicate))
}

let (a,b) = partition(nums, {n in n > 2})
a
b

extension Move: Equatable {   
}
func == (left: Move, right: Move) -> Bool {
	return left.asText() == right.asText()
}

func != (left: Move, right: Move) -> Bool {
	return !(right == left)
}

func extend(from: [Path]) -> [Path] {
    var result = [Path]()
    for fromPath in from {
        let lastMove = fromPath.last
        if lastMove == nil {
            result = [[Move.Fill(0)], [Move.Fill(1)], [Move.Fill(2)]]
        } else {
            for move in filter(Move.values, {x in x != lastMove!}) {
                var path = fromPath
                path.append(move)
                result.append(path)
            }
        }
    }
    return result
}

func resolve(paths: [Path], target: Int) {
    func isSolution(path: Path) -> Bool {
        return contains(path.reduce(initialState, ~~), target)
    }
	let (solutions, others) = partition(paths, isSolution)
	if (solutions.count > 0) {
		solutions.map({s in println("Solution: \(s.map({m in m.asText()})) -> \(s.reduce(initialState, ~~))")})
	} else {
	   resolve(extend(others), target)
    }
}

resolve([[]], TARGET)
