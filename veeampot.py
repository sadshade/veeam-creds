#!/usr/bin/env python3

from http.server import HTTPServer, BaseHTTPRequestHandler
import ssl
import re

SERVER_PORT = 8443 # Listen port
ReqNum = 1

class RequestHandler(BaseHTTPRequestHandler):
    
    
    def _add_headers(self):
        global ReqNum
        self.send_response(500 if ReqNum == 5 else 200)
        self.send_header('Content-type', 'text/html' if ReqNum == 1 else 'text/xml')
        self.end_headers()
    
    def _counter(self):
        global ReqNum
        #print(ReqNum)
        if ReqNum == 5:
            ReqNum = 1
        else:
            ReqNum += 1        

    def do_GET(self):
        global ReqNum
        self._add_headers()
        with open("data/resp-{}.txt".format(ReqNum), 'rb') as file: 
            self.wfile.write(file.read())
        self._counter()
                
    def do_POST(self):
        global ReqNum
        content_length = int(self.headers['Content-Length'])
        post_data = self.rfile.read(content_length).decode('utf-8')
        self._add_headers()
        with open("data/resp-{}.txt".format(ReqNum), 'rb') as file: 
            self.wfile.write(file.read())
        
        if ReqNum == 5 :
            print("Login: " + re.search('<userName>(.*)</userName>', post_data, re.IGNORECASE).group(1))
            print("Password: " + re.search('<password>(.*)</password>', post_data, re.IGNORECASE).group(1))
        self._counter()
    
    def log_message(self, format, *args):
        return

def run(server_class=HTTPServer, handler_class=RequestHandler, port=SERVER_PORT):
    server_address = ('', port)
    httpd = server_class(server_address, handler_class)
    httpd.socket = ssl.wrap_socket (httpd.socket, certfile='data/cert.pem', keyfile='data/key.pem', server_side=True)
    print('Waiting Veeam on port {}...\n'.format(SERVER_PORT))
    try:
        httpd.serve_forever()
    except KeyboardInterrupt:
        pass
    httpd.server_close()
    print('Stopping...')

if __name__ == '__main__':
        run()
