import argparse
import logging
import json
import os
import signal
import subprocess
from utils import get_platform_tag



def main() -> None:

    parser = argparse.ArgumentParser(description="Fetch and extract tarballs")
    parser.add_argument("--download-dir", default="build")
    parser.add_argument("--cache-dir", default="tarballs")
    parser.add_argument("--config-file", default=os.path.splitext(__file__)[0] + ".json")
    args = parser.parse_args()
    logging.basicConfig(level=logging.INFO)

    download_dir: str = args.download_dir
    cache_dir: str = args.cache_dir

    # read config file
    with open(args.config_file, "r") as fp:
        config = json.load(fp)

    # ensure destination directory exists
    logging.info(f"Creating directory {download_dir}")
    if not os.path.exists(download_dir):
        os.makedirs(download_dir)

    for url_template in config["urls"]:
        tarball_url = url_template.replace("{platform}", get_platform_tag())

        # download tarball
        tarball_name = tarball_url.split("/")[-1]
        tarball_file = os.path.join(cache_dir, tarball_name)
        if not os.path.exists(tarball_file):
            logging.info("Downloading %s" % tarball_url)
            if not os.path.exists(cache_dir):
                os.mkdir(cache_dir)
            subprocess.check_call(
                ["curl", "--location", "--output", tarball_file, "--silent", tarball_url]
            )

        # extract tarball
        logging.info("Extracting %s" % tarball_name)
        subprocess.check_call(["tar", "-C", download_dir, "-xf", tarball_file])


if __name__ == "__main__":
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    main()