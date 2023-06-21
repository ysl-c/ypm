module ypm.build;

import std.file;
import std.json;
import std.stdio;
import std.format;
import std.process;
import core.stdc.stdlib;

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

	if (!exists("source/main.ysl")) {
		writeln("Nothing to be done");
		exit(0);
	}

	auto command = format(
		"yslc source/main.ysl -o %s.asm -i .ypm", project["name"].str
	);

	auto res = command.executeShell();
	write(res.output);

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

	if (cleanUp) {
		remove(format("%s.asm", project["name"].str));
	}
}
