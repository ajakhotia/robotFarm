#!/usr/bin/env python3
import argparse
import os
from itertools import product
from typing import List

TEMPLATE = """name: validate-{lib_lower}-{os_base_fn}-{toolchain}.yaml

on:
  workflow_run:
    workflows: [ "robot-farm" ]
    types: [ completed ]

jobs:
  validate-install:
    if: ${{{{ github.event.workflow_run.conclusion == 'success' }}}}
    uses: ./.github/workflows/validate-library-install-template.yaml
    with:
      os_base: {os_base}
      toolchain: {toolchain}
      library_name: {library}
      image_tag: ${{{{ github.event.workflow_run.head_sha }}}}
"""


def parse_list(values: List[str]) -> List[str]:
    """
    Support both repeated flags and comma-separated values.
    Example:
      --library Eigen3 --library OpenCV
      --library Eigen3,OpenCV
    """
    out: List[str] = []
    for v in values:
        # split on comma, strip whitespace, drop empties
        parts = [p.strip() for p in v.split(",")]
        out.extend([p for p in parts if p])
    # de-duplicate while preserving order
    seen = set()
    uniq = []
    for item in out:
        if item not in seen:
            uniq.append(item)
            seen.add(item)
    return uniq


def os_base_to_filename(os_base: str) -> str:
    """Convert 'ubuntu:22.04' -> 'ubuntu-22-04' for filenames."""
    return os_base.replace(":", "-").replace(".", "-")


def generate_workflow_file(output_dir: str, library: str, os_base: str, toolchain: str) -> str:
    os_base_fn = os_base_to_filename(os_base)
    filename = f"validate-{library}-{os_base_fn}-{toolchain}.yaml"
    filepath = os.path.join(output_dir, filename)

    content = TEMPLATE.format(
        lib_lower=library.lower(),
        os_base_fn=os_base_fn,
        toolchain=toolchain,
        os_base=os_base,
        library=library,
    )

    os.makedirs(output_dir, exist_ok=True)
    with open(filepath, "w", encoding="utf-8") as f:
        f.write(content)

    return filepath


def build_badge_cell(repo_owner: str, repo_name: str, library: str, os_base: str, toolchain: str) -> str:
    osb_fn = os_base_to_filename(os_base)
    wf_file = f"validate-{library}-{osb_fn}-{toolchain}.yaml"
    return (f"[![status](https://github.com/{repo_owner}/{repo_name}"
            f"/actions/workflows/{wf_file}/badge.svg)]"
            f"(https://github.com/{repo_owner}/{repo_name}"
            f"/actions/workflows/{wf_file})")


def print_badge_table(libraries: List[str], os_bases: List[str], toolchains: List[str],
                      repo_owner: str, repo_name: str) -> None:
    combos = list(product(os_bases, toolchains))
    # Header
    header_cells = ["Library"] + [f"{osb} / {tc}" for osb, tc in combos]
    separator = ["---"] * len(header_cells)
    lines = []
    lines.append("| " + " | ".join(header_cells) + " |")
    lines.append("| " + " | ".join(separator) + " |")
    # Rows
    for library in libraries:
        row_cells = [library]
        for osb, tc in combos:
            row_cells.append(build_badge_cell(repo_owner, repo_name, library, osb, tc))
        lines.append("| " + " | ".join(row_cells) + " |")

    print("\n# Workflow Status Matrix\n")
    print("\n".join(lines))


def main():
    parser = argparse.ArgumentParser(
        description="Generate GitHub Actions workflow files for library/os_base/toolchain combinations "
                    "and print a Markdown badge table."
    )
    parser.add_argument("--library", "-l", action="append", required=True,
                        help="Library name (repeatable or comma-separated). Example: --library Eigen3,OpenCV")
    parser.add_argument("--os-base", "-o", action="append", required=True,
                        help="Base OS in colon form (repeatable or comma-separated). Example: --os-base ubuntu:22.04")
    parser.add_argument("--toolchain", "-t", action="append", required=True,
                        help="Toolchain (repeatable or comma-separated). Example: --toolchain linux-gnu-12")
    parser.add_argument("--repo-owner", default="ajakhotia", help="GitHub repo owner. Default: %(default)s")
    parser.add_argument("--repo-name", default="robotFarm", help="GitHub repo name. Default: %(default)s")
    parser.add_argument("--output-dir", default=".github/workflows",
                        help="Directory to write workflow files. Default: %(default)s")

    args = parser.parse_args()

    libraries = parse_list(args.library)
    os_bases = parse_list(args.os_base)
    toolchains = parse_list(args.toolchain)

    if not libraries:
        parser.error("No libraries provided.")
    if not os_bases:
        parser.error("No os_bases provided.")
    if not toolchains:
        parser.error("No toolchains provided.")

    # Generate workflows
    for library, os_base, toolchain in product(libraries, os_bases, toolchains):
        path = generate_workflow_file(args.output_dir, library, os_base, toolchain)
        print(f"Generated {path}")

    # Print the Markdown table of badges
    print_badge_table(libraries, os_bases, toolchains, args.repo_owner, args.repo_name)


if __name__ == "__main__":
    main()
