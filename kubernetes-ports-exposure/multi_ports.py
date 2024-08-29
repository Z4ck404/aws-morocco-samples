import http.server
import socketserver
from http.server import SimpleHTTPRequestHandler
import threading

class CustomHandler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        response = f"Hello from port {self.server.server_address[1]}!"
        self.wfile.write(response.encode())

def run_server(port):
    with socketserver.TCPServer(("", port), CustomHandler) as httpd:
        print(f"Serving on port {port}")
        httpd.serve_forever()

if __name__ == "__main__":
    ports = [8080, 9090, 5000]
    threads = []
    for port in ports:
        thread = threading.Thread(target=run_server, args=(port,))
        threads.append(thread)
        thread.start()

    for thread in threads:
        thread.join()