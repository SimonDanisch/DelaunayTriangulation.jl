using ..DelaunayTriangulation
const DT = DelaunayTriangulation
using CairoMakie
include("../helper_functions.jl")

#=
fig, ax, sc = triplot(tri)
let vert = each_solid_vertex(tri)
    text!(ax, collect(get_point(tri, vert...)); text=string.(vert))
end
lines!(ax, [get_point(tri, 2, 7)...], color=:blue, linestyle=:dash)
fig
=#

@testset "Shewchuk Example: A small example with some collinearities" begin
    tri = shewchuk_example_constrained()
    @testset "locate_intersecting_triangles" begin
        e = [(2, 7), (2, 10), (4, 11), (1, 6), (3, 11), (1, 3), (3, 6)]
        allT = [
            [(2, 4, 3), (3, 4, 10), (10, 4, 9), (9, 5, 10), (5, 8, 10), (5, 6, 8), (8, 6, 7)],
            [(2, 4, 3), (3, 4, 10)],
            [(4, 9, 10), (10, 9, 5), (10, 5, 8), (10, 8, 11)],
            [(1, 4, 2), (4, 5, 9), (5, 6, 8)],
            [(3, 4, 10), (10, 8, 11)],
            [(3, 2, 4), (2, 1, 4)],
            [(3, 4, 10), (10, 4, 9), (10, 9, 5), (8, 5, 6), (5, 8, 10)]
        ]
        collinear = [
            [],
            [],
            [],
            [(1, 4), (4, 5), (5, 6)],
            ([(11, 10), (10, 3)], [(3, 10), (10, 11)]),
            [(1, 2), (2, 3)],
            []
        ]
        for _ in 1:250
            for (edge, tris, edges) in zip(e, allT, collinear)
                test_intersections(tri, edge, tris, edges)
            end
        end
    end

    @testset "split_constrained_edge!" begin
        e = [(1, 6), (1, 3), (3, 11), (11, 6)]
        constrained_edge_progression = [
            (Set(((1, 4), (4, 5), (5, 6))),),
            (Set(((1, 4), (4, 5), (5, 6), (1, 2), (2, 3))),),
            (Set(((1, 4), (4, 5), (5, 6), (1, 2), (2, 3), (3, 10), (10, 11))), Set(((1, 4), (4, 5), (5, 6), (1, 2), (2, 3), (11, 10), (10, 3)))),
            (Set(((1, 4), (4, 5), (5, 6), (1, 2), (2, 3), (3, 10), (10, 11), (11, 7), (7, 6))), Set(((1, 4), (4, 5), (5, 6), (1, 2), (2, 3), (11, 10), (10, 3), (11, 7), (7, 6))))
        ]
        for _ in 1:250
            tri = shewchuk_example_constrained()
            constrained_edges = get_constrained_edges(tri)
            for (edge, current_constrained_edges) in zip(e, constrained_edge_progression)
                test_split_edges(tri, edge, current_constrained_edges)
            end
        end
    end

    @testset "Locating polygon cavities" begin
        tri = fixed_shewchuk_example_constrained()
        T, C, L, R = DT.locate_intersecting_triangles(tri, (2, 7))
        @test L == [7, 8, 10, 9, 10, 3, 2]
        @test R == [2, 4, 5, 6, 7]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (1, 11))
        @test L == [11, 10, 3, 2, 1]
        @test R == [1, 4, 9, 5, 8, 11]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (8, 9))
        @test L == [8, 10, 9]
        @test R == [9, 5, 8]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (9, 7))
        @test L == [7, 8, 10, 9]
        @test R == [9, 5, 6, 7]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (3, 9))
        @test L == [3, 4, 9]
        @test R == [9, 10, 3]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (2, 8))
        @test L == [8, 10, 9, 10, 3, 2]
        @test R == [2, 4, 5, 8]
    end
end

