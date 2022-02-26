function ground(args...)
    background("white")
    sethue("black")
end

@testset "Livestreaming" begin
    astar(args...; do_action = :stroke) = star(O, 50, 5, 0.5, 0, do_action)
    acirc(args...; do_action = :stroke) = circle(Point(100, 100), 50, do_action)

    vid = Video(500, 500)
    back = Background(1:100, ground)
    star_obj = Object(1:100, astar)
    act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

    conf_local = setup_stream(:local, address = "0.0.0.0", port = 8081)
    @test conf_local isa Javis.StreamConfig
    @test conf_local.livestreamto == :local
    @test conf_local.protocol == "udp"
    @test conf_local.address == "0.0.0.0"
    @test conf_local.port == 8081

    conf_twitch_err = setup_stream(:twitch)
    conf_twitch = setup_stream(:twitch, twitch_key = "foo")
    @test conf_twitch_err isa Javis.StreamConfig
    @test conf_twitch_err.livestreamto == :twitch
    @test isempty(conf_twitch_err.twitch_key)
    @test conf_twitch.twitch_key == "foo"

    render(vid, pathname = "stream_local.gif", streamconfig = conf_local)

    # errors with macos; a good test to have
    # test_local = run(pipeline(`lsof -i -P -n`, `grep ffmpeg`))
    # @test test_local isa Base.ProcessChain
    # @test test_local.processes isa Vector{Base.Process}

    cancel_stream()
    @test_throws ProcessFailedException run(
        pipeline(
            `ps aux`,
            pipeline(`grep ffmpeg`, pipeline(`grep stream_loop`, `awk '{print $2}'`)),
        ),
    )

    vid = Video(500, 500)
    back = Background(1:100, ground)
    star_obj = Object(1:100, astar)
    act!(star_obj, Action(morph_to(acirc; do_action = :fill)))

    @test_throws ErrorException render(
        vid,
        pathname = "stream_twitch.gif",
        streamconfig = conf_twitch_err,
    )
    rm("stream_twitch.gif")
end