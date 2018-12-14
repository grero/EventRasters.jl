struct Raster{T<:Real,T2<:Real}
    events::Vector{T}
    trialidx::Vector{Int64}
    markers::Vector{T2}
    tmin::Union{T,T2}
    tmax::Union{T,T2}
end
