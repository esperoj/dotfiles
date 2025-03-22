from esperoj.logging import get_logger
from esperoj.utils import get_util
from pathlib import Path
from esperoj.database import get_database
from esperoj.database.models import Audio

logger = get_logger(__name__)
ingest_file = get_util("ingest_file")
audios = get_database("primary").get_table("audios")


def ingest_audio(file_path):
    logger.info("Started to ingest audio '%s'", metadata["title"])
    file = ingest_file(file_path, ["catbox", "internet-archive", "qu-ax"])
    metadata = file.metadata
    metadata = {
                "title": metadata["Title"],
                "creator": [metadata["Artist"]]
                if isinstance(metadata.get("Artist", ""), str)
                else metadata["Artist"]
            }
    audio = audios.create(dict(Audio(files=[file.id], **metadata)))
    logger.info("Ingested audio '%s'", audio.title)


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return ingest_audio


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
    def click_command(file_path):
        """Execute the export_database function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
            identifier (str): The name of the database to export.
        """
        ingest_audio(file_path)

    return click_command
