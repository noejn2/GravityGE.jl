using Test, DataFrames
using GravityGE

@testset "gravityGE baseline tests" begin
    flows = DataFrame(
        orig=repeat(string.('A':'Z'), inner=26),
        dest=repeat(string.('A':'Z'), outer=26),
        flow=ones(26^2)
    )

    # No change: additive
    out = gravityGE(flows; theta=4.0)
    @test out[:new_welfare].welfare ≈ ones(26)
    # No change: repeated test
    out = gravityGE(flows; theta=4.0)
    @test out[:new_welfare].welfare ≈ ones(26)

    # More bitrade costs (additive)
    flows.bitrade_costs = -4 * log(1.5) .* ones(26^2)
    flows.bitrade_costs[flows.orig.==flows.dest] .= 0.0
    out = gravityGE(flows; theta=4.0, beta_hat_name="bitrade_costs")
    @test all(out[:new_welfare].welfare .<= 1.0)

    # Less bitrade costs (additive)
    flows.bitrade_costs .= -4 * log(0.5)
    flows.bitrade_costs[flows.orig.==flows.dest] .= 0.0
    out = gravityGE(flows; theta=4.0, beta_hat_name="bitrade_costs")
    @test all(out[:new_welfare].welfare .>= 1.0)

    # More productivity
    flows.prod .= 2.0
    out = gravityGE(flows; theta=4.0, a_hat_name="prod")
    @test all(out[:new_welfare].welfare .>= 1.0)

    # Less productivity
    flows.prod .= 0.5
    out = gravityGE(flows; theta=4.0, a_hat_name="prod")
    @test all(out[:new_welfare].welfare .<= 1.0)
end

@testset "gravityGE multiplicative tests" begin
    flows = DataFrame(
        orig=repeat(string.('A':'Z'), inner=26),
        dest=repeat(string.('A':'Z'), outer=26),
        flow=ones(26^2)
    )

    # No change: multiplicative
    out = gravityGE(flows; theta=4.0, multiplicative=true)
    @test out[:new_welfare].welfare ≈ ones(26)

    # Again
    out = gravityGE(flows; theta=4.0, multiplicative=true)
    @test out[:new_welfare].welfare ≈ ones(26)

    # More bitrade costs (multiplicative)
    flows.bitrade_costs .= -4 * log(1.5)
    flows.bitrade_costs[flows.orig.==flows.dest] .= 0.0
    out = gravityGE(flows; theta=4.0, beta_hat_name="bitrade_costs", multiplicative=true)
    @test all(out[:new_welfare].welfare .<= 1.0)

    # Less bitrade costs (multiplicative)
    flows.bitrade_costs .= -4 * log(0.5)
    flows.bitrade_costs[flows.orig.==flows.dest] .= 0.0
    out = gravityGE(flows; theta=4.0, beta_hat_name="bitrade_costs", multiplicative=true)
    @test all(out[:new_welfare].welfare .>= 1.0)

    # More productivity (multiplicative)
    flows.prod .= 2.0
    out = gravityGE(flows; theta=4.0, a_hat_name="prod", multiplicative=true)
    @test all(out[:new_welfare].welfare .>= 1.0)

    # Less productivity (multiplicative)
    flows.prod .= 0.5
    out = gravityGE(flows; theta=4.0, a_hat_name="prod", multiplicative=true)
    @test all(out[:new_welfare].welfare .<= 1.0)
end

@testset "tradeflows do not change" begin
    flows = DataFrame(
        orig=repeat(string.('A':'Z'), inner=26),
        dest=repeat(string.('A':'Z'), outer=26),
        flow=rand(26^2) .+ 1.0
    )

    out = gravityGE(flows; theta=4.0)
    @test all(out[:new_trade].new_trade .≈ flows.flow)

end
