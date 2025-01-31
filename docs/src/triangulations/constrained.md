# Constrained Triangulations

Here we show to compute constrained triangulations. The interface for this is via `triangulate` just as it was with unconstrained triangulations, or 
you can do it manually with `add_edge!`. We will go through several examples.

## Constrained edges only 

Let us start with an example that shows the computation of a constrained triangulation, with constrained edges only rather than handling boundary nodes. Here, any edges can be used as long as they do not intersect (they can run into each other if they are collinear, in which case they are split automatically).

```julia
using DelaunayTriangulation, CairoMakie
a = (0.0, 0.0)
b = (0.0, 1.0)
c = (0.0, 2.5)
d = (2.0, 0.0)
e = (6.0, 0.0)
f = (8.0, 0.0)
g = (8.0, 0.5)
h = (7.5, 1.0)
i = (4.0, 1.0)
j = (4.0, 2.5)
k = (8.0, 2.5)
pts = [a, b, c, d, e, f, g, h, i, j, k]
C = Set([(2,1),(2,11),(2, 7), (2, 5)])
uncons_tri = triangulate(pts)
cons_tri=triangulate(pts;edges=C)
fig = Figure()
ax = Axis(fig[1, 1], xlabel=L"x", ylabel=L"y", width=300, height=300,
    title=L"(a):$ $ Unconstrained", titlealign=:left)
triplot!(ax, uncons_tri)
ax = Axis(fig[1, 2], xlabel=L"x", ylabel=L"y", width=300, height=300,
    title=L"(b):$ $  Constrained", titlealign=:left)
triplot!(ax, cons_tri)
resize_to_layout!(fig)
```

```@raw html
<figure>
    <img src='../figs/simple_constrained.png', alt='Constrained triangulation'><br>
</figure>
```

## With an outer boundary 

Now let us define an outer boundary also. For this, the `convert_boundary_points_to_indices` function will be useful to convert a set of boundary coordinates to indices correctly.
Note also that the boundary points we specify must connect, matching the specification defined in the boundary handling section of the sidebar.

```julia
using DelaunayTriangulation, CairoMakie
pts = [
    (-7.36, 12.55), (-9.32, 8.59), (-9.0, 3.0), (-6.32, -0.27),
    (-4.78, -1.53), (2.78, -1.41), (-5.42, 1.45), (7.86, 0.67),
    (10.92, 0.23), (9.9, 7.39), (8.14, 4.77), (13.4, 8.61),
    (7.4, 12.27), (2.2, 13.85), (-3.48, 10.21), (-4.56, 7.35),
    (3.44, 8.99), (3.74, 5.87), (-2.0, 8.0), (-2.52, 4.81),
    (1.34, 6.77), (1.24, 4.15)
]
boundary_points = [
    (0.0, 0.0), (2.0, 1.0), (3.98, 2.85), (6.0, 5.0),
    (7.0, 7.0), (7.0, 9.0), (6.0, 11.0), (4.0, 12.0),
    (2.0, 12.0), (1.0, 11.0), (0.0, 9.13), (-1.0, 11.0),
    (-2.0, 12.0), (-4.0, 12.0), (-6.0, 11.0), (-7.0, 9.0),
    (-6.94, 7.13), (-6.0, 5.0), (-4.0, 3.0), (-2.0, 1.0), (0.0, 0.0)
]
boundary_nodes, pts = convert_boundary_points_to_indices(boundary_points; existing_points=pts)
uncons_tri = triangulate(pts, delete_ghosts = false)
cons_tri = triangulate(pts; boundary_nodes, delete_ghosts = false)
```

```@raw html
<figure>
    <img src='../figs/heart_constrained.png', alt='Constrained triangulation with a boundary'><br>
</figure>
```

If we wanted to, we could add an edge in after the construction or a point. We would need to add back in the ghost triangles, though, or use `delete_ghosts=false` in `triangulate` (as we did above).

```julia
add_point!(cons_tri, 0.0, 5.0)
add_edge!(cons_tri, 40, 26)
add_edge!(cons_tri, 39, 27)
add_edge!(cons_tri, 38, 28)
add_point!(cons_tri, -3.0, 12.0) # can add points onto segments 
```

