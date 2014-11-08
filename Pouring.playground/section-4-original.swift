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

Move.Fill(0).change(initialState)
Move.Pour(0,2).change(Move.Fill(0).change(initialState))
