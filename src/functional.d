/*
Please don't use global imports - every test should be independent.
*/

// Needed for custom name attribute
struct name
{
    string val;
}

/**
With map we can call a custom function for every element
*/
@name("Increment elements") @safe unittest{
    import std.algorithm: equal, map;
    assert([1,2,3].map!(a => a+1).equal([2,3,4]));
}

/**
We can also filter our input range with custom functions
*/
@name("Filter elements") @safe unittest{
    import std.algorithm: count, filter;
    import std.string: indexOf;
    assert(["hello", "world"].filter!(a => a.indexOf("wo") >= 0).count == 1);
}

/**
Alternatively we can also use the 
*/
@name("Find minimum") @safe unittest{
    import std.algorithm: min, minPos, reduce;
    import std.range: enumerate;
    assert([3,2,1].reduce!min == 1);
}

/**
Sort accepts a pred template, which means we can just pass our own
*/
@name("Reverse sort") @safe unittest{
    import std.algorithm: sort, reverse;
    import std.array: array;
    assert([1,3,2].sort!"a > b".array == [3,2,1]);
    auto arr = [1,3,2];
    arr.sort();
    arr.reverse();
    assert(arr == [3,2,1]);
}

/**
A pretty common pattern is to read user input.
Splitter is usually lazily evaluated.
*/
@name("Split string to ints") @safe unittest{
    import std.algorithm: map, splitter;
    import std.array: array;
    import std.conv: to;
    assert("1 3 2".splitter().map!(to!int).array == [1,3,2]);
}

/**
Awesome description
*/
@name("Count number of unique elements") @safe unittest{
    import std.algorithm: count, sort, uniq;
    assert([1,3,2,2,3].sort().uniq.count == 3);
}

/**
We split our input range into chunks of the size two and calculate the sum for each.
*/
@name("Pairwise sum") @safe unittest{
    import std.algorithm: map, sum;
    import std.array: array;
    import std.range: chunks;
    assert([1,2,3,4].chunks(2).map!(sum).array == [3,7]);
}

/**
This approach requires sorting the array.
Use a dict (below) - it doesn't require sorting.
*/
@name("Count chars") unittest{
    import std.array: array;
    import std.algorithm: sort, group;
    import std.typecons: tuple; // create tuples manually
    auto res = "ABCA".array.sort().group.array;
    auto expected = [tuple('A', 2), tuple('B', 1), tuple('C', 1)];
    assert(expected == cast(typeof(expected)) res);
}

/**
We can iterate pairwise over all k-mer and list them.
The syntax to convert a tuple back to list is a bit hard to figure out.
*/
@name("List k-mer") unittest{
    import std.algorithm: map, uniq;
    import std.array: array, join;
    import std.range: dropOne, only, save, zip;
    import std.conv: to;
    auto arr = "AGCGA".array;
    assert(arr.zip(arr.save.dropOne).map!"a.expand.only".map!(to!string).join(",") == "AG,GC,CG,GA");
}

/**
We iterate over all pairs of the string and increment a key in our dictionary.
In D a new key is automatically created once it is accessed for the first time.
The syntax to convert a tuple back to list is a bit hard to figure out.
*/
@name("Count k-mer with defaultdict") unittest{
    import std.array: array;
    import std.algorithm: each, map;
    import std.range: dropOne, only, save, zip;
    import std.conv: to;
    int[string] d;
    auto arr = "AGAGA".array;
    arr.zip(arr.save.dropOne).map!"a.expand.only".map!(to!string).each!(a => d[a]++);
    assert(d == ["AG":2, "GA":2]);
}

/**
With enumerate we get an index which we can use to filter
*/
@name("Filter by index") @safe unittest{
    import std.algorithm: filter, map;
    import std.array: array;
    import std.range: enumerate;
    assert([3,4,5].enumerate.filter!(a => a[0] != 1).map!"a[1]".array == [3,5]);
}

/**
With enumerate we get an index with which we can remove all odd numbers.
*/
@name("Sum up even indexed number") @safe unittest{
    import std.algorithm: filter, map, sum;
    import std.range: enumerate;
    assert([3,4,5].enumerate.filter!(a => a[0] % 2 == 0).map!"a[1]".sum == 8);
}

/**
Yet another good example of group.
*/
@name("Most common word") @safe unittest{
    import std.algorithm: group, map, sort;
    import std.array: split;
    import std.string: toLower;
    string text = "A green crocodile fast to a shop";
    auto res = text.toLower.split(' ').sort().group.front;
    assert(res[0] == "a");
    assert(res[1] == 2);
}

/**
This is a good example how expressive functional programming can be.
Also note that the second base case is not necessary.
*/
@name("Quicksort") @safe unittest{
    import std.algorithm: filter;
    import std.array: array;
    int[] qs(int[] arr) {
        if(!arr.length) return [];
        if(arr.length == 1) return arr;
        return qs(arr.filter!(a => a < arr[0]).array) ~ arr[0] ~ qs(arr[1..$].filter!(a => a >= arr[0]).array);
    }
    assert(qs([3,2,1,4]) == [1,2,3,4]);
    assert(qs([1]) == [1]);
    assert(qs([]) == []);
}
