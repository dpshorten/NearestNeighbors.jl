check_radius(r) = r < 0 && throw(ArgumentError("the query radius r must be ≧ 0"))

"""
    inrange(tree::NNTree, points, radius [, sortres=false]) -> indices

Find all the points in the tree which is closer than `radius` to `points`. If
`sortres = true` the resulting indices are sorted.
"""
function inrange(tree::NNTree,
                 points::Vector{T},
                 radius::Number,
                 sortres=false) where {T <: AbstractVector}
    check_input(tree, points)
    check_radius(radius)

    idxs = [Vector{Int}() for _ in 1:length(points)]

    for i in 1:length(points)
        inrange_point!(tree, points[i], radius, sortres, idxs[i])
    end
    return idxs
end

function inrange_point!(tree, point, time_of_this_event::AbstractFloat, history_start_of_this_event::AbstractFloat,
                        event_times::Vector{<:AbstractFloat}, history_start_times::Vector{<:AbstractFloat},radius, sortres, idx)
    _inrange(tree, point,  time_of_this_event, history_start_of_this_event, event_times, history_start_times, radius, idx)
    if tree.reordered
        @inbounds for j in 1:length(idx)
            idx[j] = tree.indices[idx[j]]
        end
    end
    sortres && sort!(idx)
    return
end

function inrange(tree::NNTree{V}, point::AbstractVector{T}, time_of_this_event::AbstractFloat, history_start_of_this_event::AbstractFloat,
                 event_times::Vector{<:AbstractFloat}, history_start_times::Vector{<:AbstractFloat},
                 radius::Number, sortres=false) where {V, T <: Number}
    check_input(tree, point)
    check_radius(radius)
    idx = Int[]
    inrange_point!(tree, point, time_of_this_event, history_start_of_this_event, event_times, history_start_times, radius, sortres, idx)
    return idx
end

function inrange(tree::NNTree{V}, point::AbstractMatrix{T}, time_of_this_event::AbstractFloat, history_start_of_this_event::AbstractFloat,
                 event_times::Vector{<:AbstractFloat}, history_start_times::Vector{<:AbstractFloat},
                 radius::Number, sortres=false) where {V, T <: Number}
    dim = size(point, 1)
    npoints = size(point, 2)
    if isbitstype(T)
        new_data = copy_svec(T, point, Val(dim))
    else
        new_data = SVector{dim,T}[SVector{dim,T}(point[:, i]) for i in 1:npoints]
    end
    inrange(tree, new_data, radius, sortres)
end
