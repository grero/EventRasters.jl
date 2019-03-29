module EventRasters
using StatsBase
import Base.sort

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
    nevents = length(events)
    nmarkers = length(marker)
    for tidx in 1:nmarkers
        ii = searchsortedfirst(sevents, smarker[tidx] + tmin)
        jj = searchsortedlast(sevents, smarker[tidx] + tmax)
        append!(aligned_events, sevents[ii:jj] .- smarker[tidx])
        append!(trial_index, fill(tidx, jj-ii+1))
    end
    aligned_events, trial_index
end

function Raster(events::Vector{T}, markers::Vector{T2}, tmin::Real, tmax::Real) where T <: Real where T2 <: Real
    aligned_events, trialindex = alignto(events, markers, tmin,tmax)
    Raster(aligned_events, trialindex, markers, tmin, tmax)
end

"""
Sort `raster` by trials using the labels `sortby`.
"""
function Base.sort(raster::Raster, sortby::AbstractVector{T},;rev=false) where T <: Real
    sidx = sortperm(raster.trialidx, alg=MergeSort, by=s->sortby[s];rev=rev)
    trialidx_s = raster.trialidx[sidx]
    tidx = 1
    tidx_s = trialidx_s[1]
    y = fill!(similar(sidx),0)
    for i in 1:length(y)
        if trialidx_s[i] != tidx_s
            tidx_s = trialidx_s[i]
            tidx += 1
        end
        y[i] = tidx  # set the trialidx to the new value
    end
    #we need to sort the markers, leaving out the ones that were not used
    _tidx = sort(unique(raster.trialidx),by=s->sortby[s], rev=rev)
    _markers = raster.markers[_tidx]
    Raster(raster.events[sidx], y, _markers, raster.tmin, raster.tmax)
end
end # module