```@raw html
<figure>
    <img src='../figs/heart_add_constrained.png', alt='Constrained triangulation with a boundary and additions'><br>
</figure>
```

You do need to be careful not to add segments that intersect each other at an angle, though.

Since we have used just a single boundary, there is just a single boundary index:

```julia-repl
julia> DelaunayTriangulation.all_boundary_indices(cons_tri)
KeySet for a OrderedCollections.OrderedDict{Int64, UnitRange{Int64}} with 1 entry. Keys:
  -1

julia> get_adjacent2vertex(cons_tri, -1)
Set{Tuple{Int64, Int64}} with 21 elements:
  (37, 36)
  (44, 35)
  (35, 34)
  (33, 32)
  (27, 26)
  (36, 44)
  (31, 30)
  (39, 38)
  (24, 23)
  (23, 42)
  (30, 29)
  (42, 41)
  ⋮

julia> get_neighbours(cons_tri, -1)
Set{Int64} with 21 elements:
  35
  30
  28
  24
  37
  23
  32
  41
  44
  36
  31
  39
  ⋮
```

If needed, you can get all the constrained edges using the `all_constrained_edges` field:

```julia-repl 
julia> each_constrained_edge(cons_tri)
Set{Tuple{Int64, Int64}} with 25 elements:
  (23, 24)
  (40, 43)
  (40, 41)
  (26, 43)
  (25, 26)
  (39, 27)
  (30, 31)
  (29, 30)
  (44, 35)
  (42, 23)
  (33, 34)
  (38, 39)
  ⋮
```

which includes all constrained edges, i.e. the boundary edges and the constrained edges we just added. If you just want to iterate over each boundary edge, you could use the `boundary_edge_map`:

```julia-repl
julia> get_boundary_edge_map(cons_tri)
Dict{Tuple{Int64, Int64}, Tuple{Vector{Int64}, Int64}} with 21 entries:
  (23, 24) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 1)
  (40, 41) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 19)
  (25, 26) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 3)
  (35, 44) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 13)
  (30, 31) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 8)
  (29, 30) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 7)
  (42, 23) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 21)
  (33, 34) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 11)
  (38, 39) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 17)
  (27, 28) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 5)
  (26, 27) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 4)
  (39, 40) => ([23, 24, 25, 26, 27, 28, 29, 30, 31, 32  …  35, 44, 36, 37, 38, 39, 40, 41, 42, 23], 18)
  ⋮        => ⋮
```

## Segmented outer boundary 

Now we give an example where we split the boundary into segments, allowing each part of the boundary to be identified separately. For this, we define the boundary nodes on each segment, but making sure the segments connect at the endpoints.

```julia
using DelaunayTriangulation, CairoMakie
points = [
    (2.0, 8.0), (6.0, 4.0), (2.0, 6.0),
    (2.0, 4.0), (8.0, 2.0)
]
segment_1 = [(0.0, 0.0), (14.0, 0.0)]
segment_2 = [(14.0, 0.0), (10.0, 4.0), (4.0, 6.0), (2.0, 12.0), (0.0, 14.0)]
segment_3 = [(0.0, 14.0), (0.0, 0.0)]
boundary_points = [segment_1, segment_2, segment_3]
boundary_nodes, points = convert_boundary_points_to_indices(boundary_points; existing_points=points)
uncons_tri = triangulate(points)
cons_tri = triangulate(points; boundary_nodes)
```

```@raw html
<figure>
    <img src='../figs/triangle_triangulation.png', alt='Constrained triangulation of a dented triangle'><br>
</figure>
```

In this case, we can now identify the bottom, diagonal, and left sides:

```julia-repl
julia> get_adjacent2vertex(cons_tri, -1) # bottom
Set{Tuple{Int64, Int64}} with 1 element:
  (7, 6)

julia> get_adjacent2vertex(cons_tri, -2) # diagonal
Set{Tuple{Int64, Int64}} with 4 elements:
  (10, 9)
  (8, 7)
  (11, 10)
  (9, 8)

julia> get_adjacent2vertex(cons_tri, -3) # left
Set{Tuple{Int64, Int64}} with 1 element:
  (6, 11)
```

The triangulation we've built has few triangles around the boundaries, since we've defined the boundary using few points. We can add more points onto the boundary if we want, being careful not to add points on top of other points, and noting that we need to have ghost triangles to do this. Note also that floating point arithmetic isn't perfect, so some points aren't detected as being on the boundary unfortunately:

