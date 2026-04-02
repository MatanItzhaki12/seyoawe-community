#!/usr/bin/env python3
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
import os


def main() -> None:
    module_dir = Path(__file__).resolve().parent
    os.chdir(module_dir)
    port = int(os.environ.get("WEBFORM_ASSETS_PORT", "9000"))
    server = ThreadingHTTPServer(("127.0.0.1", port), SimpleHTTPRequestHandler)
    print(f"[webform-assets] Serving {module_dir} on http://127.0.0.1:{port}")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        pass
    finally:
        server.server_close()


if __name__ == "__main__":
    main()
