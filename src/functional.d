/*
Please don't use global imports - every test should be independent.
*/

// Needed for custom name attribute
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
@name("Reverse sort") @safe unittest{
    import std.algorithm: sort;
    import std.array: array;
    assert([3,2,1] == [1,3,2].sort!"a > b".array);
}
