using DelaunayTriangulation
using Test
using SafeTestsets

@testset verbose = true "DelaunayTriangulation" begin
    @testset "Triangulation" begin
        @safetestset "Gmsh" begin
            include("triangulation/gmsh.jl")
        end
        @safetestset "Rectangular Triangulation" begin
            include("triangulation/rectangle.jl")
        end
        @safetestset "Bowyer Watson" begin
            include("triangulation/bowyer_watson.jl")
        end
        @safetestset "Triangulate" begin
            include("triangulation/triangulate.jl")
        end
    end

    @testset verbose = true "Utilities" begin
        @safetestset "Utilities" begin
            include("utils.jl")
        end
        @safetestset "Polygon Utilities" begin
            include("polygon_utils.jl")
        end
    end

    @testset verbose = true "Interfaces" begin
        @safetestset "Triangles" begin
            include("interfaces/triangles.jl")
        end
        @safetestset "Edges" begin
            include("interfaces/edges.jl")
        end
        @safetestset "Points" begin
            include("interfaces/points.jl")
        end
        @safetestset "Boundary Nodes" begin
            include("interfaces/boundary_nodes.jl")
        end
    end

    @testset verbose = true "Data Structures" begin
        @safetestset "Adjacent" begin
            include("data_structures/adjacent.jl")
        end
        @safetestset "Adjacent2Vertex" begin
            include("data_structures/adjacent2vertex.jl")
        end
        @safetestset "Graph" begin
            include("data_structures/graph.jl")
        end
        @safetestset "ConvexHull" begin
            include("data_structures/convex_hull.jl")
        end
        @safetestset "Triangulation" begin
            include("data_structures/triangulation.jl")
        end
        @safetestset "Representative Points" begin
            include("data_structures/representative.jl")
        end
    end

    @testset verbose = true "Operations" begin
        @safetestset "add_triangle!" begin
            include("operations/add_triangle.jl")
        end
        @safetestset "delete_triangle!" begin
            include("operations/delete_triangle.jl")
        end
        @safetestset "add_ghost_triangles!" begin
            include("operations/add_ghost_triangles.jl")
        end
        @safetestset "delete_ghost_triangles!" begin
            include("operations/delete_ghost_triangles.jl")
        end
        @safetestset "add_point!" begin
            include("operations/add_point.jl")
        end
    end

    @testset verbose = true "Predicates" begin
        @safetestset "Certificate" begin
            include("predicates/certificate.jl")
        end
        @safetestset "Boundaries and Ghosts" begin
            include("predicates/boundaries_and_ghosts.jl")
        end
        @safetestset "General" begin
            include("predicates/general.jl")
        end
        @safetestset "Index and Ghost Handling" begin
            include("predicates/index_and_ghost_handling.jl")
        end
    end

    @safetestset "Plotting" begin
        include("plotting.jl")
    end

    @testset verbose = true "Point Location" begin
        @safetestset "Brute Force" begin
            include("point_location/brute_force.jl")
        end
        @safetestset "Initial Point Selection" begin
            include("point_location/select_initial_point.jl")
        end
        @safetestset "Initial Triangle Selection" begin
            include("point_location/select_initial_triangle_interior_node.jl")
        end
        @safetestset "Interior Edge Intersections" begin
            include("point_location/interior_edge_intersections.jl")
        end
        @safetestset "Ghost Search" begin
            include("point_location/ghost_search.jl")
        end
        @safetestset "Jump and March" begin
            include("point_location/jump_and_march.jl")
        end
    end
end