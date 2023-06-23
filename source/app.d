module ypm.app;

import std.stdio;
import std.string;
import ypm.init;
import ypm.build;
import ypm.upgrade;
import ypm.install;

const string appHelp = "
YSL-C package manager, made by MESYETI
======================================
Commands:
	init                   - creates or initialises a YPM project
	build                  - builds the YPM project
	upgrade                - updates builtin libaries and external dependencies
	install (git http url) - installs a library to this project

Flags:
	init:
		none
	build:
		-nc / --no-clean : don't clean up after building
	upgrade:
		none
	install:
		none

Notes:
	for some reason upgrade doesn't always work on the builtin libraries
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
		case "upgrade": {
			YPM_Upgrade(args[2 .. $]);
			break;
		}
		case "install": {
			YPM_Install(args[2 .. $]);
			break;
		}
		default: {
			stderr.writefln("Unknown command '%s'", args[1]);
			return 1;
		}
	}

	return 0;
}
