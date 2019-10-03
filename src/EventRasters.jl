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

function Base.getindex(raster::Raster, idx::AbstractVector{Int64})
    qtrialidx = raster.trialidx[idx]
    trialidx = fill(zero(Int64), length(idx))
    trialidx[1] = 1
    _tidx = 1
    midx = fill(false, length(raster.markers))
    midx[qtrialidx[1]] = true
    for i in 2:length(idx)
        if qtrialidx[i] != qtrialidx[i-1]
            _tidx += 1
            midx[qtrialidx[i]] = true
        end
        trialidx[i] = _tidx
    end
    markers = raster.markers[midx]
    events = raster.events[idx]
    Raster(events, trialidx, markers, raster.tmin, raster.tmax)
end

function Base.filter(pred, raster::Raster)
	qidx = findall(pred, raster.trialidx)
	tidx = findall(pred, unique(raster.trialidx))
	events = raster.events[qidx]
	tmin, tmax = extrema(events)
	Raster(events, raster.trialidx[qidx], raster.markers, tmin, tmax)
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

"""
Get the first event in each trial with a timestamp larger than or equal to t0
"""
function firstevent(raster::Raster;t0=0.0)
	trials = unique(raster.trialidx)
	sort!(trials)
	events = fill(NaN, length(trials))
	for (i,t) in enumerate(trials)
		tidx = findall(raster.trialidx.==t)
		ii = searchsortedfirst(raster.events[tidx], t0)
		if 0 < ii <= length(tidx)
			events[i] = raster.events[tidx[ii]]
		end
	end
	events
end
end # module
