using Test, DataFrames, Random, Infiltrator
using GravityGE

@testset "gravityGE tests with partial dataset that will be completed within the process. Tests expect (1) No changes in welfare values, and (2) No changes in trade values." begin

    # Create a DataFrame with some missing trade connections
    flows = DataFrame(
        origin=repeat(string.('A':'Z'), inner=26),
        destination=repeat(string.('A':'Z'), outer=26),
        value=rand(1.0:0.1:10.0, 26^2)
    )
    flows_copy = copy(flows)

    # Identify rows where origin != destination
    non_diag_idx = findall(row -> row.origin != row.destination, eachrow(flows))

    # Choose a random subset of these rows to delete (e.g., 60% of them)
    n_to_delete = Int(floor(0.6 * length(non_diag_idx)))
    rows_to_delete = randperm(length(non_diag_idx))[1:n_to_delete]
    delete_idx = non_diag_idx[rows_to_delete]

    # Delete the selected rows
    deleteat!(flows, sort(delete_idx))
    flows_copy[sort(delete_idx), "value"] .= 0

    # No change: additive
    out = gravityGE(flows)
    @test out[:new_welfare].welfare ≈ ones(26)
    @test out[:new_welfare].nominal_wage ≈ ones(26)
    @test out[:new_welfare].price_index ≈ ones(26)
    @test all(out[:new_trade].new_trade .≈ flows_copy.value)

    # No change: multiplicative
    out = gravityGE(flows; multiplicative=true)
    @test out[:new_welfare].welfare ≈ ones(26)
    @test out[:new_welfare].nominal_wage ≈ ones(26)
    @test out[:new_welfare].price_index ≈ ones(26)
    @test all(out[:new_trade].new_trade .≈ flows_copy.value)

end

@testset "gravityGE tests with a square (all origin-destination pairs present) dataframe. I test that the model is theoretically consistent. When all changes in productivity are negative, then we should expect negative welfare. When bilateral trade costs increase, we should expect negative welfare. No further tests are done in nominal_wage, price_index, and new_trade." begin
    flows = DataFrame(
        origin=repeat(string.('A':'Z'), inner=26),
        destination=repeat(string.('A':'Z'), outer=26),
        value=ones(26^2)
    )

    # More bitrade costs (additive)
    flows.bitrade_costs .= -4 * log(1.5)
    flows.bitrade_costs[flows.origin.==flows.destination] .= 0.0
    out = gravityGE(flows; theta=4.0, beta_hat_name="bitrade_costs")
    @test all(out[:new_welfare].welfare .<= 1.0)

    # Less bitrade costs (additive)
    flows.bitrade_costs .= -4 * log(0.5)
    flows.bitrade_costs[flows.origin.==flows.destination] .= 0.0
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


    # More bitrade costs (multiplicative)
    flows.bitrade_costs .= -4 * log(1.5)
    flows.bitrade_costs[flows.origin.==flows.destination] .= 0.0
    out = gravityGE(flows; theta=4.0, beta_hat_name="bitrade_costs", multiplicative=true)
    @test all(out[:new_welfare].welfare .<= 1.0)

    # Less bitrade costs (multiplicative)
    flows.bitrade_costs .= -4 * log(0.5)
    flows.bitrade_costs[flows.origin.==flows.destination] .= 0.0
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
