/*
Please don't use global imports - every test should be independent.
*/

// Needed for custom name attribute
struct name
{
    string val;
}

@name("Increment elements") @safe unittest{
    import std.algorithm: equal, map;
    assert([1,2,3].map!(a=>a+1).equal([2,3,4]));
}

@name("Filter elements") @safe unittest{
    import std.algorithm: count, filter;
    import std.string: indexOf;
    assert(1 == ["hello", "world"].filter!(a=>a.indexOf("wo")>=0).count);
}

@name("Find minimum") @safe unittest{
    import std.algorithm: min, minPos, reduce;
    import std.range: enumerate;
    assert(1 == [3,2,1].reduce!min);
    assert(1 == [3,2,1].minPos[0]);
}

@name("Reverse sort") @safe unittest{
    import std.algorithm: sort;
    import std.array: array;
    assert([3,2,1] == [1,3,2].sort!"a > b".array);
}

@name("Count number of unique elements") @safe unittest{
    import std.algorithm: count, sort, uniq;
    assert(3 == [1,3,2,2,3].sort().uniq.count);
}

@name("Split string to ints") @safe unittest{
    import std.algorithm: map, splitter;
    import std.array: array;
    import std.conv: to;
    assert([1,3,2] == "1 3 2".splitter().map!(to!int).array);
}

@name("Filter by index") @safe unittest{
    import std.algorithm: filter, map;
    import std.array: array;
    import std.range: enumerate;
    assert([3,5] == [3,4,5].enumerate(0).filter!(a => a[0] != 1).map!"a[1]".array);
}

@name("Sum up even indexed number") @safe unittest{
    import std.algorithm: filter, map, sum;
    import std.range: enumerate;
    assert(8 == [3,4,5].enumerate(0).filter!(a => a[0] % 2 == 0).map!"a[1]".sum);
}

@name("Most common word") @safe unittest{
    import std.algorithm: group, map, sort;
    import std.array: split;
    import std.string: toLower;
    string text = "A green crocodile fast to a shop";
    auto res = text.toLower.split(' ').sort().group.front;
    assert(res[0] == "a");
    assert(res[1] == 2);
}

@name("Quicksort") @safe unittest{
    import std.algorithm: filter;
    import std.array: array;
    int[] qs(int[] arr) {
        if(!arr.length) return [];
        if(arr.length == 1) return arr;
        return qs(arr.filter!(a => a < arr[0]).array) ~ arr[0] ~ qs(arr[1..$].filter!(a => a >= arr[0]).array);
    }
    assert([1,2,3,4] == qs([3,2,1,4]));
    assert([1] == qs([1]));
    assert([] == qs([]));
}
