#include <stdlib.h>
#include <math.h>
#include <errno.h>
#include <stdio.h>
#include <unistd.h>
#include <syslog.h>
#include <string.h>
#include <sys/socket.h>
#include <unistd.h>
#include <signal.h>
#include <stdbool.h>
#include <netinet/in.h>

/********************************************
 * Remote RGB Server for Raspberry Pi
 * Author: Ben Brown
 * ©2014 Ben Brown
 * gcc -Wall -o rgbserver rgbserver.c
 */

void log_error( const char* );
void log_msg( const char* );
bool Servlet( int );

void fadeToColor(int toR, int toG, int toB);
double step(double fromVal, double toVal, double speed);
bool isClose(double a, double b);
void fadeLoop();
void cycleLoop();
void christmasLoop();

bool isDaemon = true;

#define PORT 51717
#define D_RED 23
#define D_GREEN 18
#define D_BLUE 24
#define FADE_STEP 5.0
#define FADE_DELAY 1000
//Delay is in microseconds, 1000 mirosecond = 1 m(illi)sec

int RED, GREEN, BLUE;
double rVal, gVal, bVal;
bool shouldFade;
pid_t fadeLoopPID;

void pwm(int pin, double val) {
    double angle;
    angle = val / 100.0;
    if (angle < 0.1) angle = 0.0;
    else if (angle > 1.0) angle = 1.0;
    char str[40];
    sprintf(str, "echo %i=%.3f > /dev/pi-blaster", pin, angle);
    system((char *)str);
}
/**
 * Sets the rPi color, each int being x/100.0 for r, g, or b
 */
void setColor(double r, double g, double b) {
    pwm(RED, r);
    pwm(GREEN, g);
    pwm(BLUE, b);
    rVal = r;
    gVal = g;
    bVal = b;
}


int main( int argc, char** argv ) {
	if( argc > 1 )
		isDaemon = false;

	if( isDaemon ) {
		openlog( "remote server", 0, 0 );
		pid_t pid = fork();
		if( pid < 0 ) {
			log_error( "fork" );
			exit( EXIT_FAILURE );
		}
		if( pid > 0 )
			exit( EXIT_SUCCESS );
	}

    RED = D_RED;
    GREEN = D_GREEN;
    BLUE = D_BLUE;

	int sockfd = socket( AF_INET, SOCK_STREAM, 0 );
	if( sockfd < 0 ) {
		log_error( "Failed to open socket" );
		exit( 1 );
	}
	struct sockaddr_in serv_addr;
	memset( &serv_addr, 0, sizeof(serv_addr) );
	serv_addr.sin_family = AF_INET;
	serv_addr.sin_addr.s_addr = INADDR_ANY;
	serv_addr.sin_port = htons( PORT );
	if( bind(sockfd, (struct sockaddr*)&serv_addr, sizeof(serv_addr)) < 0 ) {
		log_error( "Failed to bind" );
		exit( 1 );
	}
	listen( sockfd, 1 );	// wait for connection

	int insockfd;
	bool connected = true;
	while( connected ) {
		struct sockaddr_in cli_addr;
		socklen_t clilen = sizeof(cli_addr);
		log_msg( "Accepting..." );
		insockfd = accept( sockfd, (struct sockaddr*)&cli_addr, &clilen );
		if( insockfd < 0 ) {
			log_error( "Error on accept" );
			exit( 1 );
		}
		log_msg( "Connected" );
        bool running = true;
		while ( running ) {
			running = Servlet( insockfd );	// block until Servlet returns
		}
	}
	log_msg( "Closing" );
	close( insockfd );
	if( isDaemon )
		closelog();
	exit( 0 );
}

