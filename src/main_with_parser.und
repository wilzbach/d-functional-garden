import dparse.lexer;
import dparse.ast;
import dparse.parser;
import dformat = dparse.formatter;

// even with a lot of workarounds libdparse doesn't work well with lambdas
// parking here for the time being

import std.regex : ctRegex, replaceAll;
import std.file;
import std.stdio;
import std.conv;
import std.string;

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
    string desc;
}

private string formatNode(T)(const T t)
{
    import std.array;
    auto writer = appender!string();
    auto formatter = new dformat.Formatter!(typeof(writer))(writer);
    formatter.format(t);
    return writer.data;
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
            string text = format(fileBytes, id.blockStatement);
            
            //writeln(text);
            // remove first and list newline
            if(text[0] == '\n'){
                text = text[1..$];
            }
            string desc = id.comment;
            // poor man's hack to get new lines
            desc = desc.replace("\n","<br>");
            tests ~= [Test(name, text, name.slug, desc)];
        }
    }
    return tests;
}

void log(T)(T obj) {
  static if (is(T == struct) || is(T == class)){
     writef("{");
     foreach(i,_;obj.tupleof) {
       writefln("%s : %s,", obj.tupleof[i].stringof[4..$], obj.tupleof[i]);
     }
     writefln("}");
  }
  else {
     writefln(obj);
  }
}

mixin template dump(Names ... )
{
    auto _unused_dump = {
        import std.stdio : writeln, write; 
        foreach(i,name; Names)
        {
            write(name, " = ", mixin(name), (i<Names.length-1)?", ": "\n");
        }
        return false;
    }();
}

string format(ref ubyte[] fileBytes, const BlockStatement blockstmt){
    string text;
    foreach(i,k;blockstmt.declarationsAndStatements.declarationsAndStatements){
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
            if (auto fun = decl.functionDeclaration) {
                auto header = fun.returnType.formatNode ~ " " ~ fun.name.formatNode ~ fun.parameters.formatNode ~ " {";
                auto block = fun.functionBody.blockStatement;
                line = "\n" ~ header ~ format(fileBytes, block).split('\n').join("\n     ") ~ "\n}";
            }else if (auto fun = decl.variableDeclaration) {
                if(fun.type !is null){
                    line = formatNode(k);
                }else{
                    //write(fun.autoDeclaration.formatNode);
                    //write(";\n");
                    auto au = fun.autoDeclaration;
                    line = "auto ";
                    foreach(l; 0..au.identifiers.length)
                    {
                        //if (i) put(", ");
                        line ~= formatNode(au.identifiers[l]);
                        line ~= " = ";
                        line ~= formatNode(au.initializers[l]);
                        with(au.initializers[l].nonVoidInitializer){
                            {
                                //writeln(assignExpression.formatNode);
                                //space();
                                //put(tokenRep(assignExpression.operator));
                                //space();
                                    //formatNode(assignExpression.expression).writeln;
                            }
                        }
                        //writeln(typeid(au.initializers[l]));
                    }
                }
                //writeln(fun.declarators);
            }else if (auto fun = decl.importDeclaration) {
                line = formatNode(k);
            }
        }
        // just in case - not needed atm
        if(line.length == 0){
            line = formatNode(k);
        }
        if(line[0..2] == "\n\n"){
            line = line[1..$];
        }
        text ~= line;
    }
    return text;
}
