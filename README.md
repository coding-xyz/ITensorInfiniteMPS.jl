| :warning: WARNING          |
|:---------------------------|
| This package is a work in progress! There is minimal documentation, and you are expected to understand infinite MPS methods before using the code. Please first read references on tangent space methods for infinite MPS and be sure to understand the mixed canonical form of infinite MPS (https://arxiv.org/abs/1701.07035, https://arxiv.org/abs/1802.07197, https://arxiv.org/abs/1810.07006), and also read through the code and examples to understand the code design, philosophy, and supported infinite MPS operations. This package is *not* as feature-rich and field-tested as the MPS/DMRG implementation in ITensors.jl. The VUMPS algorithm is much newer than the DMRG algorithm, and the convergence properties and best practices of the algorithm are not as well understood as the DMRG algorithm. You are expected to work out best practices on your own, tune parameters, and feel free to share your experiences through [Github issues](https://github.com/ITensor/ITensorInfiniteMPS.jl/issues) or the [ITensor Discourse forum](https://itensor.discourse.group/). If/when you come across issues, please try to read the code and debug the issue yourself, and raise [issues](https://github.com/ITensor/ITensorInfiniteMPS.jl/issues) and/or make [pull requests](https://github.com/ITensor/ITensorInfiniteMPS.jl/pulls) that fix issues through Github. |

# ITensorInfiniteMPS

## Introduction
This is a package for working with infinite MPS based on the [ITensors.jl](https://github.com/ITensor/ITensors.jl) library. The goal is to provide basic tools for infinite MPS that match the functionality that is available for finite MPS in ITensors.jl, for example gauging infinite MPS with `orthogonalize`, `InfiniteMPS + InfiniteMPS`, `InfiniteMPO * InfiniteMPS`, gate evolution, computing low-lying excited states with VUMPS, etc.

## Installation

The package is currently not registered. Please install with the commands:
```julia
julia> using Pkg; Pkg.add(url="https://github.com/coding-xyz/ITensorInfiniteMPS.jl.git")
```

## Examples

This package is a work in progress. Here are some examples of the interface:
```julia
julia> using ITensors, ITensorInfiniteMPS

julia> s = siteinds("S=1/2", 3)
3-element Array{Index{Int64},1}:
 (dim=2|id=652|"S=1/2,Site,n=1")
 (dim=2|id=984|"S=1/2,Site,n=2")
 (dim=2|id=569|"S=1/2,Site,n=3")

julia> ψ = InfiniteMPS(s) # Infinite MPS with 3-site unit cell
InfiniteMPS
[1] IndexSet{3} (dim=1|id=317|"Link,c=0,l=3") (dim=2|id=652|"S=1/2,Site,c=1,n=1") (dim=1|id=77|"Link,c=1,l=1")
[2] IndexSet{3} (dim=1|id=77|"Link,c=1,l=1") (dim=2|id=984|"S=1/2,Site,c=1,n=2") (dim=1|id=868|"Link,c=1,l=2")
[3] IndexSet{3} (dim=1|id=868|"Link,c=1,l=2") (dim=2|id=569|"S=1/2,Site,c=1,n=3") (dim=1|id=317|"Link,c=1,l=3")


julia> ψ[2] == replacetags(ψ[5], "c=2" => "c=1") # Indexing outside of the unit cell gets tensors from other unit cells
true

julia> ψ₁ = ψ[1:3] # Create a finite MPS from the tensors of the first unit cell
MPS
[1] IndexSet{3} (dim=1|id=317|"Link,c=0,l=3") (dim=2|id=652|"S=1/2,Site,c=1,n=1") (dim=1|id=77|"Link,c=1,l=1")
[2] IndexSet{3} (dim=1|id=77|"Link,c=1,l=1") (dim=2|id=984|"S=1/2,Site,c=1,n=2") (dim=1|id=868|"Link,c=1,l=2")
[3] IndexSet{3} (dim=1|id=868|"Link,c=1,l=2") (dim=2|id=569|"S=1/2,Site,c=1,n=3") (dim=1|id=317|"Link,c=1,l=3")


julia> ψ₂ = ψ[4:6] # Create a finite MPS from the tensors of the second unit cell
MPS
[1] IndexSet{3} (dim=1|id=317|"Link,c=1,l=3") (dim=2|id=652|"S=1/2,Site,c=2,n=1") (dim=1|id=77|"Link,c=2,l=1")
[2] IndexSet{3} (dim=1|id=77|"Link,c=2,l=1") (dim=2|id=984|"S=1/2,Site,c=2,n=2") (dim=1|id=868|"Link,c=2,l=2")
[3] IndexSet{3} (dim=1|id=868|"Link,c=2,l=2") (dim=2|id=569|"S=1/2,Site,c=2,n=3") (dim=1|id=317|"Link,c=2,l=3")
```
Useful operations like gauging and optimization are in progress, so stay tuned!