```julia
add_ghost_triangles!(cons_tri)
add_ghost_triangles!(uncons_tri)
for x in LinRange(0.1, 13.9, 10) # bottom side
    add_point!(uncons_tri, x, 0.0)
    add_point!(cons_tri, x, 0.0)
end
for x in LinRange(13.9, 10.1, 10) # first part of diagonal
    add_point!(uncons_tri, x, 14 - x)
    add_point!(cons_tri, x, 14 - x)
end
for x in LinRange(9.9, 4.1, 10) # second part of diagonal 
    add_point!(uncons_tri, x, 22 // 3 - x / 3)
    add_point!(cons_tri, x, 22 // 3 - x / 3)
end
for x in LinRange(3.9, 2.1, 10) # third part of diagonal 
    add_point!(uncons_tri, x, 18 - 3x)
    add_point!(cons_tri, x, 18 - 3x)
end
for x in LinRange(1.9, 0.1, 10) # last part of diagonal
    add_point!(uncons_tri, x, 14 - x)
    add_point!(cons_tri, x, 14 - x)
end
for y in LinRange(13.9, 0.1, 10) # left 
    add_point!(uncons_tri, 0.0, y)
    add_point!(cons_tri, 0.0, y)
end
delete_ghost_triangles!(cons_tri)
delete_ghost_triangles!(uncons_tri)
```

```@raw html
<figure>
    <img src='../figs/triangle_triangulation_refined.png', alt='Constrained triangulation of a dented triangle with refinements'><br>
</figure>
```

A better way could be to use e.g. the `split_edge!` operation. This would be better handled by the mesh refinement methods.

## Domain with interior holes 

Now let us consider a domain with interior holes. In this case, the outer boundary should be given counter-clockwise, while the interiors should be clockwise. Additionally, each curve should be given as if it were split into segments, even if there is only a single segment.

```julia
using DelaunayTriangulation, CairoMakie
curve_1 = [[
    (0.0, 0.0), (4.0, 0.0), (8.0, 0.0), (12.0, 0.0), (12.0, 4.0),
    (12.0, 8.0), (14.0, 10.0), (16.0, 12.0), (16.0, 16.0),
    (14.0, 18.0), (12.0, 20.0), (12.0, 24.0), (12.0, 28.0),
    (8.0, 28.0), (4.0, 28.0), (0.0, 28.0), (-2.0, 26.0), (0.0, 22.0),
    (0.0, 18.0), (0.0, 10.0), (0.0, 8.0), (0.0, 4.0), (-4.0, 4.0),
    (-4.0, 0.0), (0.0, 0.0),
]]
curve_2 = [[
    (4.0, 26.0), (8.0, 26.0), (10.0, 26.0), (10.0, 24.0),
    (10.0, 22.0), (10.0, 20.0), (8.0, 20.0), (6.0, 20.0),
    (4.0, 20.0), (4.0, 22.0), (4.0, 24.0), (4.0, 26.0)
]]
curve_3 = [[(4.0, 16.0), (12.0, 16.0), (12.0, 14.0), (4.0, 14.0), (4.0, 16.0)]]
curve_4 = [[(4.0, 8.0), (10.0, 8.0), (8.0, 6.0), (6.0, 6.0), (4.0, 8.0)]]
curves = [curve_1, curve_2, curve_3, curve_4]
points = [
    (2.0, 26.0), (2.0, 24.0), (6.0, 24.0), (6.0, 22.0), (8.0, 24.0), (8.0, 22.0),
    (2.0, 22.0), (0.0, 26.0), (10.0, 18.0), (8.0, 18.0), (4.0, 18.0), (2.0, 16.0),
    (2.0, 12.0), (6.0, 12.0), (2.0, 8.0), (2.0, 4.0), (4.0, 2.0),
    (-2.0, 2.0), (4.0, 6.0), (10.0, 2.0), (10.0, 6.0), (8.0, 10.0), (4.0, 10.0),
    (10.0, 12.0), (12.0, 12.0), (14.0, 26.0), (16.0, 24.0), (18.0, 28.0),
    (16.0, 20.0), (18.0, 12.0), (16.0, 8.0), (14.0, 4.0), (14.0, -2.0),
    (6.0, -2.0), (2.0, -4.0), (-4.0, -2.0), (-2.0, 8.0), (-2.0, 16.0),
    (-4.0, 22.0), (-4.0, 26.0), (-2.0, 28.0), (6.0, 15.0), (7.0, 15.0),
    (8.0, 15.0), (9.0, 15.0), (10.0, 15.0), (6.2, 7.8),
    (5.6, 7.8), (5.6, 7.6), (5.6, 7.4), (6.2, 7.4), (6.0, 7.6),
    (7.0, 7.8), (7.0, 7.4)]
boundary_nodes, points = convert_boundary_points_to_indices(curves; existing_points=points)
uncons_tri = triangulate(points)
cons_tri = triangulate(points; boundary_nodes=boundary_nodes)
```

