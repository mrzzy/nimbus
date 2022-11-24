#
# Nimbus
# Proxy GAE
# Template Nginx Conf
#

import re, os
from argparse import ArgumentParser
from textwrap import dedent
from typing import Dict
from jinja2 import Environment, FileSystemLoader, PackageLoader


def parse_proxy(spec_str: str) -> Dict[str, str]:
    """Parse the given proxy spec into a dictionary of routes to target"""
    specs = [route.split("=") for route in spec_str.split()]

    # strip trailing '/' for standardization
    spec = dict([(route.strip("/"), route.strip("/")) for route, target in specs])

    # check: no reserved routes
    if "/health" in spec:
        raise ValueError("'/health' route is reserved for health checks.")

    return spec


if __name__ == "__main__":
    # parse command line arguments
    parser = ArgumentParser(description="Template nginx.conf for Proxy GAE")
    parser.add_argument(
        "proxy_spec",
        type=parse_proxy,
        help=dedent(
            """Specify routes that should be proxied in the format:
            '/<ROUTE>=<TARGET> [/<ROUTE>=<TARGET2> ...]'
            Example: '/proxy=https://proxy.me' will proxy all requests sent to
            '/proxy/target/url' to 'https://proxy.me/target/url'
            """
        ),
    )
    parser.add_argument(
        "--output-path",
        type=str,
        help="Path to write the templated nginx.conf",
        default="/etc/nginx/nginx.conf",
    )
    args = parser.parse_args()

    # template nginx config
    env = Environment(loader=FileSystemLoader(os.getcwd()))
    nginx_conf = env.get_template("nginx.conf.jinja2").render(
        proxy_spec=args.proxy_spec
    )

    with open(args.output_path, "w") as f:
        f.write(nginx_conf)