@testset "Lattice Example" begin
    @testset "Segment location in a lattice" begin
        e = Vector{Any}(undef, 13)
        crossed_triangles = Vector{Any}(undef, 13)
        constrained_edges = Vector{Any}(undef, 13)
        collinear_segments = Vector{Any}(undef, 13)

        e[1] = (7, 28)
        _T1 = [(7, 8, 12), (12, 8, 13), (17, 12, 13), (17, 13, 18), (22, 17, 18), (22, 18, 23), (27, 22, 23), (27, 23, 28)]
        crossed_triangles[1] = (_T1, reverse(_T1))
        constrained_edges[1] = Set{NTuple{2,Int64}}((e[1],))
        collinear_segments[1] = NTuple{2,Int64}[]

        e[2] = (44, 21)
        crossed_triangles[2] = [(21, 22, 26), (26, 22, 27), (31, 26, 27), (31, 27, 32), (32, 27, 28), (32, 28, 33), (37, 32, 33), (37, 33, 38), (38, 33, 34), (38, 34, 39), (43, 38, 39), (43, 39, 44)]
        constrained_edges[2] = Set{NTuple{2,Int64}}((e[1], e[2]))
        collinear_segments[2] = NTuple{2,Int64}[]

        e[3] = (8, 14)
        crossed_triangles[3] = ([(13, 8, 9), (13, 9, 14)], [(13, 9, 14), (13, 8, 9)])
        constrained_edges[3] = Set{NTuple{2,Int64}}((e[1], e[2], e[3]))
        collinear_segments[3] = NTuple{2,Int64}[]

        e[4] = (1, 50)
        _T4 = [(6, 1, 2), (6, 2, 7), (11, 6, 7), (11, 7, 12), (16, 11, 12), (16, 12, 17), (17, 12, 13), (17, 13, 18), (22, 17, 18), (22, 18, 23), (27, 22, 23), (27, 23, 28), (28, 23, 24), (28, 24, 29), (33, 28, 29), (33, 29, 34), (38, 33, 34), (38, 34, 39), (39, 34, 35), (39, 35, 40), (44, 39, 40), (44, 40, 45), (49, 44, 45), (49, 45, 50)]
        crossed_triangles[4] = (_T4, reverse(_T4))
        constrained_edges[4] = Set{NTuple{2,Int64}}((e[1], e[2], e[3], e[4]))
        collinear_segments[4] = NTuple{2,Int64}[]

        e[5] = (47, 4)
        _T5 = [(47, 42, 43), (42, 38, 43), (42, 37, 38), (38, 37, 33), (37, 32, 33), (32, 28, 33), (32, 27, 28), (27, 23, 28), (28, 23, 24), (23, 19, 24), (23, 18, 19), (18, 14, 19), (18, 13, 14), (13, 9, 14), (13, 8, 9), (8, 4, 9)]
        crossed_triangles[5] = (_T5, reverse(_T5))
        constrained_edges[5] = Set{NTuple{2,Int64}}((e[1], e[2], e[3], e[4], e[5]))
        collinear_segments[5] = NTuple{2,Int64}[]

        e[6] = (17, 24)
        _T6 = [(22, 17, 18), (22, 18, 23), (23, 18, 19), (23, 19, 24)]
        crossed_triangles[6] = (_T6, reverse(_T6))
        constrained_edges[6] = Set{NTuple{2,Int64}}((e[1], e[2], e[3], e[4], e[5], e[6]))
        collinear_segments[6] = NTuple{2,Int64}[]

        e[7] = (17, 27)
        _T7a = [(22, 21, 17), (21, 22, 26), (26, 22, 27)]
        _T7b = [(18, 22, 17), (22, 18, 23), (22, 23, 27)]
        _T7c = [(22, 23, 27), (23, 22, 18), (18, 22, 17)]
        _T7d = [(26, 22, 27), (22, 26, 21), (22, 21, 17)]
        crossed_triangles[7] = (_T7a, _T7b, _T7c, _T7d)
        constrained_edges[7] = Set{NTuple{2,Int64}}((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17)))
        collinear_segments[7] = ([(27, 22), (22, 17)], [(17, 22), (22, 27)])

        e[8] = (32, 24)
        _T8a = [(27, 28, 32), (28, 27, 23), (28, 23, 24)]
        _T8b = [(28, 33, 32), (33, 28, 29), (29, 28, 24)]
        crossed_triangles[8] = (_T8a, _T8b, reverse(_T8a), reverse(_T8b))
        constrained_edges[8] = Set((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17), (32, 28), (28, 24)))
        collinear_segments[8] = ([(32, 28), (28, 24)], [(24, 28), (28, 32)])

        e[9] = (2, 12)
        crossed_triangles[9] = [(3, 7, 2), (7, 3, 8), (7, 8, 12)]
        constrained_edges[9] = Set((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17), (32, 28), (28, 24), (2, 7), (7, 12)))
        collinear_segments[9] = [(2, 7), (7, 12)]

        e[10] = (6, 26)
        _T10 = [(11, 6, 7), (16, 11, 12), (21, 16, 17), (26, 21, 22)]
        crossed_triangles[10] = (_T10, reverse(_T10))
        constrained_edges[10] = Set((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17), (32, 28), (28, 24), (2, 7), (7, 12), (26, 21), (21, 16), (16, 11), (11, 6)))
        collinear_segments[10] = ([(6, 11), (11, 16), (16, 21), (21, 26)], [(26, 21), (21, 16), (16, 11), (11, 6)])

        e[11] = (46, 30)
        crossed_triangles[11] = (Set([(37, 42, 41), (35, 34, 30), (34, 39, 38), (34, 38, 33), (34, 35, 39), (42, 37, 38), (41, 42, 46)]), Set([(35, 34, 30), (34, 39, 38), (34, 38, 33), (34, 35, 39), (43, 42, 38), (42, 43, 47), (42, 47, 46)]), [(41, 42, 46), (42, 41, 37), (42, 37, 38), (42, 38, 43), (33, 34, 38), (34, 33, 29), (34, 29, 30)], [(41, 42, 46), (42, 41, 37), (42, 37, 38), (42, 38, 43), (34, 39, 38), (39, 34, 35), (35, 34, 30)], Set([(39, 34, 35), (42, 38, 43), (35, 34, 30), (39, 33, 34), (42, 41, 37), (42, 37, 38), (33, 39, 38), (41, 42, 46)]))
        constrained_edges[11] = Set((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17), (32, 28), (28, 24), (2, 7), (7, 12), (26, 21), (21, 16), (16, 11), (11, 6), (46, 42), (42, 38), (38, 34), (34, 30)))
        collinear_segments[11] = ([(30, 34), (34, 38), (38, 42), (42, 46)], [(46, 42), (42, 38), (38, 34), (34, 30)])

        e[12] = (31, 35)
        _T12a = [(27, 32, 31), (32, 27, 28), (32, 28, 33), (32, 33, 37), (34, 38, 33), (38, 34, 39), (39, 34, 35)]
        _T12b = [(27, 32, 31), (32, 27, 28), (32, 28, 33), (32, 33, 37), (29, 34, 33), (34, 29, 30), (34, 30, 35)]
        _T12c = Set([(39, 34, 35), (27, 32, 31), (34, 39, 38), (28, 32, 27), (34, 38, 33), (34, 33, 29), (32, 28, 33)])
        _T12d = Set([(32, 36, 31), (39, 34, 35), (34, 39, 38), (32, 37, 36), (37, 32, 33), (34, 38, 33), (34, 33, 29)])
        crossed_triangles[12] = (_T12a, _T12b, _T12c, _T12d)
        collinear_segments[12] = ([(31, 32), (32, 33), (33, 34), (34, 35)], [(35, 34), (34, 33), (33, 32), (32, 31)])
        constrained_edges[12] = Set((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17), (32, 28), (28, 24), (2, 7), (7, 12), (26, 21), (21, 16), (16, 11), (11, 6), (46, 42), (42, 38), (38, 34), (34, 30), (31, 32), (32, 33), (33, 34), (34, 35)))

        e[13] = (18, 10)
        crossed_triangles[13] = [(15, 14, 10), (14, 15, 19), (14, 19, 18)]
        constrained_edges[13] = Set((e[1], e[2], e[3], e[4], e[5], e[6], (27, 22), (22, 17), (32, 28), (28, 24), (2, 7), (7, 12), (26, 21), (21, 16), (16, 11), (11, 6), (46, 42), (42, 38), (38, 34), (34, 30), (31, 32), (32, 33), (33, 34), (34, 35), (10, 14), (14, 18)))
        collinear_segments[13] = [(10, 14), (14, 18)]

        a, b = 0, 4
        c, d = 0.0, 9.0
        nx, ny = 5, 10
        for _ in 1:250
            tri = triangulate_rectangle(a, b, c, d, nx, ny)
            for (j, (e, T, cs, c)) in enumerate(zip(e, crossed_triangles, collinear_segments, constrained_edges))
                test_segment_triangle_intersections(tri, e, T, cs, c)
            end
        end
    end

    @testset "Segment location in a lattice with constrained edges going between collinear and non-collinear segments" begin
        a, b = 0, 4
        c, d = 0.0, 9.0
        nx, ny = 5, 10
        tri = triangulate_rectangle(a, b, c, d, nx, ny)
        DT.flip_edge!(tri, 34, 38)
        DT.flip_edge!(tri, 2, 7)
        DT.flip_edge!(tri, 5, 9)
        DT.flip_edge!(tri, 22, 27)
        DT.flip_edge!(tri, 27, 32)
        DT.flip_edge!(tri, 33, 37)
        DT.flip_edge!(tri, 9, 14)
        DT.flip_edge!(tri, 14, 19)
        DT.flip_edge!(tri, 29, 34)

        e = Vector{Any}(undef, 6)
        crossed_triangles = Vector{Any}(undef, 6)
        constrained_edges = Vector{Any}(undef, 6)
        collinear_segments = Vector{Any}(undef, 6)

        e[1] = (2, 47)
        _T1a = Set([(11, 7, 12), (6, 3, 7), (23, 26, 22), (17, 18, 22), (3, 6, 2), (42, 41, 37), (12, 7, 8), (37, 32, 38), (31, 28, 32), (41, 42, 46), (31, 27, 28), (46, 42, 47), (13, 17, 12), (36, 32, 37), (6, 7, 11), (17, 13, 18), (31, 32, 36), (17, 22, 21), (26, 27, 31), (26, 23, 27)])
        _T1b = Set([(11, 7, 12), (6, 3, 7), (23, 26, 22), (3, 6, 2), (38, 42, 37), (12, 7, 8), (37, 32, 38), (42, 38, 43), (31, 28, 32), (17, 16, 12), (22, 17, 18), (31, 27, 28), (36, 32, 37), (42, 43, 47), (6, 7, 11), (21, 17, 22), (31, 32, 36), (26, 27, 31), (16, 17, 21), (26, 23, 27)])
        _T1c = Set([(11, 7, 12), (6, 3, 7), (23, 26, 22), (17, 18, 22), (3, 6, 2), (38, 42, 37), (12, 7, 8), (37, 32, 38), (42, 38, 43), (31, 28, 32), (31, 27, 28), (13, 17, 12), (36, 32, 37), (42, 43, 47), (6, 7, 11), (17, 13, 18), (31, 32, 36), (17, 22, 21), (26, 27, 31), (26, 23, 27)])
        _T1d = Set([(11, 7, 12), (6, 3, 7), (23, 26, 22), (42, 41, 37), (3, 6, 2), (12, 7, 8), (37, 32, 38), (31, 28, 32), (41, 42, 46), (17, 16, 12), (22, 17, 18), (31, 27, 28), (46, 42, 47), (36, 32, 37), (6, 7, 11), (21, 17, 22), (31, 32, 36), (26, 27, 31), (16, 17, 21), (26, 23, 27)])
        crossed_triangles[1] = (_T1a, _T1b, _T1c, _T1d)
        collinear_segments[1] = [(2, 7), (7, 12), (12, 17), (17, 22), (22, 27), (27, 32), (32, 37), (37, 42), (42, 47)]
        constrained_edges[1] = [(7, 12), (12, 17), (17, 22), (22, 27), (27, 32), (32, 37), (37, 42), (42, 47), (2, 7)] |> unique

        e[2] = (4, 49)
        _T2a = Set([(9, 8, 4), (10, 13, 9), (23, 19, 24), (44, 48, 43), (33, 34, 39), (14, 18, 13), (44, 43, 39), (15, 18, 14), (48, 44, 49), (29, 24, 25), (19, 23, 18), (30, 33, 29), (44, 39, 40), (29, 33, 28), (29, 28, 24), (34, 33, 30), (14, 13, 10), (9, 13, 8), (19, 18, 15)])
        _T2b = Set([(10, 13, 9), (44, 48, 43), (30, 34, 33), (44, 43, 39), (24, 29, 28), (15, 14, 10), (35, 34, 30), (15, 18, 14), (48, 44, 49), (34, 35, 39), (25, 29, 24), (30, 33, 29), (44, 39, 40), (19, 20, 24), (20, 19, 15), (10, 14, 13), (30, 29, 25), (10, 9, 4), (15, 19, 18)])
        _T2c = Set([(10, 13, 9), (44, 48, 43), (33, 34, 39), (44, 43, 39), (15, 14, 10), (15, 18, 14), (48, 44, 49), (29, 24, 25), (30, 33, 29), (44, 39, 40), (29, 33, 28), (29, 28, 24), (19, 20, 24), (34, 33, 30), (20, 19, 15), (10, 14, 13), (10, 9, 4), (15, 19, 18)])
        _T2d = Set([(9, 8, 4), (10, 13, 9), (23, 19, 24), (44, 48, 43), (30, 34, 33), (14, 18, 13), (44, 43, 39), (24, 29, 28), (35, 34, 30), (15, 18, 14), (48, 44, 49), (34, 35, 39), (19, 23, 18), (25, 29, 24), (30, 33, 29), (44, 39, 40), (14, 13, 10), (30, 29, 25), (9, 13, 8), (19, 18, 15)])
        crossed_triangles[2] = (_T2a, _T2b, _T2c, _T2d)
        collinear_segments[2] = [(49, 44), (44, 39), (39, 34), (34, 29), (29, 24), (24, 19), (19, 14), (14, 9), (9, 4)]
        constrained_edges[2] = append!(constrained_edges[1] |> copy, collinear_segments[2]) |> unique

        e[3] = (29, 37)
        _T3a = Set([(38, 32, 33), (30, 33, 29), (32, 38, 37), (39, 33, 34), (34, 33, 30), (38, 33, 39)])
        _T3b = Set([(33, 38, 32), (30, 33, 29), (33, 34, 39), (32, 38, 37), (33, 30, 34), (33, 39, 38)])
        _T3c = Set([(28, 33, 32), (32, 38, 37), (33, 28, 29), (32, 33, 38)])
        crossed_triangles[3] = (_T3a, _T3b, _T3c)
        collinear_segments[3] = ([(37, 33), (33, 29)], [(29, 33), (33, 37)])
        constrained_edges[3] = append!(constrained_edges[2] |> copy, collinear_segments[3][1]) |> unique

        e[4] = (2, 32)
        _T4a = Set([(11, 7, 12), (6, 3, 7), (23, 26, 22), (3, 6, 2), (12, 7, 8), (31, 28, 32), (17, 16, 12), (22, 17, 18), (31, 27, 28), (6, 7, 11), (21, 17, 22), (26, 27, 31), (16, 17, 21), (26, 23, 27)])
        _T4b = Set([(11, 7, 12), (6, 3, 7), (23, 26, 22), (17, 18, 22), (3, 6, 2), (12, 7, 8), (31, 28, 32), (31, 27, 28), (13, 17, 12), (6, 7, 11), (17, 13, 18), (17, 22, 21), (26, 27, 31), (26, 23, 27)])
        crossed_triangles[4] = (_T4a, _T4b)
        collinear_segments[4] = [(2, 7), (7, 12), (12, 17), (17, 22), (22, 27), (27, 32)]
        constrained_edges[4] = append!(constrained_edges[3] |> copy, collinear_segments[4]) |> unique

        e[5] = (5, 13)
        _T5a = Set([(8, 9, 13), (4, 10, 9), (10, 4, 5), (4, 9, 8)])
        crossed_triangles[5] = Set([(8, 9, 13), (4, 10, 9), (10, 4, 5), (4, 9, 8)])
        collinear_segments[5] = [(5, 9), (9, 13)]
        constrained_edges[5] = append!(constrained_edges[4] |> copy, collinear_segments[5]) |> unique

        e[6] = (3, 20)
        _T6 = Set([(18, 22, 17), (23, 18, 19), (23, 19, 24), (22, 18, 23)])
        crossed_triangles[6] = Set([(10, 13, 9), (15, 18, 14), (19, 15, 20), (4, 8, 3), (9, 13, 8), (15, 19, 18), (10, 14, 13), (15, 14, 10), (9, 8, 4)])
        collinear_segments[6] = []
        constrained_edges[6] = append!(constrained_edges[5] |> copy, collinear_segments[6]) |> unique
        push!(constrained_edges[6], (3, 20))

        for i in 1:250
            tri = triangulate_rectangle(a, b, c, d, nx, ny)
            DT.flip_edge!(tri, 34, 38)
            DT.flip_edge!(tri, 2, 7)
            DT.flip_edge!(tri, 5, 9)
            DT.flip_edge!(tri, 22, 27)
            DT.flip_edge!(tri, 27, 32)
            DT.flip_edge!(tri, 33, 37)
            DT.flip_edge!(tri, 9, 14)
            DT.flip_edge!(tri, 14, 19)
            DT.flip_edge!(tri, 29, 34)
            for (e, T, cs, c) in zip(e, crossed_triangles, collinear_segments, constrained_edges)
                test_segment_triangle_intersections(tri, e, T, cs, c)
            end
        end
    end

    @testset "Locating polygon cavities" begin
        a, b = 0, 4
        c, d = 0.0, 9.0
        nx, ny = 5, 10
        tri = triangulate_rectangle(a, b, c, d, nx, ny)
        T, C, L, R = DT.locate_intersecting_triangles(tri, (2, 8))
        @test L == [8, 7, 2]
        @test R == [2, 3, 8]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (1, 50))
        @test L == [50, 49, 44, 39, 38, 33, 28, 27, 22, 17, 16, 11, 6, 1]
        @test R == [1, 2, 7, 12, 13, 18, 23, 24, 29, 34, 35, 40, 45, 50]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (1, 39))
        @test L == [39, 38, 33, 28, 27, 22, 17, 16, 11, 6, 1]
        @test R == [1, 2, 7, 12, 13, 18, 23, 24, 29, 34, 39]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (7, 38))
        @test L == [38, 37, 32, 27, 22, 17, 12, 7]
        @test R == [7, 8, 13, 18, 23, 28, 33, 38]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (46, 40))
        @test L == [40, 44, 48, 47, 46]
        @test R == [46, 42, 43, 39, 40]
        T, C, L, R = DT.locate_intersecting_triangles(tri, (32, 19))
        @test L == [19, 24, 28, 32]
        @test R == [32, 27, 23, 19]
    end
