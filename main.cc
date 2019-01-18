#include <errno.h>
#include <fcntl.h>
#include <iostream>
#include <netdb.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/epoll.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <unistd.h>

#define MAX_EPOLL_EVENTS_PER_RUN 100
#define EPOLL_RUN_TIMEOUT -1

static int
create_and_bind (char *port)
{
    struct addrinfo hints;
    struct addrinfo *result, *rp;
    int s, sfd;

    memset (&hints, 0, sizeof (struct addrinfo));
    hints.ai_family = AF_UNSPEC;     /* Return IPv4 and IPv6 choices */
    hints.ai_socktype = SOCK_STREAM; /* We want a TCP socket */
    hints.ai_flags = AI_PASSIVE;     /* All interfaces */

    s = getaddrinfo (NULL, port, &hints, &result);
    if (s != 0) {
        fprintf (stderr, "getaddrinfo: %s\n", gai_strerror (s));
        return -1;
    }

    for (rp = result; rp != NULL; rp = rp->ai_next) {
        sfd = socket (rp->ai_family, rp->ai_socktype, rp->ai_protocol);
        if (sfd == -1)
            continue;

        s = bind (sfd, rp->ai_addr, rp->ai_addrlen);
        if (s == 0) {
            /* We managed to bind successfully! */
            break;
        }

        close (sfd);
    }

    if (rp == NULL) {
        fprintf (stderr, "Could not bind\n");
        return -1;
    }

    freeaddrinfo (result);

    return sfd;
}

static int
make_socket_non_blocking (int sfd)
{
    int flags, s;

    flags = fcntl (sfd, F_GETFL, 0);
    if (flags == -1) {
        perror ("fcntl");
        return -1;
    }

    flags |= O_NONBLOCK;
    s = fcntl (sfd, F_SETFL, flags);
    if (s == -1) {
        perror ("fcntl");
        return -1;
    }

    return 0;
}

/*
 * Handle incoming data
 */
void handle_io_on_socket(struct epoll_event event)
{
    std::cout << "Handle io on FD ( " << event.data.fd << " )" << std::endl;
    char buf[2];

    ssize_t count = read (event.data.fd, buf, sizeof( buf ) -1  );
    buf[count] = 0;
    if (count == -1) {
        /* If errno == EAGAIN, that means we have read all
        	 data. So go back to the main loop. */
        if (errno != EAGAIN) {
            perror ("read");
        }
    } else {
        std::cout << buf << std::endl;
    }
}

/*
 *  Main
 */
int main(int argc, char *argv[])
{

    if ( argc != 2 ) {
        std::cerr << ": Usage <port>" << std::endl;
        exit(1);
    }
    int sfd = create_and_bind(argv[1]);

    int s = make_socket_non_blocking(sfd);
    if (s == -1)
        abort ();

    s = listen (sfd, SOMAXCONN);
    if (s == -1) {
        perror ("listen");
        abort ();
    }

    struct epoll_event *events;

    int efd = epoll_create(1);

    struct epoll_event ev;
    int client_sock = 0; // STDIN

    ev.events = EPOLLIN | EPOLLPRI | EPOLLERR | EPOLLHUP;
    ev.data.fd = client_sock;

    int res = epoll_ctl(efd, EPOLL_CTL_ADD, client_sock, &ev);
    if ( res == -1 ) {
      std::cerr << "Error epoll_ctl(): " << strerror(errno) << std::endl;
      return 1;
    }

    /* Buffer where events are returned */
    events = (epoll_event*) calloc (MAX_EPOLL_EVENTS_PER_RUN, sizeof(ev) );

    while (1) {
        // wait for something to do...
        int nfds = epoll_wait(efd, events, MAX_EPOLL_EVENTS_PER_RUN, EPOLL_RUN_TIMEOUT);

        if (nfds < 0) {
            std::cerr << "Error in epoll_wait!" << std::endl;
            return 1;
        }

        // for each ready socket
        for(int i = 0; i < nfds; i++) {
            if ((events[i].events & EPOLLERR) ||
                    (events[i].events & EPOLLHUP) ||
                    (!(events[i].events & EPOLLIN))) {
                /* An error has occured on this fd, or the socket is not
                   ready for reading (why were we notified then?) */
                fprintf (stderr, "epoll error\n");
                close (events[i].data.fd);
                continue;
            } else if (sfd == events[i].data.fd) {
                /* We have a notification on the listening socket, which
                   means one or more incoming connections. */
                while (1) {
                    struct sockaddr in_addr;
                    socklen_t in_len;
                    int infd;
                    char hbuf[NI_MAXHOST], sbuf[NI_MAXSERV];

                    in_len = sizeof in_addr;
                    infd = accept (sfd, &in_addr, &in_len);
                    if (infd == -1) {
                        if ((errno == EAGAIN) ||
                                (errno == EWOULDBLOCK)) {
                            /* We have processed all incoming
                               connections. */
                            break;
                        } else {
                            perror ("accept");
                            break;
                        }
                    }

                    s = getnameinfo (&in_addr, in_len,
                                     hbuf, sizeof hbuf,
                                     sbuf, sizeof sbuf,
                                     NI_NUMERICHOST | NI_NUMERICSERV);
                    if (s == 0) {
                        printf("Accepted connection on descriptor %d "
                               "(host=%s, port=%s)\n", infd, hbuf, sbuf);
                    }

                    /* Make the incoming socket non-blocking and add it to the
                       list of fds to monitor. */
                    s = make_socket_non_blocking (infd);
                    if (s == -1)
                        abort ();

                    struct epoll_event event;
                    event.data.fd = infd;
                    event.events = EPOLLIN | EPOLLET;
                    s = epoll_ctl (efd, EPOLL_CTL_ADD, infd, &event);
                    if (s == -1) {
                        perror ("epoll_ctl");
                        abort ();
                    }
                }
                continue;
            } else {
                /* We have data on the fd waiting to be read. Read and
                   display it. We must read whatever data is available
                   completely, as we are running in edge-triggered mode
                   and won't get a notification again for the same
                   data. */
                int done = 0;

                while (1) {
                    ssize_t count;
                    char buf[2];

                    count = read (events[i].data.fd, buf, sizeof(buf) - 1);
                    if (count == -1) {
                        /* If errno == EAGAIN, that means we have read all
                           data. So go back to the main loop. */
                        if (errno != EAGAIN) {
                            perror ("read");
                            done = 1;
                        }
                        break;
                    } else if (count == 0) {
                        /* End of file. The remote has closed the
                           connection. */
                        done = 1;
                        break;
                    }
                    buf[count] = 0;

                    /* Write the buffer to standard output */
                    s = write (1, buf, count);
                    if (s == -1) {
                        perror ("write");
                        abort ();
                    }
                }

                if (done) {
                    printf ("Closed connection on descriptor %d\n",
                            events[i].data.fd);

                    /* Closing the descriptor will make epoll remove it
                       from the set of descriptors which are monitored. */
                    close (events[i].data.fd);
                }
            }

            handle_io_on_socket(events[i]);
        }
    }
    return 0;
}
