struct name
{
    string val;
}

@name("Filter by index") @safe unittest{
    import std.algorithm: filter, map;
    import std.array: array;
    import std.range: enumerate;
    assert([3,5] == [3,4,5].enumerate(0).filter!(a => a[0] != 1).map!"a[1]".array);
}
@name("Testing") @safe unittest{
    import std.algorithm: filter, map;
    import std.array: array;
    import std.range: enumerate, iota;
    assert([0,2,3] == iota(4).enumerate(1).filter!(a => a[0] != 2).map!"a[1]".array);
}
