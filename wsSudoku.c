
#include "chicken.h"
#include <stdbool.h>
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include "ws.h"
#include <assert.h>
#include <stdbool.h>

void clearResponse(void);
char *wsResponse = NULL;
static char buffer[256];
static C_word k;
int globalfd=-1;

void clearResponse(void)
{
	free(wsResponse);
	wsResponse=NULL;
	printf("success");
}


void onopen(int fd)
{
	char *cli;
	cli = ws_getaddress(fd);
#ifndef DISABLE_VERBOSE
	printf("Connection opened, client: %d | addr: %s\n", fd, cli);
#endif
	free(cli);	
}

void onclose(int fd)
{
	char *cli;
	cli = ws_getaddress(fd);
#ifndef DISABLE_VERBOSE
	printf("Connection closed, client: %d | addr: %s\n", fd, cli);
#endif
	free(cli);

}

void onmessage(int fd, const unsigned char *msg, uint64_t size, int type)
{
	char *cli;
	cli = ws_getaddress(fd);
#ifndef DISABLE_VERBOSE
	printf("I receive a message: %s (size: %" PRId64 ", type: %d), from: %s/%d\n",
		   msg, size, type, cli, fd);
#endif
	free(cli);

	/**
	 * Mimicks the same frame type received and re-send it again
	 *
	 * Please note that we could just use a ws_sendframe_txt()
	 * or ws_sendframe_bin() here, but we're just being safe
	 * and re-sending the very same frame type and content
	 * again.
	 */
	if (wsResponse == NULL)
	{
		wsResponse=(char *)malloc(MESSAGE_LENGTH);		
	}
	if (wsResponse == NULL)
	{
	 	perror("Failed to allocate memory");
		// 	// return EXIT_FAILURE; // defined in stdlib.h
	}
	strcpy(wsResponse, msg);
	// // printf("%s",wsResponse);
	globalfd=fd;
	//ws_sendframe(fd, (char *)msg, size, true, type);
}

int main(void)
{

	char buffer[256];
	setbuf(stdout, NULL);

	C_word val = C_SCHEME_UNDEFINED;
	C_word *data[1];
	data[0] = &val;
	
	// C_word val = C_SCHEME_UNDEFINED;
	// C_word *data[ 1 ];
	//	data[ 0 ] = &val;
	//	status = CHICKEN_eval_string ("(print 10000)", &val);/
	//	status = CHICKEN_eval_string ("(start 1)", &val);

	struct ws_events evs;
	evs.onopen = &onopen;
	evs.onclose = &onclose;
	evs.onmessage = &onmessage;
	usleep(500000);
	printf("Server Initialized!\n");
	ws_socket(&evs, 8080, 1); /* Never returns. */
	//
	// k = CHICKEN_run(CHICKEN_default_toplevel);
	k = CHICKEN_run(C_toplevel);
	CHICKEN_load("wsSudoku.scm");
	C_word status = CHICKEN_eval_string("(start)", &val);
	printf("data1: %08ld\n", val);
	CHICKEN_get_error_message(buffer, 255);
	printf("-> %s\n", buffer);
	assert(status);
	//
	/*
	 * If you want to execute code past ws_socket, invoke it like:
	 *   ws_socket(&evs, 8080, 1)
	 */

	return (0);
}
