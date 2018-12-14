struct Raster{T<:Real,T2<:Real}
    events::Vector{T}
    trialidx::Vector{Int64}
    markers::Vector{T2}
    tmin::Union{T,T2}
    tmax::Union{T,T2}
end

ntrials(raster::Raster) = length(raster.markers)

struct EventHistogram{T<:Real,N,E,T2<:Real} <: StatsBase.AbstractHistogram{T,N,E}
    edges::E
    weights::Array{T,N}
    closed::Symbol
    isdensity::Bool
    markers::Vector{T2}
end

StatsBase.binindex(h::EventHistogram{T,N,E,T2}, x::Real) where {T,N,E,T2} = StatsBase._edge_binindex(h.edges, h.closed, x)

function StatsBase.fit(::Type{EventHistogram}, raster::Raster{T,T2}, edges::E;isdensity=false, closed=:left) where {T<:Real,T2<:Real,E}
    nt = ntrials(raster)
    h = EventHistogram(edges, fill(0.0, length(edges)-1,nt), closed,isdensity,raster.markers)
    nevents = length(raster.events)
    for i in 1:nevents
        idx = StatsBase.binindex(h,raster.events[i]) 
        tidx = raster.trialidx[i]
        if checkbounds(Bool, h.weights, idx...,tidx)
            @inbounds h.weights[idx...,tidx] += 1.0
        end
    end
    h
end
