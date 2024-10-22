from functools import partial
from pathlib import Path

from esperoj.database.database import Record


def ingest_music(esperoj, path: Path) -> list[Record]:
    """Ingest a file into the Esperoj system.

    Args:
        esperoj (object): The Esperoj object representing the system.
        path (Path): The path to be ingested.

    Returns:
        list(Record): The database records representing the ingested files.

    """
    storage_names = ["Audio Storage", "Backup Audio Storage"]

    def post_process(file_path: Path, metadata: dict, file: Record) -> Record:
        audio = esperoj.databases["Primary"].get_table("Audio")
        audio_record = audio.create(
            {
                "Title": metadata["Title"],
                "Artist": [metadata["Artist"]]
                if isinstance(metadata.get("Artist", ""), str)
                else metadata["Artist"],
                "Comment": metadata.get("Comment", ""),
                "Files": [file.record_id],
            }
        )
        # TODO: Remove this later, since this is a bug of Seatable
        files = esperoj.databases["Primary"].get_table("Files")
        files.update_link("Audio", "Audio", file.record_id, [audio_record.record_id])
        return audio_record

    return esperoj.utils.ingest(esperoj, path, storage_names, post_process)


def get_esperoj_method(esperoj):
    """Get the method to ingest files into the Esperoj system.

    Args:
        esperoj (object): The Esperoj object representing the system.

    Returns:
        function: A partial function that takes a file path as an argument and ingests the file.
    """
    return partial(ingest_music, esperoj)


def get_click_command():
    """Get the Click command to ingest a file into the Esperoj system.

    Returns:
        click.Command: The Click command to ingest a file.
    """
    import click

    @click.command()
    @click.argument(
        "path",
        type=click.Path(exists=True, dir_okay=True, path_type=Path),
        required=True,
    )
    @click.pass_obj
    def click_command(esperoj, path: Path):
        """Ingest a file or a folder into the Esperoj system.

        Args:
            esperoj (object): The Esperoj object representing the system.
            path (Path): The path to be ingested.
        """
        print(ingest_music(esperoj, path))

    return click_command
