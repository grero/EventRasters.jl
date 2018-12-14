module EventRasters
using StatsBase

include("types.jl")

"""
Align `events` to the alignment markers in `marker`, and retain events window of `(tmin,tmax)` around each marker.
"""
function alignto(events::Vector{T}, marker::Vector{T2}, tmin::Real, tmax::Real) where T <: Real where T2 <: Real
    if issorted(marker)
        smarker = marker
    else
        smarker = sort(marker)
    end
    if issorted(events)
        sevents = events
    else
        sidx = sortperm(events)
        sevents = events[sidx]
    end
    aligned_events = T[]
    trial_index = Int64[]
    i = 1 
    nevents = length(events)
    nmarkers = length(marker)
    ii = searchsortedfirst(sevents, smarker[1] + tmin)
    tidx = 1
    while (ii <= nevents) && (tidx <= nmarkers)
        ii = searchsortedfirst(sevents, smarker[tidx] + tmin)
        while (ii <= nevents) && sevents[ii] < smarker[tidx]+tmax
            push!(trial_index, tidx)
            push!(aligned_events, sevents[ii] - smarker[tidx])
            ii += 1
        end
        tidx += 1
    end
    aligned_events, trial_index
end

function Raster(events::Vector{T}, markers::Vector{T2}, tmin::Real, tmax::Real) where T <: Real where T2 <: Real
    aligned_events, trialindex = alignto(events, markers, tmin,tmax)
    Raster(aligned_events, trialindex, markers, tmin, tmax)
end
end # module
