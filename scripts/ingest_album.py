from esperoj.logging import get_logger
import tomllib
from pathlib import Path
import subprocess
from urllib.parse import quote

logger = get_logger(__name__)


def upload(src, dest):
    subprocess.call(
        ["rclone", "sync", "-v", src, dest],
    )


def ingest_album(src, metadata_file):
    metadata = tomllib.loads(metadata_file.read_text())
    files = sorted([file.name for file in src.glob("*")])
    images = [
        f"""![{file}](https://ik.imagekit.io/xiwang/{metadata['identifier']}/{quote(file)})"""
        for file in files
    ]
    upload(str(src), f'imagekit:{metadata["identifier"]}')
    text = f"""# {metadata["title"]}

Identifier: {metadata["identifier"]}
Creator: {metadata["creator"]}
Date: {metadata["date"]}
Description: {metadata["description"]}
Subject: {', '.join(metadata["subject"])}
Collection: {metadata["collection"]}
Source: {', '.join(metadata["source"])}
Download: {metadata["download_url"]}

# Images

{'\n'.join(images)}"""
    print(text)


# identifier-access
def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return ingest_album


def get_click_command():
    """Create a Click command for executing the export_database function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument(
        "src",
        type=click.Path(exists=True, dir_okay=True, path_type=Path),
        required=True,
    )
    @click.argument(
        "metadata_file",
        type=click.Path(exists=True, dir_okay=False, path_type=Path),
        required=True,
    )
    def click_command(src, metadata_file):
        """Execute the export_database function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
            identifier (str): The name of the database to export.
        """
        ingest_album(src, metadata_file)

    return click_command
