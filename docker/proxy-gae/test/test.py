#
# Nimbus
# Proxy GAE
# End to End Test
#

from time import sleep
from testcontainers.compose import DockerCompose
import requests

PROXY_URL = "http://localhost:8080"

if __name__ == "__main__":
    with DockerCompose(
        ".", compose_file_name="docker-compose.yaml", build=True, pull=True
    ) as c:
        c.start()
        # wait for proxy target to start listening for requests
        c.wait_for("http://localhost:8081")

        for host, route, expected_status in [
            # test: proxy returns 404 on undefined routes
            ["undefined", "/", 404],
            # test: proxy returns 200 on proxied routes
            ["target", "/test/e2e", 200],
            ["alt.target", "/test/e2e", 200],
        ]:
            got_status = requests.get(
                f"{PROXY_URL}{route}",
                headers={"Host": host},
            ).status_code
            print(f"GET http://{host}{route} {got_status}")

            assert expected_status == got_status
