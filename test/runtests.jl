using EventRasters
using StatsBase
using Test

@testset "Basic" begin
    @testset "Sorted" begin
        events = [1.0,1.2,1.4, 2.0,2.1, 3.1, 3.4, 3.5,3.7]
        markers = [1,2,3]
        tmin,tmax = (0.0, 0.3)
        aligned_events, trial_index = EventRasters.alignto(events, markers, tmin,tmax)
        @test aligned_events ≈ [0.0, 0.2, 0.0, 0.1, 0.1]
        @test trial_index == [1, 1, 2, 2, 3]
    end
    @testset "Unsorted" begin
        events = [3.1, 1.2, 3.5, 2.1, 1.4, 3.6, 2.0, 1.0, 3.4]
        markers = [1,2,3]
        tmin,tmax = (0.0, 0.3)
        aligned_events, trial_index = EventRasters.alignto(events, markers, tmin,tmax)
        @test aligned_events ≈ [0.0, 0.2, 0.0, 0.1, 0.1]
        @test trial_index == [1, 1, 2, 2, 3]
    end
end

@testset "Type wrapper" begin
    events = [1.0,1.2,1.4, 2.0,2.1, 3.1, 3.4, 3.5,3.6]
    markers = [1,2,3]
    tmin,tmax = (0.0, 0.3)
    raster = EventRasters.Raster(events, markers, tmin,tmax)
    @test raster.events ≈ [0.0, 0.2, 0.0, 0.1, 0.1]
    @test raster.trialidx == [1, 1, 2, 2, 3]
end

@testset "EventHistogram" begin
    events = [1.0,1.2,1.4, 2.0,2.1, 3.1, 3.4, 3.5,3.6]
    markers = [1,2,3]
    tmin,tmax = (-0.1, 0.3)
    raster = EventRasters.Raster(events, markers, tmin,tmax)
    hh = fit(EventRasters.EventHistogram, raster, range(0.0,stop=tmax, length=5))
    @test hh.weights[:,1] ≈ [1.0, 0.0, 1.0,0.0]
    @test hh.weights[:,2] ≈ [1.0, 1.0, 0.0,0.0]
    @test hh.weights[:,3] ≈ [0.0, 1.0, 0.0,0.0]
end

#TODO: Make sure this also works when there are gaps in the trialidx
@testset "Sorting" begin
    events = [1.0,1.2,1.4, 2.0,2.1, 4.1, 4.4, 4.5,4.6]
    markers = [1.0,2.0,3.0,4.0]
    tmin,tmax = (0.0, 0.3)
    raster = EventRasters.Raster(events, markers, tmin,tmax)
    trial_labels = [2,4,3,1]
    sraster = sort(raster,trial_labels)
    @test sraster.events ≈ [0.1, 0.0, 0.2, 0.0, 0.1]
    @test sraster.trialidx == [1, 2, 2, 3, 3]
    @test sraster.markers ≈ [4.0, 1.0, 2.0]
end
