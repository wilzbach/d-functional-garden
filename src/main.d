import std.stdio;
import std.conv;
import std.string;
import std.file;
import std.regex;

auto slugR = ctRegex!(r"[^a-z]+", "g");
string slug(string target) {
    import std.string : toLower;
    auto ret = target.toLower.replaceAll(slugR, "-");

    if(ret[0] == '-') {
        ret = ret[1..$];
    }

    if(ret[$-1] == '-') {
        ret = ret[0..$-1];
    }

    return ret;
}


struct Test{
    string name;
    string code;
    string desc;
    string slug;
}

import std.range;

auto removeIndentR = ctRegex!(r"\n    ", "g");
Test[] parseTests(string filename){
    // even with a lot of workarounds libdparse doesn't work well with lambdas
    // for the time being we use regexs
    auto r = regex(`\/\*\*((.|\n)*?)\*\/\n\s*@name\("(.*?)"\)\s*(@safe)?\s*unittest\s*\{((.|\n)*?)\n\}`);
    auto text = filename.readText;
    Test[] tests;
    foreach (c; text.matchAll(r)){
        auto desc = c[1];
        auto name = c[3];
        auto code = c[5];
        auto slug = name.slug;
        // remove one indent - dirty fix
        code = code.replaceAll(removeIndentR, "\n");
        code = code.chompPrefix("\n");
        Test test = {name: name, code: code, desc: desc, slug: slug};
        tests ~= [test];
    }
    return tests;
}

void writeTests(Test[] tests, string filename){
    import diet.html;
    import std.stdio;
    import std.path: dirName;
    string dir = filename.dirName;
    if(!exists(dir)){
        mkdir(dir);
    }
    auto f = File(filename, "wt"); 
    scope(exit) f.close();
    auto dst = f.lockingTextWriter;
    string title = "D Functional garden";
    dst.compileHTMLDietFile!("./page.jade", tests, title);
    writefln("Wrote %d tests", tests.length);
}

void main(){
    string inFilename = "src/functional.d";
    assert(exists(inFilename));
    string outFilename = "_site/index.html";
    parseTests(inFilename).writeTests(outFilename);
    // other stuff
    copy("css/custom.css", "_site/custom.css");
    copy("js/custom.js", "_site/custom.js");
}
