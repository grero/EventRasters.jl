# EventRasters
[![Build Status](https://travis-ci.org/grero/EventRasters.jl.svg?branch=master)](https://travis-ci.org/grero/EventRasters.jl)
[![Coverage Status](https://coveralls.io/repos/github/grero/EventRasters.jl/badge.svg?branch=master)](https://coveralls.io/github/grero/EventRasters.jl?branch=master)
## Introduction
This is a simple tool to generate so-called rasters by aligning events to markers. This is widely used in neuroscience to create peri-stimulus time rasters, which show the spiking activity of putative neurons aligned to experimentally controlled events.

## Examples
```julia
events = [1.0,1.2,1.3, 2.0,2.1, 3.1, 3.4, 3.5,3.6]
markers = [1,2,3]
tmin,tmax = (0.0, 0.3)
raster = EventRasters.Raster(events, markers, tmin,tmax)
```
