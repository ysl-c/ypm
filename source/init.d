module ypm.init;

import std.file;
import std.json;
import std.path;
import std.stdio;
import std.string;
import std.process;
import std.net.curl;
import core.stdc.stdlib;

const string exampleMain =
"%include \"std.ysl\"
# include your other source files here

func main
	local string msg \"Hello World\"
	putstr &msg
endfunc
";

void YPM_Init(string[] args) {
	JSONValue project = parseJSON("{}");
	string    input;
	bool      newProject = true;

	if (exists("ypm.json")) {
		project    = readText("ypm.json").parseJSON();
		newProject = false;
	}

	if ("name" !in project.objectNoRef) {
		project["name"] = baseName(getcwd());
		writef("Name [%s]: ", project["name"].str);
		input = readln().strip();

		if (input != "") {
			project["name"] = input;
		}
	}

	if ("binCommand" !in project.objectNoRef) {
		project["binCommand"] = format(
			"nasm -f bin %s.asm -o %s.com", project["name"].str,
			project["name"].str
		);

		writef("Create binary command [%s]: ", project["binCommand"].str);
		input = readln().strip();

		if (input != "") {
			project["binCommand"] = input;
		}
	}

	if (!exists("source")) {
		mkdir("source");
	}

	if (!exists(".ypm")) {
		mkdir(".ypm");
	}

	if ("core" !in project.objectNoRef) {
		project["core"] = "core_x86_16";

		writef("Core [%s]: ", project["core"].str);
		input = readln().strip();

		if (input != "") {
			project["core"] = input;
		}
	}

	if ("libs" !in project.objectNoRef) {
		project["libs"] = new JSONValue[](0);
	}
	else {
		foreach (ref dependency ; project["libs"].array) {
			if (args[0].startsWith("http")) {
				writeln("Installing library %s", baseName(dependency.str));
				
				auto res = executeShell(
					format(
						"git clone %s .ypm/%s", dependency.str,
						baseName(dependency.str)
					)
				);

				if (res.status != 0) {
					stderr.writeln(res.output);
					stderr.writeln("Failed to install library");
					exit(1);
				}

				res = executeShell(
					format(
						"cd .ypm/%s && ypm init", baseName(dependency.str)
					)
				);

				if (res.status != 0) {
					stderr.writeln(res.output);
					stderr.writeln("Failed to initialise library");
					exit(1);
				}
			}
			else {
				stderr.writefln(
					"Dependency '%s' is not a http git url", dependency.str
				);
			}
		}
	}

	if (!exists(".ypm/core.ysl")) {
		writefln("Downloading core...");
		bool success = true;
		auto url = format(
			"https://raw.githubusercontent.com/ysl-c/core/main/%s.ysl",
			project["core"].str
		);
		
		try {
			std.file.write(".ypm/core.ysl", get(url));
		}
		catch (CurlException e) {
			success = false;

			stderr.writefln("Failed: %s", e.msg);
			stderr.writefln("URL: %s", url);
		}

		if (success) {
			writeln("Done");
		}
	}

	if (!exists(".ypm/std.ysl")) {
		writeln("Downloading STD library");

		auto url = "https://raw.githubusercontent.com/ysl-c/std/main/std.ysl";
		std.file.write(".ypm/std.ysl", get(url));
		writeln("Done");
	}

	if (newProject) {
		std.file.write("source/main.ysl", exampleMain);
		std.file.write(
			".gitignore", format(
				"%s.asm\n%s.com\n.ypm", project["name"].str,
				project["name"].str
			)
		);
	}

	std.file.write("ypm.json", project.toPrettyString());
}
