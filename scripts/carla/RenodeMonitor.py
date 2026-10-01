# Copyright (c) 2026 Antmicro <www.antmicro.com>
#
# This work is licensed under the terms of the MIT license.
# For a copy, see <https://opensource.org/licenses/MIT>.

# Client for the Renode Monitor accessed through the Robot server.

from xmlrpc.client import ServerProxy

class RenodeMonitor:

    def __init__(self, port):
        self._server = ServerProxy(f"http://localhost:{port}/")
        try:
            self._server.get_keyword_names()
        except Exception:
            raise ConnectionError(f"No Renode Robot server on port {port}, start Renode with --robot-server-port {port}") from None

    def execute(self, command):
        result: dict[str, object] = self._server.run_keyword("ExecuteCommand", [command])  # type: ignore
        if result.get("status") == "FAIL":
            raise RuntimeError(result.get("error", f"{command} failed"))
        return result.get("return", "")

    def run_for(self, seconds):
        self.execute(f'emulation RunFor "{seconds}"')
