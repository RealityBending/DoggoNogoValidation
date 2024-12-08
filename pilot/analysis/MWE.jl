# Activate: using Pkg; Pkg.activate(@__DIR__); cd(@__DIR__)
using Turing, StatsFuns, DataFrames, Random
using DynamicPPL

@model function mod(x1, x2)

    μ_intercept ~ Normal(0, 0.5)
    μ_x1 ~ Normal(1, 0.5)
    μ_x2 ~ Normal(2, 0.5)
    σ ~ truncated(Normal(0.0, 1), lower=0)

    for i in 1:length(y)
        μ = μ_intercept .+ μ_x1 .* x1[i] .+ μ_x2 .* x2[i]
        y[i] ~ Normal(μ, σ)
    end
end


fit = mod(rand(10), rand(10)) | (y=rand(10),)
chain = sample(fit, NUTS(), 400)
pred = predict(mod([missing for i in 1:10], rand(10), rand(10)), chain)