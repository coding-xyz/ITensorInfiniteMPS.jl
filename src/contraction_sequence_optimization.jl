
module ContractionSequenceOptimization

  using ITensors

  export depth_first_constructive

  function _dim(is::Vector{<: Index})
    isempty(is) && return 1
    return mapreduce(dim, *, is)
  end

  function _dim(is::Vector{Int}, ind_dims::Vector{Int})
    isempty(is) && return 1
    dim = 1
    for n in 1:length(is)
      dim *= ind_dims[is[n]]
    end
    return dim
  end

  function remove_common_pair!(isR, N1, n1)
    if n1 > N1
      return
    end
    N = length(isR)
    is1 = isR[n1]
    is2 = @view isR[N1+1:N]
    n2 = findfirst(==(is1), is2)
    if isnothing(n2)
      n1 += 1
      remove_common_pair!(isR, N1, n1)
    else
      deleteat!(isR, (n1, N1+n2))
      N1 -= 1
      remove_common_pair!(isR, N1, n1)
    end
  end

  # Return the noncommon indices and the cost of contraction
  # Recursively removes pairs of indices that are common
  # between the IndexSets (TODO: use this for symdiff in ITensors.jl)
  function contract_inds_cost(is1is2::Tuple{Vector{Int}, Vector{Int}}, ind_dims::Vector{Int})
    is1, is2 = is1is2
    N1 = length(is1)
    isR = vcat(is1, is2)
    remove_common_pair!(isR, N1, 1)
    cost = Int(sqrt(_dim(is1, ind_dims) * _dim(is2, ind_dims) * _dim(isR, ind_dims)))
    return isR, cost
  end

  function depth_first_constructive(T::Vector{<: ITensor})
    return depth_first_constructive(collect.(inds.(T)))
  end

  # Converts the indices to integer labels
  # and returns a Vector that takes those labels
  # and returns the original integer dimensions
  function inds_to_ints(T::Vector{Vector{IndexT}}) where {IndexT <: Index}
    N = length(T)
    uniqueinds = ∪(T...)
    ind_to_int = Dict{IndexT, Int}()
    for p in pairs(uniqueinds)
      int, ind = p
      ind_to_int[ind] = int
    end
    ints = Vector{Int}[Vector{Int}(undef, length(T[n])) for n in 1:N]
    for n in 1:N
      T_n = T[n]
      ints_n = ints[n]
      for j in 1:length(ints_n)
        ints_n[j] = ind_to_int[T_n[j]]
      end
    end
    return ints, dim.(uniqueinds)
  end

  function depth_first_constructive(T::Vector{Vector{IndexT}}) where {IndexT <: Index}
    T′, ind_dims = inds_to_ints(T)
    return depth_first_constructive(T′, ind_dims)
  end

  # Convert a contraction sequence in pair form to tree format
  function pair_sequence_to_tree(pairs::Vector{Pair{Int, Int}}, N::Int)
    trees = Any[1:N...]
    for p in pairs
      push!(trees, Any[trees[p[1]], trees[p[2]]])
    end
    return trees[end]
  end

  # TODO: use the initial sequence as a guess sequence, which
  # can be used to prune the tree
  function depth_first_constructive(T::Vector{Vector{Int}}, ind_dims::Vector{Int})
    best_cost = Ref(typemax(Int))
    best_sequence = Vector{Pair{Int, Int}}(undef, length(T)-1)
    # Memoize index contractions and costs that have already been seen
    cost_cache = Dict{Tuple{Vector{Int}, Vector{Int}}, Tuple{Vector{Int}, Int}}()
    function _depth_first_constructive(sequence, T, remaining, cost)
      if length(remaining) == 1
        # Only should get here if the contraction was the best
        # Otherwise it would have hit the `continue` below
        @assert cost ≤ best_cost[]
        best_cost[] = cost
        best_sequence .= sequence
      end
      for aᵢ in 1:length(remaining)-1, bᵢ in aᵢ+1:length(remaining)
        a = remaining[aᵢ]
        b = remaining[bᵢ]
        Tᵈ, current_cost = get!(cost_cache, (T[a], T[b])) do
          contract_inds_cost((T[a], T[b]), ind_dims)
        end
        new_cost = cost + current_cost
        if new_cost ≥ best_cost[]
          continue
        end
        new_sequence = push!(copy(sequence), a => b)
        new_T = push!(copy(T), Tᵈ)
        new_remaining = deleteat!(copy(remaining), (aᵢ, bᵢ))
        push!(new_remaining, length(new_T))
        _depth_first_constructive(new_sequence, new_T, new_remaining, new_cost)
      end
    end
    _depth_first_constructive(Pair{Int, Int}[], T, collect(1:length(T)), 0)
    return pair_sequence_to_tree(best_sequence, length(T)), best_cost[]
  end

end # module ContractionSequenceOptimization

