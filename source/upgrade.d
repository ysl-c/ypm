module ypm.upgrade;

import std.file;
import std.json;
import std.path;
import std.stdio;
import std.format;
import std.process;
import std.net.curl;
import core.stdc.stdlib;

void YPM_Upgrade(string[] args) {
	if (!exists("ypm.json")) {
		stderr.writeln("Not a YPM project");
		exit(1);
	}

	JSONValue project = readText("ypm.json").parseJSON();

	writefln("Upgrading project %s", project["name"].str);

	writefln("Downloading core...");
	bool success = true;
	auto url = format(
		"https://raw.githubusercontent.com/ysl-c/core/main/%s.ysl",
		project["core"].str
	);

	if (exists(".ypm/core.ysl")) {
		std.file.remove(".ypm/core.ysl");
	}
	
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

	writeln("Downloading STD library");

	if (exists(".ypm/std.ysl")) {
		std.file.remove(".ypm/std.ysl");
	}
	
	url = "https://raw.githubusercontent.com/ysl-c/std/main/std.ysl";
	std.file.write(".ypm/std.ysl", get(url));
	writeln("Done");

	foreach (ref dependency ; project["libs"].array) {
		auto path = format(".ypm/%s", baseName(dependency.str));
	
		auto upgradeCommand = format(
			"cd %s && git pull && ypm upgrade", path
		);

		auto res = executeShell(upgradeCommand);

		if (res.status != 0) {
			stderr.writeln(res.output);
			stderr.writefln("Upgrade of package '%s' failed", project["name"].str);
		}
	}
}
