#!/usr/bin/env python3

import subprocess
import sys
import os
from typing import List, Tuple

# ANSI color codes for terminal output


class Colors:
    GREEN = '\033[0;32m'
    YELLOW = '\033[0;33m'
    RED = '\033[0;31m'
    NC = '\033[0m'  # No Color


def log(message: str) -> None:
    """Print an info message with green color."""
    print(f"{Colors.GREEN}[INFO]{Colors.NC} {message}")


def warn(message: str) -> None:
    """Print a warning message with yellow color."""
    print(f"{Colors.YELLOW}[WARN]{Colors.NC} {message}")


def error(message: str) -> None:
    """Print an error message with red color."""
    print(f"{Colors.RED}[ERROR]{Colors.NC} {message}")


def command_exists(command: str) -> bool:
    """Check if a command exists in the system."""
    try:
        subprocess.run(["which", command], stdout=subprocess.PIPE,
                       stderr=subprocess.PIPE, check=True)
        return True
    except subprocess.CalledProcessError:
        return False


def install_with_curl(name: str, command: str) -> bool:
    """Run a curl installation command and return success status."""
    log(f"Installing {name}...")
    try:
        subprocess.run(command, shell=True, check=True)
        log(f"{name} installed successfully")
        return True
    except subprocess.CalledProcessError as e:
        error(f"Failed to install {name}: {e}")
        return False


def main() -> int:
    """Main function to run all curl installations."""
    log("Starting curl-based installations...")

    # List of installations in format: (name, curl_command)
    curl_installations: List[Tuple[str, str]] = [
        ("PNPM",
         "curl -fsSL https://get.pnpm.io/install.sh | sh -"),

        ("Oh My Fish",
         "curl https://raw.githubusercontent.com/oh-my-fish/oh-my-fish/master/bin/install | fish"),

        ("Rust",
         "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh"),
    ]

    success_count = 0
    failure_count = 0

    for name, command in curl_installations:
        if install_with_curl(name, command):
            success_count += 1
        else:
            failure_count += 1
            warn("Continuing with next installation")

    log(f"All curl-based installations completed!")
    log(f"Summary: {success_count} successful, {failure_count} failed")

    return 0 if failure_count == 0 else 1


if __name__ == "__main__":
    sys.exit(main())
