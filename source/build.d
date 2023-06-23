module ypm.build;

import std.file;
import std.json;
import std.path;
import std.stdio;
import std.format;
import std.process;
import core.stdc.stdlib;

private string IncludeArgs(string path) {
	string ret;
	auto   project = readText("ypm.json").parseJSON();

	foreach (ref dependency ; project["libs"].array) {
		ret ~= format(" -i %s/.ypm/%s/source", path, dependency.str.baseName());

		IncludeArgs(format("%s/.ypm/%s", path, dependency.str.baseName()));
	}

	return ret;
}

void YPM_Build(string[] args) {
	bool cleanUp = true;

	foreach (ref arg ; args) {
		switch (arg) {
			case "-nc":
			case "--no-clean": {
				cleanUp = false;
				break;
			}
			default: {
				stderr.writefln("Unknown option '%s'", arg);
				break;
			}
		}
	}

	if (!exists("ypm.json")) {
		stderr.writeln("Not a YPM project");
		exit(1);
	}

	auto project = readText("ypm.json").parseJSON();

	writeln("Starting build for project %s", project["name"].str);

	if (!exists("source/main.ysl")) {
		writeln("Nothing to be done");
		exit(0);
	}

	auto command = format(
		"yslc source/main.ysl -o %s.asm -i .ypm", project["name"].str
	);

	foreach (ref dependency ; project["libs"].array) {
		auto projectPath = format(".ypm/%s/ypm.json", dependency.str.baseName());

		if (!exists(projectPath)) {
			stderr.writefln(
				"Depdency '%s' is not a YPM project, skipping",
				dependency.str.baseName()
			);
			continue;
		}

		auto dependencyProject = readText(projectPath).parseJSON();
		
		command ~= IncludeArgs(dirName(projectPath));
		command ~= format(" -i %s/source/", dirName(projectPath));
	
		writefln("Including dependency %s", dependencyProject["name"].str);
	}

	auto res = command.executeShell();
	write(res.output);

	writeln("Compiled program");

	if (res.status != 0) {
		stderr.writeln("Compilation failed");
		exit(1);
	}

	res = project["binCommand"].str.executeShell();
	write(res.output);

	if (res.status != 0) {
		stderr.writeln("Failed to create binary");
		exit(1);
	}

	writeln("Created binary");

	if (cleanUp) {
		remove(format("%s.asm", project["name"].str));
	}

	writeln("Done");
}
