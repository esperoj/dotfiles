from esperoj.logging import get_logger
from esperoj.utils import get_util
import tomllib
from pathlib import Path
from esperoj.database import get_database
from esperoj.database.models import Album

logger = get_logger(__name__)
ingest_file = get_util("ingest_file")
albums = get_database("primary").get_table("albums")


def ingest_album(file_path, metadata_file):
    metadata = tomllib.loads(metadata_file.read_text())
    logger.info("Started to ingest album '%s'", metadata["title"])
    file = ingest_file(file_path, ["catbox", "internet-archive"])
    album = albums.create(dict(Album(files=[file.id], **metadata)))
    logger.info("Ingested album '%s'", album.title)


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
        "file_path",
        type=click.Path(exists=True, dir_okay=False, path_type=Path),
        required=True,
    )
    @click.option(
        "--metadata-file",
        "-m",
        type=click.Path(exists=True, dir_okay=False, path_type=Path),
        required=True,
    )
    def click_command(file_path, metadata_file):
        """Execute the export_database function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
            identifier (str): The name of the database to export.
        """
        ingest_album(file_path, metadata_file)

    return click_command
