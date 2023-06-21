module ypm.app;

import std.stdio;
import std.string;
import ypm.init;
import ypm.build;

const string appHelp = "
YSL-C package manager, made by MESYETI
======================================
Commands:
	init - makes a new YSL-C project
	build - builds the YSL-C project

Flags:
	init:
		none
	build:
		-nc / --no-clean : don't clean up after building
";

int main(string[] args) {
	if (args.length <= 1) {
		writeln(appHelp.strip());
		return 0;
	}

	switch (args[1]) {
		case "init": {
			YPM_Init(args[2 .. $]);
			break;
		}
		case "build": {
			YPM_Build(args[2 .. $]);
			break;
		}
		default: {
			stderr.writefln("Unknown command '%s'", args[1]);
			return 1;
		}
	}

	return 0;
}
