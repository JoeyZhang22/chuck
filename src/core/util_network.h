/*----------------------------------------------------------------------------
  ChucK Strongly-timed Audio Programming Language
    Compiler, Virtual Machine, and Synthesis Engine

  Copyright (c) 2003 Ge Wang and Perry R. Cook. All rights reserved.
    http://chuck.stanford.edu/
    http://chuck.cs.princeton.edu/

  This program is free software; you can redistribute it and/or modify
  it under the dual-license terms of EITHER the MIT License OR the GNU
  General Public License (the latter as published by the Free Software
  Foundation; either version 2 of the License or, at your option, any
  later version).

  This program is distributed in the hope that it will be useful and/or
  interesting, but WITHOUT ANY WARRANTY; without even the implied warranty
  of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
  MIT Licence and/or the GNU General Public License for details.

  You should have received a copy of the MIT License and the GNU General
  Public License (GPL) along with this program; a copy of the GPL can also
  be obtained by writing to the Free Software Foundation, Inc., 59 Temple
  Place, Suite 330, Boston, MA 02111-1307 U.S.A.
-----------------------------------------------------------------------------*/

//-----------------------------------------------------------------------------
// name: util_network.h
// desc: sockets
//
// author: Ge Wang (gewang@cs.princeton.edu)
//
// originally 'randy_socket'
// author: Peng Bi (pbi@cs.princeton.edu)
//         Ge Wang (gewang@cs.princeton.edu)
// date: Winter 2003
//-----------------------------------------------------------------------------
#ifndef __UTIL_NETWORK_H__
#define __UTIL_NETWORK_H__

#include "chuck_def.h"

#ifndef __PLATFORM_WINDOWS__
#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#else
#define _WINSOCKAPI_
#include <windows.h>
#endif

#include "chuck_def.h"


#if defined(_cplusplus) || defined(__cplusplus)
  extern "C" {
#endif

// our socket type
typedef struct ck_socket_ * ck_socket;

// create a UDP socket
ck_socket ck_udp_create( );
// create a TCP socket
ck_socket ck_tcp_create( int flags );
// connect to a server
t_CKBOOL ck_connect( ck_socket sock, const char * hostname, int port );
// connect to a server
t_CKBOOL ck_connect2( ck_socket sock, const struct sockaddr * serv_addr,
                      int addrlen);
// bind to a port
t_CKBOOL ck_bind( ck_socket sock, int port );
// listen (TCP)
t_CKBOOL ck_listen( ck_socket sock, int backlog );
// accept (TCP)
ck_socket ck_accept( ck_socket sock );

// send
int ck_send( ck_socket sock, const char * buffer, int len );
// send using connect/sendto
int ck_send2( ck_socket sock, const char * buffer, int len );
// send a datagram
int ck_sendto( ck_socket sock, const char * buffer, int len,
               const struct sockaddr * to, int tolen );

// recv
int ck_recv( ck_socket sock, char * buffer, int len );
// recv
int ck_recv2( ck_socket sock, char * buffer, int len );
// recv a datagram
int ck_recvfrom( ck_socket sock, char * buffer, int len,
                 struct sockaddr * from, int * fromlen );

// send timeout
int ck_send_timeout( ck_socket sock, long sec, long usec );
// recv timeout
int ck_recv_timeout( ck_socket sock, long sec, long usec );

// close the socket
void ck_close( ck_socket sock );


#if defined(_cplusplus) || defined(__cplusplus)
  }
#endif




#endif
