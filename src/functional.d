/*

Guidelines:
    - Please don't use global imports of the functions you want to show.
        (Every test should be independent.)
    - Add one line between imports and your tests if you have more than one
        import line
*/

// we use this comparison method a lot
import std.algorithm: equal;

// Needed for custom name attribute
struct name
{
    string val;
}

/**
With map we can call a custom function for every element
*/
@name("Increment elements") @safe unittest{
    import std.algorithm: map;
    auto result = [1, 2, 3].map!(a => a + 1);
    assert(result.equal([2 ,3, 4]));
}

/**
With fold we can apply a function to all elements by calling the function with
the current result and the value of every element, optionally starting with a
specific value.
*/
@name("Reduce to minimum or maximum") @safe unittest{
    import std.algorithm: min, max, fold;
    auto result = [3, 2, 1].fold!min;
    assert(result == 1);
    result = [3, 2, 1].fold!max;
    assert(result == 3);
}

/**
We can also filter our input range with custom functions
*/
@name("Filter elements") @safe unittest{
    import std.algorithm: count, filter;
    import std.string: indexOf;

    auto result = ["hello", "world"]
                    .filter!(a => a.indexOf("wo") >= 0)
                    .count;
    assert(result == 1);
}

/**
Sort accepts a pred template, which means we can just pass our own
*/
@name("Reverse sort") @safe unittest{
    import std.algorithm: sort;

    auto result = [1, 3, 2].sort!"a > b";
    assert(result.equal([3, 2, 1]));
}

/**
A pretty common pattern is to read user input.
Splitter is usually lazily evaluated.
*/
@name("Split string to ints") @safe unittest{
    import std.algorithm: map, splitter;
    import std.array: array;
    import std.conv: to;

    auto result = "1 3 2".splitter().map!(to!int);
    assert(result.equal([1, 3, 2]));
}

/**
A typical example from Unix is to sort and count the number of unique lines.
In D we can do the same!
*/
@name("Count number of unique elements") @safe unittest{
    import std.algorithm: count, sort, uniq;
    auto result = [1, 3, 2, 2, 3].sort().uniq.count;
    assert(result == 3);
}

/**
We split our input range into chunks of the size two and calculate the sum for each.
*/
@name("Pairwise sum") @safe unittest{
    import std.algorithm: map, sum;
    import std.range: chunks;

    auto result = [1, 2, 3, 4].chunks(2).map!(sum);
    assert(result.equal([3, 7]));
}

/**
This approach requires sorting the array.
Use a dict (below) - it doesn't require sorting.
*/
@name("Count chars") unittest{
    import std.array: array;
    import std.algorithm: sort, group;
    import std.typecons: tuple; // create tuples manually

    auto result = "ABCA".array.sort().group.array;
    auto expected = [tuple('A', 2),
                     tuple('B', 1),
                     tuple('C', 1)];
    assert(expected == cast(typeof(expected)) result);
}

/**
We can iterate pairwise over all k-mer and list them.
The syntax to convert a tuple back to list is a bit hard to figure out.
*/
@name("List k-mer") unittest{
    import std.algorithm: map;
    import std.array: array, join;
    import std.range: dropOne, only, save, zip;
    import std.conv: to;

    auto arr = "AGCGA".array;
    auto result = arr.zip(arr.save.dropOne)
                     .map!"a.expand.only"
                     .map!(to!string)
                     .join(",");
    assert(result == "AG,GC,CG,GA");
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
    arr.zip(arr.save.dropOne)
       .map!"a.expand.only"
       .map!(to!string)
       .each!(a => d[a]++);
    assert(d == ["AG": 2, "GA": 2]);
}

@name("Filter by index") @safe unittest{
    import std.range: chain, zip;
    import std.typecons;
    import std.algorithm : map, max, fold, sum;
    import std.array: array;

    auto a = tuple([1, 2, 3], [4, 5, 6], [7, 8, 9]);
    auto ab = a.array.map!"a.sum";
    auto ac = zip(ab).map!"sum(a[].only)";
    assert(ab.chain(ac).fold!max == 24);
}

/**
With enumerate we get an index which we can use to filter
*/
@name("Filter by index") @safe unittest{
    import std.algorithm: filter, map;
    import std.range: enumerate;

    auto result = [3, 4, 5]
                    .enumerate
                    .filter!(a => a[0] != 1)
                    .map!"a[1]";
    assert(result.equal([3, 5]));
}

/**
With enumerate we get an index with which we can remove all odd numbers.
*/
@name("Sum up even indexed number") @safe unittest{
    import std.algorithm: filter, map, sum;
    import std.range: enumerate;

    auto result = [3, 4, 5]
                    .enumerate
                    .filter!(a => a[0] % 2 == 0)
                    .map!"a[1]"
                    .sum;
    assert(result == 8);
}

/**
Yet another good example of group.
*/
@name("Most common word") @safe unittest{
    import std.algorithm: group, map, sort;
    import std.array: split;
    import std.string: toLower;
    import std.typecons: tuple;

    string text = "Two times two equals four";
    auto result = text
                    .toLower
                    .split(' ')
                    .sort()
                    .group;
    assert(result.equal([tuple("equals", 1u), tuple("four", 1u),
                         tuple("times", 1u),  tuple("two", 2u)]));
}

/**
reverseArgs can be used to continue using the result in a UFCS pipe
*/
@name("Format a range pipeline") @safe unittest{
    import std.algorithm : filter, map, sum;
    import std.range : iota;
    import std.format : format;
    import std.functional : reverseArgs;

    auto res = 6.iota
      .filter!(a => a % 2) // 0 2 4
      .map!(a => a * 2) // 0 4 8
      .sum
      .reverseArgs!format("Sum: %d");
    assert(res == "Sum: 18");
}

/**
With cumulativeFold a lazy, stack-based parser can be written
*/
@name("Lazy parser") @safe unittest{
    import std.algorithm : cumulativeFold, equal, map, until;
    import std.range : zip;
    auto input = "foo()bar)";
    auto result = input.cumulativeFold!((count, r){
        switch(r)
        {
            case '(':
                count++;
                break;
            case ')':
                count--;
                break;
            default:
        }
        return count;
    })(1).zip(input).until!(e => e[0] == 0).map!(e => e[1]);
    assert(result.equal("foo()bar"));
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
        if(arr.length == 1) return arr; // optional
        return qs(arr.filter!(a => a < arr[0]).array) ~ arr[0] ~ qs(arr[1..$].filter!(a => a >= arr[0]).array);
    }
    assert(qs([3, 2, 1, 4]) == [1, 2, 3, 4]);
    assert(qs([1]) == [1]);
    assert(qs([]) == []);
}
