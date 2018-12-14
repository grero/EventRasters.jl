using EventRasters
using Test

@testset "Basic" begin
    @testset "Sorted" begin
        events = [1.0,1.2,1.3, 2.0,2.1, 3.1, 3.4, 3.5,3.6]
        markers = [1,2,3]
        tmin,tmax = (0.0, 0.3)
        aligned_events, trial_index = EventRasters.alignto(events, markers, tmin,tmax)
        @test aligned_events ≈ [0.0, 0.2, 0.0, 0.1, 0.1]
        @test trial_index == [1, 1, 2, 2, 3]
    end
    @testset "Unsorted" begin
        events = [3.1, 1.2, 3.5, 2.1, 1.3, 3.6, 2.0, 1.0, 3.4]
        markers = [1,2,3]
        tmin,tmax = (0.0, 0.3)
        aligned_events, trial_index = EventRasters.alignto(events, markers, tmin,tmax)
        @test aligned_events ≈ [0.0, 0.2, 0.0, 0.1, 0.1]
        @test trial_index == [1, 1, 2, 2, 3]
    end
end
