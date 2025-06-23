from esperoj.log import get_logger
from esperoj.utils import get_util
from pathlib import Path
from esperoj.database import get_database
from internetarchive import upload

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
        "composer": song.composers,
        "title": song.title,
        "creator": song.artists,
        "www": song.www,
    }
    upload(
        song.identifier,
        files=[str(path)],
        metadata=metadata,
        verbose=True,
        verify=True,
        delete=True,
        retries=10,
        retries_sleep=6,
        validate_identifier=True,
    )[0]
    breakpoint()
    logger.info("Uploaded song '%s'", song.title)
    print(f"https://archive.org/details/{song.identifier}")


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