```@raw html
<figure>
    <img src='../figs/multiply_connected.png', alt='Constrained triangulation of a multiply-connected domain'><br>
</figure>
```

## More complex geometries

It is possible to represent more complex geometries than those above. While the package assumes that boundaries are continguous boundaries, segmented contiguous boundaries, or an outer boundary with interior holes that themselves have no interior holes, e.g. for point location, we can still construct them. If you are only going to use the mesh without worrying about adding points or further edges, this works great.

### Interior holes within interiors

Let us give an example which has interiors within interiors. This can be represented by swapping the orientation of an interior to be counter-clockwise.

```julia
curve_1 = [
    [(0.0, 0.0), (5.0, 0.0), (10.0, 0.0), (15.0, 0.0), (20.0, 0.0), (25.0, 0.0)],
    [(25.0, 0.0), (25.0, 5.0), (25.0, 10.0), (25.0, 15.0), (25.0, 20.0), (25.0, 25.0)],
    [(25.0, 25.0), (20.0, 25.0), (15.0, 25.0), (10.0, 25.0), (5.0, 25.0), (0.0, 25.0)],
    [(0.0, 25.0), (0.0, 20.0), (0.0, 15.0), (0.0, 10.0), (0.0, 5.0), (0.0, 0.0)]
] # outer-most boundary: counter-clockwise  
curve_2 = [
    [(4.0, 6.0), (4.0, 14.0), (4.0, 20.0), (18.0, 20.0), (20.0, 20.0)],
    [(20.0, 20.0), (20.0, 16.0), (20.0, 12.0), (20.0, 8.0), (20.0, 4.0)],
    [(20.0, 4.0), (16.0, 4.0), (12.0, 4.0), (8.0, 4.0), (4.0, 4.0), (4.0, 6.0)]
] # inner boundary: clockwise 
curve_3 = [
    [(12.906, 10.912), (16.0, 12.0), (16.16, 14.46), (16.29, 17.06),
    (13.13, 16.86), (8.92, 16.4), (8.8, 10.9), (12.906, 10.912)]
] # this is inside curve_2, so it's counter-clockwise 
curves = [curve_1, curve_2, curve_3]
points = [
    (3.0, 23.0), (9.0, 24.0), (9.2, 22.0), (14.8, 22.8), (16.0, 22.0),
    (23.0, 23.0), (22.6, 19.0), (23.8, 17.8), (22.0, 14.0), (22.0, 11.0),
    (24.0, 6.0), (23.0, 2.0), (19.0, 1.0), (16.0, 3.0), (10.0, 1.0), (11.0, 3.0),
    (6.0, 2.0), (6.2, 3.0), (2.0, 3.0), (2.6, 6.2), (2.0, 8.0), (2.0, 11.0),
    (5.0, 12.0), (2.0, 17.0), (3.0, 19.0), (6.0, 18.0), (6.5, 14.5),
    (13.0, 19.0), (13.0, 12.0), (16.0, 8.0), (9.8, 8.0), (7.5, 6.0),
    (12.0, 13.0), (19.0, 15.0)
]
boundary_nodes, points = convert_boundary_points_to_indices(curves; existing_points=points)
```

When we try and triangulate this, we get an error:

