module ypm.install;

import std.file;
import std.json;
import std.path;
import std.stdio;
import std.format;
import std.process;
import std.algorithm;
import core.stdc.stdlib;

void YPM_Install(string[] args) {
	if (!exists("ypm.json")) {
		stderr.writefln("Not a YPM project");
		exit(1);
	}

	auto project = readText("ypm.json").parseJSON();

	if (args[0].startsWith("http")) {
		writefln("Installing library %s", baseName(args[0]));
		
		auto res = executeShell(
			format("git clone %s .ypm/%s", args[0], baseName(args[0]))
		);

		if (res.status != 0) {
			stderr.writeln(res.output);
			stderr.writeln("Failed to install library");
			exit(1);
		}

		project["libs"].array ~= JSONValue(args[0]);

		res = executeShell(
			format(
				"cd .ypm/%s && ypm init", baseName(args[0])
			)
		);

		if (res.status != 0) {
			stderr.writeln(res.output);
			stderr.writeln("Failed to initialise library");
			exit(1);
		}
	}
	else {
		writeln("Use a http git URL");
	}

	std.file.write("ypm.json", project.toPrettyString());
}