bool Servlet( int sock )
{
	char inBuf[256];

	int count = read( sock, inBuf, sizeof(inBuf) );
    if( count == 0 ) {
        log_msg("Client closed");
        close( sock );
		return false;		// client closed socket
    }
	if( count < 0 ) {
		log_error( "Socket read failed" );
		return false;
	}
	if( inBuf[0] == 'c' ) { //set color
        char* ptr = inBuf + 2;	// start after 'c '
        double r, g, b;
        sscanf(ptr, "%lf %lf %lf", &r, &g, &b);
        //printf( "Rec: %d %d %d\n", r, g, b);
        setColor(r, g, b);
    } else if( inBuf[0] == 'p' ) { //set pin
        char* ptr = inBuf + 2;	// start after 'p '
        int pin;
        char color;
        sscanf(ptr, "%c %d", &color, &pin);
        if ( pin <= 0 ) {
            return true;
        }
        switch (color) {
            case 'r':
            case 'R':
                RED = pin;
                printf("Set RED pin to %i\n", pin);
                break;
            case 'g':
            case 'G':
                GREEN = pin;
                printf("Set GREEN pin to %i\n", pin);
                break;
            case 'b':
            case 'B':
                BLUE = pin;
                printf("Set BLUE pin to %i\n", pin);
                break;
            default:
                break;
        }
    } else if( inBuf[0] == 'f' ) { 		//[f]ading:
    	if ( inBuf[1] == 's' ) { 		// start fade
    		shouldFade = true;
    		fadeLoopPID = fork();
    		if ( fadeLoopPID == 0 ) {
    			printf("starting fade loop in PID %d\n", getpid());
    			fadeLoop();
    		}
    	} else if ( inBuf[1] == 'e' ) { // stop (end) fade
    		shouldFade = false;
    		if (fadeLoopPID > 0) {
    			kill(fadeLoopPID, SIGTERM);
    		}
    	}

	} else if( inBuf[0] == 'y' ) { 		//c[y]cling colors:
		if ( inBuf[1] == 's' ) { 		// start cycle
			shouldFade = true;
			fadeLoopPID = fork();
			if ( fadeLoopPID == 0 ) {
				printf("starting fade loop in PID %d\n", getpid());
				cycleLoop();
			}
		} else if ( inBuf[1] == 'e' ) { // stop (end) fade
			shouldFade = false;
			if (fadeLoopPID > 0) {
				kill(fadeLoopPID, SIGTERM);
			}
		}

	} else if( inBuf[0] == 'h' ) { 		//c[h]ristmas:
		if ( inBuf[1] == 's' ) { 		// start loop
			shouldFade = true;
			fadeLoopPID = fork();
			if ( fadeLoopPID == 0 ) {
				printf("starting fade loop in PID %d\n", getpid());
				christmasLoop();
			}
		} else if ( inBuf[1] == 'e' ) { // stop (end) fade
			shouldFade = false;
			if (fadeLoopPID > 0) {
				kill(fadeLoopPID, SIGTERM);
			}
		}

	} else if( inBuf[0] == '.' ) {
        log_msg( "end Servlet" );
        close( sock );
    } else {
        printf("Rec msg: %s\n", inBuf);
    }
	return true;
}

void log_error( const char* s )
{
	if( isDaemon )
		syslog( LOG_ERR, "%s: %s", s, strerror(errno) );
	else
		perror( s );
}

void log_msg( const char* s )
{
	if( isDaemon )
		syslog( LOG_INFO, "%s", s );
	else
		printf( "%s\n", s );
}

void fadeLoop() {
	fadeToColor(100, 0, 0);	// Red
	fadeToColor(95, 16, 0);	// Orange
	fadeToColor(95, 41, 0);	// Yellow
	fadeToColor(0, 100, 0);	// Green
	fadeToColor(0, 0, 100);	// Blue
	fadeToColor(78, 0, 100);// Purple
	if (shouldFade) {
		fadeLoop();
	} else {
		exit(EXIT_SUCCESS);
	}
}

void cycleLoop() {
	int sleepTime = 0.8*1000000; //Sleep 0.8 sec between colors
	setColor(100, 0, 0);	// Red
	usleep(sleepTime);
	setColor(95, 16, 0);	// Orange
	usleep(sleepTime);
	setColor(95, 41, 0);	// Yellow
	usleep(sleepTime);
	setColor(0, 100, 0);	// Green
	usleep(sleepTime);
	setColor(0, 0, 100);	// Blue
	usleep(sleepTime);
	setColor(78, 0, 100);// Purple
	if (shouldFade) {
		usleep(sleepTime);
		cycleLoop();
	} else {
		exit(EXIT_SUCCESS);
	}
}

void christmasLoop() {
	setColor(0, 100, 0);
	usleep(3.8*1000000); //Sleep 3.8 sec - this looks the best
	if (shouldFade) {
		setColor(100, 0, 0);
		usleep(3.8*1000000); //Sleep 3.8 sec
		christmasLoop();
	} else {
		exit(EXIT_SUCCESS);
	}
}

void fadeToColor(int toR, int toG, int toB) {
	double speed = 200.0;//number of steps it should take to
						 //get to the toVal
	double rStep = step(rVal, toR, speed);
	double gStep = step(gVal, toG, speed);
	double bStep = step(bVal, toB, speed);
	while (1) {
		if (rVal < toR) rVal += rStep;
		else if (rVal > toR) rVal -= rStep;
		if (gVal < toG) gVal += gStep;
		else if (gVal > toG) gVal -= gStep;
		if (bVal < toB) bVal += bStep;
		else if (bVal > toB) bVal -= bStep;
		setColor(rVal, gVal, bVal);
		usleep(FADE_DELAY);
		if (isClose(rVal, toR) && 
			isClose(gVal, toG) &&
			isClose(bVal, toB)) {
			break;
		}
	}
}

double step(double fromVal, double toVal, double speed) {
	if (fabs(fromVal-toVal) < 0.01) {
        return 0.0;
	}
    return fabs(fromVal-toVal)/speed;
}

bool isClose(double a, double b) {
	return (fabs(a-b) <= FADE_STEP);
}