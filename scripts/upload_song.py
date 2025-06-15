from esperoj.logging import get_logger
from esperoj.utils import get_util
from pathlib import Path
from esperoj.database import get_database
from esperoj.database.models import Song
from internetarchive import get_item

logger = get_logger(__name__)
ingest_file = get_util("ingest_file")
songs = get_database("primary").get_table("songs")
files = get_database("primary").get_table("files")


def ingest_song(path):
    file_name = path.name
    logger.info("Started to upload file '%s'", file_name)
    file = next(filter(lambda r: r.name == file_name, files.query()))
    song = songs.get(file.songs[0])
    metadata = {
        "mediatype": "audio",
        "collection": "opensource_audio",
        "description": song.description,
        "subject": song.subjects,
        "language": song.language,
        "album": song.album,
        "composer": song.composer,
        "title": song.title,
        "creator": song.artist,
    }
    item = get_item(song.identifier)
    res = item.upload(
        files=[str(path)],
        metadata=metadata,
        verbose=True,
        verify=True,
        delete=True,
        retries=10,
        retries_sleep=6,
        validate_identifier=True,
    )[0]
    res.raise_for_status()
    logger.info("Uploaded song '%s'", song.title)


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