end

@testset "A previously broken example" begin
    for m in 1:100
        @show m
        a = -0.1
        b = 0.1
        c = -0.01
        d = 0.01
        nx = 25
        ny = 25
        tri = triangulate_rectangle(a, b, c, d, nx, ny; add_ghost_triangles=true, single_boundary=true)
        tri = triangulate(get_points(tri))
        for i in 2:24
            add_edge!(tri, i, 600 + i)
        end
        tri = triangulate_rectangle(a, b, c, d, nx, ny; add_ghost_triangles=true, single_boundary=true)
        tri = triangulate(get_points(tri))
        e = (23, 71)
        history = DT.PointLocationHistory{NTuple{3,Int64},NTuple{2,Int64},Int64}()
        jump_and_march(tri.points, tri.adjacent, tri.adjacent2vertex, tri.graph,
            tri.boundary_index_ranges, DT.get_representative_point_list(tri), tri.boundary_map, get_point(tri, 71);
            m=nothing, k=23, TriangleType=NTuple{3,Int64}, store_history=true, history=history)
        collinear_segments = history.collinear_segments
        DT.connect_segments!(collinear_segments)
        DT.extend_segments!(collinear_segments, e)
        @test collinear_segments == [(23, 47), (47, 71)]
    end
end

@testset "Some other previously broken examples, dealing with segments going through points without passing through segments" begin
    tri = triangulate_rectangle(0, 5, 0, 10, 6, 11; add_ghost_triangles=true)
    e = (14, 40)
    history = DT.PointLocationHistory{NTuple{3,Int64},NTuple{2,Int64},Int64}()
    jump_and_march(tri.points, tri.adjacent, tri.adjacent2vertex, tri.graph,
        tri.boundary_index_ranges, DT.get_representative_point_list(tri), tri.boundary_map, get_point(tri, 40);
        m=nothing, k=14, TriangleType=NTuple{3,Int64}, store_history=true, history=history)
    collinear_segments = history.collinear_segments
    DT.fix_segments!(collinear_segments, history.collinear_point_indices)
    DT.connect_segments!(collinear_segments)
    DT.extend_segments!(collinear_segments, e)
    @test collinear_segments == [(14, 27), (27, 40)]

    e = (2, 54)
    history = DT.PointLocationHistory{NTuple{3,Int64},NTuple{2,Int64},Int64}()
    jump_and_march(tri.points, tri.adjacent, tri.adjacent2vertex, tri.graph,
        tri.boundary_index_ranges, DT.get_representative_point_list(tri), tri.boundary_map, get_point(tri, 54);
        m=nothing, k=2, TriangleType=NTuple{3,Int64}, store_history=true, history=history)
    collinear_segments = history.collinear_segments
    bad_indices = history.collinear_point_indices
    DT.fix_segments!(collinear_segments, bad_indices)
    DT.connect_segments!(collinear_segments)
    DT.extend_segments!(collinear_segments, e)
    @test collinear_segments == [(2, 15), (15, 28), (28, 41), (41, 54)]
end