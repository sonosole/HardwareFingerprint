# Installation

```julia
using Pkg
Pkg.add(url="https://github.com/sonosole/HardwareFingerprint")
```
# Usage

The exported API is

```julia
save2jl(filepath::String)
```

where  `filepath`  is the path (with suffix  `.jl` ) you want to save your fingerprint information. For example 

```julia
# ONLY running on Windows OS
julia> using HardwareFingerprint;
julia> save2jl("d:/xxx.jl");
```