```julia
cons_tri = triangulate(points; boundary_nodes=boundary_nodes)
ERROR: AssertionError: The 3rd boundary curve is counter-clockwise when it should be clockwise. If this is a mistake, e.g. if this curve is inside of another one in which case it should be counter-clockwise, recall triangulate with check_arguments = false.
Stacktrace:
 [1] check_args(points::Vector{Tuple{Float64, Float64}}, boundary_nodes::Vector{Vector{Vector{Int64}}})
   @ DelaunayTriangulation c:\Users\User\.julia\dev\DelaunayTriangulation\src\utils.jl:515
 [2] triangulate(points::Vector{Tuple{Float64, Float64}}; edges::Nothing, boundary_nodes::Vector{Vector{Vector{Int64}}}, IntegerType::Type{Int64}, EdgeType::Type{Tuple{Int64, Int64}}, TriangleType::Type{Tuple{Int64, Int64, Int64}}, EdgesType::Type{Set{Tuple{Int64, Int64}}}, TrianglesType::Type{Set{Tuple{Int64, Int64, Int64}}}, randomise::Bool, delete_ghosts::Bool, delete_empty_features::Bool, try_last_inserted_point::Bool, skip_points::Set{Int64}, num_sample_rule::typeof(DelaunayTriangulation.default_num_samples), rng::TaskLocalRNG, point_order::Vector{Int64}, recompute_representative_point::Bool, delete_holes::Bool, check_arguments::Bool)
   @ DelaunayTriangulation c:\Users\User\.julia\dev\DelaunayTriangulation\src\triangulation\triangulate.jl:69
 [3] top-level scope
   @ Untitled-1:198
```

We have this as a default to try and make the process a bit simpler for the most common geometries. A workaround though, as suggested, is to no longer check the arguments.

```julia
uncons_tri = triangulate(points)
cons_tri = triangulate(points; boundary_nodes=boundary_nodes, check_arguments=false)
```

```@raw html
<figure>
    <img src='../figs/multiply_connected_interior_interior.png', alt='Constrained triangulation of a multiply-connected domain with holes inside holes'><br>
</figure>
```

### Disjoint domains 

Now let's give a more complex example, where we consider multiple disjoint domains. This is the domain that is furthest from being supported, and I'm not sure whether proper support for it is planned. (Perhaps the best way to represent it is via something like a `UnionTriangulation` type, storing the triangulation information for each domain? Maybe.) The way to do it is to simply treat each domain as you would a standard domain, with the outer boundary being counter-clockwise, interiors clockwise (and other interiors inside interiors counter-clockwise, if you so please). The `delete_holes!` function will handle everything.

First, a simple example.

```julia
θ = LinRange(0, 2π, 20) |> collect
θ[end] = 0 # need to make sure that 2π gives the exact same coordinates as 0
xy = Vector{Vector{Vector{NTuple{2,Float64}}}}()
cx = 0.0
for i in 1:2
    # Make the exterior circle
    push!(xy, [[(cx + cos(θ), sin(θ)) for θ in θ]])
    # Now the interior circle - clockwise
    push!(xy, [[(cx + 0.5cos(θ), 0.5sin(θ)) for θ in reverse(θ)]])
    cx += 3.0
end
boundary_nodes, points = convert_boundary_points_to_indices(xy)
uncons_tri = triangulate(points)
cons_tri = triangulate(points; boundary_nodes=boundary_nodes, check_arguments=false)
```

```@raw html
<figure>
    <img src='../figs/simple_disjoint.png', alt='Simple example with two separated circles'><br>
</figure>
```

Here's a more cheeky example.

