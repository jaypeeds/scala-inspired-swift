typealias State = [Int]

let CAPACITIES = [3, 5, 9]
var initialState = CAPACITIES.map({x in x * 0})

let glasses = 0..<CAPACITIES.count

protocol StateChanger {
    func change(state: State) -> State
}

enum Move: StateChanger {
    
    case Empty(Int)
    case Fill(Int)
    case Pour(Int, Int)
    
    func change(state: State) -> State {
        var changed = state
        switch self {
            case .Empty(let glass):
                changed[glass] = 0
                return changed
            case .Fill(let glass):
                changed[glass] = CAPACITIES[glass]
                return changed
            case let .Pour(from, to):
                let availQty = state[from]
                let availCap = CAPACITIES[to] - state[to]
                if availQty >= availCap {
                    changed[from] = availQty - availCap
                    changed[to] = CAPACITIES[to]
                } else {
                    changed[from] = 0
                    changed[to] += availQty
                }
                return changed
            default:
                return state
        }
    }
}

infix operator ~~ { associativity left precedence 160 }

// Usage: initial_state ~~ move0 ~~ move1 ~~ move2
func ~~ (left: State, right: Move) -> State {
    return right.change(left)
}

let TARGET = 7

protocol Enumerable {
    class var values:[Move] {get}
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
            for h in filter(glasses, {x in x != g}) {
                moves.append(Move.Pour(g,h))
            }
        }
        return moves
    }
}

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

typealias Path = [Move]

func partition<T>(ar: [T], predicate: T->Bool) -> ([T],[T]) {
    func antiPredicate(value: T) -> Bool {
        return !(predicate(value))
    }
    return(ar.filter(predicate), ar.filter(antiPredicate))
}

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
    let moves = Move.values
    for fromPath in from {
        let lastMove = fromPath.last
        if lastMove == nil {
            result = [[Move.Fill(0)], [Move.Fill(1)], [Move.Fill(2)]]
        } else {
            for move in filter(moves, {x in x != lastMove!}) {
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

