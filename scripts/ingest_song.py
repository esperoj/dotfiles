from esperoj.logging import get_logger
from esperoj.utils import get_util
from pathlib import Path
from esperoj.database import get_database
from esperoj.database.models import Song

logger = get_logger(__name__)
ingest_file = get_util("ingest_file")
songs = get_database("primary").get_table("songs")


def ingest_song(path):
    logger.info("Started to ingest file '%s'", path.name)
    file = ingest_file(path, ["catbox", "internet-archive", "qu-ax"])
    metadata = file.metadata
    metadata = {
        "title": metadata["Title"],
        "creator": [metadata["Artist"]]
        if isinstance(metadata.get("Artist", ""), str)
        else metadata["Artist"],
    }
    song = songs.create(dict(Song(files=[file.id], **metadata)))
    logger.info("Ingested song '%s'", song.title)


def get_esperoj_method():
    return ingest_song


def get_click_command():
    import click

    @click.command()
    @click.argument(
        "path",
        type=click.Path(exists=True, dir_okay=False, path_type=Path),
        required=True,
    )
    def click_command(path):
        ingest_song(path)

    return click_command
