// components/caffeinate.c
#include <stdio.h>
#include <string.h>

#include "../slstatus.h"
#include "../util.h"

const char *
caffeinate(const char *arg)
{
	FILE *fp = popen("pgrep -x caffeinate", "r");
	if (!fp)
		return "ERR ";

	if (fgets(buf, sizeof(buf), fp) != NULL) {
		pclose(fp);
		return "󰅶 P ";
	}

	pclose(fp);
	return "󰾪 S ";
}


