module ypm.upgrade;

import std.file;
import std.json;
import std.stdio;
import std.format;
import std.net.curl;
import core.stdc.stdlib;

void YPM_Upgrade(string[] args) {
	if (!exists("ypm.json")) {
		stderr.writeln("Not a YPM project");
		exit(1);
	}

	JSONValue project = readText("ypm.json").parseJSON();

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

	writeln("Downloading STD library");

	url = "https://raw.githubusercontent.com/ysl-c/std/main/std.ysl";
	std.file.write(".ypm/std.ysl", get(url));
	writeln("Done");
}
