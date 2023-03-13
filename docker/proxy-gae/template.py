#
# Nimbus
# Proxy GAE
# Template Nginx Conf
#

import re, os
from argparse import ArgumentParser
from textwrap import dedent
from typing import Dict
from dns.resolver import Resolver
from jinja2 import Environment, FileSystemLoader, PackageLoader


def parse_proxy(spec_str: str) -> Dict[str, str]:
    """Parse the given proxy spec into a dictionary of routes to target"""
    specs = [route.split("=") for route in spec_str.split()]

    # strip trailing '/' for standardization
    spec = dict([(route.rstrip("/"), target.rstrip("/")) for route, target in specs])

    # check: no empty hosts
    if "" in spec:
        raise ValueError("Proxy specs with no host are not supported.")

    return spec


if __name__ == "__main__":
    # parse command line arguments
    parser = ArgumentParser(description="Template nginx.conf for Proxy GAE")
    parser.add_argument(
        "hostname",
        type=str,
        help="Root hostname from which sub-hosts specified on proxy_spec are relative",
    )
    parser.add_argument(
        "proxy_spec",
        type=parse_proxy,
        help=dedent(
            """Specify sub-hosts that should be proxied in the format:
            '<HOST>=<TARGET> [<HOST>=<TARGET2> ...]'
            Example: 'proxy=https://target.host' will proxy all requests sent to
            'proxy.<hostname>/target/url' to 'https://target.host/target/url'
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
    env = Environment(loader=FileSystemLoader(os.getcwd()), autoescape=True)
    nginx_conf = env.get_template("nginx.conf.jinja2").render(
        root=args.hostname,
        proxy_spec=args.proxy_spec,
        nameservers=" ".join(Resolver().nameservers),
    )
    with open(args.output_path, "w") as f:
        f.write(nginx_conf)
