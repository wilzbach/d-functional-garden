import dparse.lexer;
import dparse.parser;
import std.stdio;
import std.conv;
import std.string;
import std.file;
import dformat = dparse.formatter;

private string formatNode(T)(const T t)
{
    import std.array;
    auto writer = appender!string();
    auto formatter = new dformat.Formatter!(typeof(writer))(writer);
    formatter.format(t);
    return writer.data;
}

import std.regex : ctRegex, replaceAll;
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
    string text;
    string slug;
}

Test[] parseTests(string filename){
    auto f = File(filename);
    immutable ulong fileSize = f.size();
    ubyte[] fileBytes = new ubyte[](fileSize);
    assert(f.rawRead(fileBytes).length == fileSize);
    StringCache cache = StringCache(StringCache.defaultBucketCount);
    LexerConfig config;
    config.stringBehavior = StringBehavior.source;
    config.fileName = filename;
    const(Token)[] tokens = getTokensForParser(fileBytes, config, &cache);
    auto dmod = parseModule(tokens, filename);

    Test[] tests;
    foreach(d; dmod.declarations){
        string name = "Untitled";
        foreach(a; d.attributes){
            auto al = a.atAttribute.argumentList;
            if(al !is null){
                name = formatNode(al.items[0])[1..$-1];
            }
        }
        if (auto id = d.unittest_) {
            string text;
            foreach(i,k;id.blockStatement.declarationsAndStatements.declarationsAndStatements){
                auto decl = k.declaration;
                auto stmt = k.statement;
                string line;
                if(stmt !is null){
                    auto noCaseDefault = stmt.statementNoCaseNoDefault;
                    if(noCaseDefault !is null){
                        line = (cast(char[]) fileBytes[noCaseDefault.startLocation..noCaseDefault.endLocation+1]).to!string;
                        if(line[0] != '\n'){
                            line = "\n" ~ line;
                        }
                    }
                }else{

                }
                if(line.length == 0){
                    line = formatNode(k);
                }
                if(line[0..2] == "\n\n"){
                    line = line[1..$];
                }
                text ~= line;
            }
            //writeln(text);
            // remove first and list newline
            if(text[0] == '\n'){
                text = text[1..$];
            }
            tests ~= [Test(name, text, name.slug)];
        }
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
