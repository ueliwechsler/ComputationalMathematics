"""
    baryweights(xx) -> w

Compute the barycentric weights `w` for the interpolation points `xx`.
"""
function baryweights(xx)
    n = length(xx)
    return [1/prod(xx[j] .- xx[setdiff(1:n,j)]) for j = 1:n]
end

"""
    barycentric(xx,w,f,x)

Evaluate `p(x)` with `p` the polynomial interpolant through the data points `(xx[i],f[i])`.
`w` are the barycentric weights computed by `baryweights(xx)`.
"""
function barycentric(xx,w,f,x)
    i = findfirst(isequal(x),xx)
    if isnothing(i)
        return prod(x .- xx) * sum(w.*f./(x.-xx))
    else
        return f[i]
    end
end

"""
    chebyshev(f,x)

Evaluate `p(x)` with `p` the polynomial interpolant through the data points

    [ (cos(π*i)/n),f[i+1]) for i = 0:n ]

where `n = length(f)-1`.
"""
function chebyshev(f,x)
    n = length(f)-1
    xx = @. cos(π*(0:n)/n)
    i = findfirst(isequal(x),xx)
    if isnothing(i)
        w = (-1.0).^(0:n); w[1] /= 2; w[end] /= 2
        return sum(w.*f./(x.-xx))/sum(w./(x.-xx))
    else
        return f[i]
    end
end


using Test

function test()
    test_baryweights()
    test_barycentric()
    test_chebyshev()
end

function test_baryweights()
    @testset "baryweights" begin
        xx = 0:2
        w = baryweights(xx)
        @test w[1] ≈ inv( (xx[1]-xx[2]) * (xx[1] - xx[3]) )
        @test w[2] ≈ inv( (xx[2]-xx[1]) * (xx[2] - xx[3]) )
        @test w[3] ≈ inv( (xx[3]-xx[1]) * (xx[3] - xx[2]) )
    end
end

function test_barycentric()
    xx = [-1,0,1]
    ffun = x->x^2
    f =  ffun.(xx)
    w = baryweights(xx)
    p = x->barycentric(xx,w,f, x)

    @testset "barycentric" begin
        @testset "simple" begin
            x = [-0.9,0.1,0.5]
            @test p.(x) ≈ ffun.(x)
        end
        @testset "advanced" begin
            x = xx
            @test p.(x) ≈ ffun.(x)
        end
    end
end

function test_chebyshev()
    n = 2
    xx = @. cos(π*(0:n)/n)
    ffun = x->x^2
    f =  ffun.(xx)
    p = x->chebyshev(f, x)

    @testset "chebyshev" begin
        @testset "simple" begin
            x = [-0.9,0.1,0.5]
            @test p.(x) ≈ ffun.(x)
        end
        @testset "advanced" begin
            x = xx
            @test p.(x) ≈ ffun.(x)
        end
    end
end