```julia
C = (15.7109521325776, 33.244486807457)
D = (14.2705719699703, 32.8530791545746)
E = (14.3, 27.2)
F = (14.1, 27.0)
G = (13.7, 27.2)
H = (13.4, 27.5)
I = (13.1, 27.6)
J = (12.7, 27.4)
K = (12.5, 27.1)
L = (12.7, 26.7)
M = (13.1, 26.5)
N = (13.6, 26.4)
O = (14.0, 26.4)
P = (14.6, 26.5)
Q = (15.1983491346581, 26.8128534095401)
R = (15.6, 27.6)
S = (15.6952958264624, 28.2344688505621)
T = (17.8088971520274, 33.1192363585346)
U = (16.3058917649589, 33.0722674401887)
V = (16.3215480710742, 29.7374742376305)
W = (16.3841732955354, 29.393035503094)
Z = (16.6190178872649, 28.9233463196351)
A1 = (17.0417381523779, 28.5319386667527)
B1 = (17.5114273358368, 28.3753756055997)
C1 = (18.1376795804487, 28.3597192994844)
D1 = (18.7169629067146, 28.5632512789833)
E1 = (19.2805899268653, 28.8920337074045)
F1 = (19.26493362075, 28.4536571361762)
G1 = (20.6426885588962, 28.4223445239456)
H1 = (20.689657477242, 33.1035800524193)
I1 = (19.2805899268653, 33.0722674401887)
J1 = (19.2962462329806, 29.7531305437458)
K1 = (19.0614016412512, 29.393035503094)
L1 = (18.7482755189452, 29.236472441941)
M1 = (18.4508057027546, 29.1425346052493)
N1 = (18.1689921926793, 29.3147539725175)
O1 = (17.7932408459121, 29.6278800948235)
P1 = (22.6466957416542, 35.4207133574833)
Q1 = (21.2219718851621, 34.9979930923702)
R1 = (21.2376281912774, 28.4693134422915)
S1 = (22.6780083538847, 28.4380008300609)
T1 = (24.5724213938357, 33.1975178891111)
U1 = (23.3512295168425, 32.8530791545746)
V1 = (23.3199169046119, 28.4380008300609)
W1 = (24.6663592305274, 28.3753756055997)
Z1 = (15.1942940307729, 35.4363696635986)
A2 = (14.7246048473139, 35.3737444391374)
B2 = (14.3645098066621, 35.1858687657538)
C2 = (14.1766341332786, 34.8570863373326)
D2 = (14.1140089088174, 34.3247719294125)
E2 = (14.2705719699703, 33.8394264398383)
F2 = (14.7246048473139, 33.6202381542241)
G2 = (15.4604512347329, 33.6045818481088)
H2 = (16.0, 34.0)
I2 = (15.9771093365377, 34.6848669700643)
J2 = (15.6170142958859, 35.2328376840997)
K2 = (24.1653574348379, 35.4520259697138)
L2 = (23.7739497819555, 35.4363696635986)
M2 = (23.4608236596496, 35.2641502963303)
N2 = (23.272947986266, 34.9040552556785)
O2 = (23.1320412312284, 34.5909291333725)
P2 = (23.1163849251131, 34.2151777866054)
Q2 = (23.2886042923813, 33.8081138276077)
R2 = (23.8209187003014, 33.6045818481088)
S2 = (24.3062641898756, 33.5576129297629)
T2 = (24.7602970672192, 33.8550827459536)
U2 = (25.010797965064, 34.4656786844502)
V2 = (24.8385785977957, 34.9666804801397)
W2 = (24.5254524754898, 35.2641502963303)
Z2 = (25.3708930057158, 37.4716894585871)
A3 = (24.7916096794498, 37.3464390096648)
B3 = (24.4471709449133, 36.9550313567823)
C3 = (24.3062641898756, 36.5636237038999)
D3 = (24.4941398632592, 35.9999966837492)
E3 = (25.0264542711793, 35.5929327247515)
F3 = (25.5587686790994, 35.5929327247515)
F3 = (25.5587686790994, 35.5929327247515)
G3 = (26.0, 36.0)
H3 = (26.1380520053653, 36.5792800100152)
I3 = (26.0, 37.0)
J3 = (25.7466443524829, 37.2838137852036)
K3 = (26.3885529032101, 35.4676822758291)
L3 = (25.9814889442124, 35.3580881330221)
M3 = (25.6840191280217, 35.1858687657538)
N3 = (25.5274560668688, 34.9040552556785)
O3 = (25.4961434546382, 34.5596165211419)
P3 = (25.5274560668688, 34.246490398836)
Q3 = (25.6683628219064, 33.8394264398383)
R3 = (26.0284578625583, 33.6358944603394)
S3 = (26.5451159643631, 33.6202381542241)
T3 = (27.0, 34.0)
U3 = (27.280962351782, 34.5596165211419)
V3 = (27.0304614539373, 35.2171813779844)
W3 = (26.1693646175959, 33.087923746304)
Z3 = (26.0, 33.0)
A4 = (25.5274560668688, 32.7278287056522)
B4 = (25.2612988629087, 32.4147025833463)
C4 = (25.1830173323322, 32.0702638488098)
D4 = (25.2299862506781, 31.7727940326191)
E4 = (25.6527065157911, 31.5222931347744)
F4 = (26.2946150665183, 31.7258251142732)
G4 = (26.5607722704784, 32.5086404200381)
H4 = (27.1557119028596, 32.7434850117675)
I4 = (27.6097447802033, 32.4929841139228)
J4 = (27.6410573924338, 32.1015764610403)
K4 = (27.7193389230103, 31.6005746653509)
L4 = (27.437525412935, 31.4283552980826)
M4 = (26.9834925355914, 31.2561359308143)
N4 = (26.5764285765937, 31.0995728696614)
O4 = (26.0441141686736, 30.7864467473554)
P4 = (25.6527065157911, 30.5672584617413)
Q4 = (25.3239240873699, 30.1915071149741)
R4 = (25.1673610262169, 29.8783809926682)
S4 = (25.1047358017558, 29.6122237887082)
T4 = (25.0890794956405, 29.1895035235952)
U4 = (25.2926114751393, 28.8294084829433)
V4 = (25.6840191280217, 28.5632512789833)
W4 = (26.1537083114806, 28.3753756055997)
Z4 = (26.8269294744384, 28.391031911715)
A5 = (27.4844943312809, 28.6102201973292)
B5 = (27.7342002330051, 28.7239579596219)
C5 = (27.7264126450755, 28.4202565942047)
D5 = (29.1825559185446, 28.3922538389457)
E5 = (29.1545531632856, 32.2146299318021)
F5 = (29.000538009361, 32.5786657501693)
G5 = (28.6785063238822, 32.9006974356481)
H5 = (28.3144705055149, 33.0827153448317)
I5 = (27.9084305542591, 33.2367304987563)
J5 = (27.3343740714492, 33.3207387645334)
K5 = (26.8303244767868, 33.2367304987563)
L5 = (27.6564057569279, 30.786489413592)
M5 = (27.6984098898165, 30.3944508399657)
N5 = (27.6984098898165, 29.7363860913787)
O5 = (27.5863988687804, 29.4143544059)
P5 = (27.2643671833016, 29.2043337414573)
Q5 = (26.9843396307114, 29.1763309861983)
R5 = (26.6903107004917, 29.3163447624934)
S5 = (26.5782996794556, 29.7503874690082)
T5 = (26.7603175886393, 30.3384453294476)
U5 = (27.3203726938197, 30.7024811478149)

J_curve = [[C, D, E, F, G, H, I, J, K, L, M, N, O, P, Q, R, S, C]]
U_curve = [[T, U, V, W, Z, A1, B1, C1, D1, E1, F1, G1, H1, I1, J1, K1, L1, M1, N1, O1, T]]
L_curve = [[P1, Q1, R1, S1, P1]]
I_curve = [[T1, U1, V1, W1, T1]]
A_curve_outline = [[
    K5, W3, Z3, A4, B4, C4, D4, E4, F4, G4, H4, I4, J4, K4, L4, M4, N4,
    O4, P4, Q4, R4, S4, T4, U4, V4, W4, Z4, A5, B5, C5, D5, E5, F5, G5,
    H5, I5, J5, K5]]
A_curve_hole = [[L5, M5, N5, O5, P5, Q5, R5, S5, T5, U5, L5]]
dot_1 = [[Z1, A2, B2, C2, D2, E2, F2, G2, H2, I2, J2, Z1]]
dot_2 = [[Z2, A3, B3, C3, D3, E3, F3, G3, H3, I3, J3, Z2]]
dot_3 = [[K2, L2, M2, N2, O2, P2, Q2, R2, S2, T2, U2, V2, W2, K2]]
dot_4 = [[K3, L3, M3, N3, O3, P3, Q3, R3, S3, T3, U3, V3, K3]]
curves = [J_curve, U_curve, L_curve, I_curve, A_curve_outline, A_curve_hole, dot_1, dot_2, dot_3, dot_4]
nodes, points = convert_boundary_points_to_indices(curves)
uncons_tri = triangulate(points)
cons_tri = triangulate(points; boundary_nodes = nodes, check_arguments = false)
```

```@raw html
<figure>
    <img src='../figs/julia.png', alt='Julia logo'><br>
</figure>
```