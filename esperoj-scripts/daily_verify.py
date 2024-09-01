"""Script to verify daily."""

import datetime
from functools import partial

from esperoj.exceptions import VerificationError


def daily_verify(esperoj) -> None:
    """Verify the integrity of files stored in various locations.

    This function retrieves a list of files from the "Files" table in the "Primary" database.
    It then verifies that the hash of the file stored in the primary storage, backup storage,
    and Internet Archive matches the expected SHA256 hash stored in the database.

    If any file fails the verification process, a VerificationError is raised with the names
    of the failed files.

    Args:
        esperoj (object): An object containing the necessary databases, storages, and loggers.

    Raises:
        VerificationError: If the verification of one or more files fails.
    """
    file_hosts = esperoj.config["file_hosts"]
    files = sorted(
        esperoj.databases["Primary"].get_table("Files").query(),
        key=lambda file: file["Created"],
        reverse=True,
    )
    files = [
        file
        for file in files
        if all(file.fields.get(key) for key in file_hosts)
        and file["Verified"]
        and file["Internet Archive"] != "https://example.com/"
    ]
    num_shards = 28
    shard_size, extra = divmod(len(files), num_shards)
    today = datetime.datetime.now(datetime.UTC).day % num_shards
    begin = (shard_size + 1) * today if today < extra else shard_size * today
    end = begin + shard_size + (1 if today < extra else 0)

    results = esperoj.utils.verify(esperoj, files[begin:end])
    if not all(results):
        raise VerificationError("Failed to verify one or more file.")


def get_esperoj_method(esperoj):
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return partial(daily_verify, esperoj)


def get_click_command():
    """Create a Click command for executing the daily_verify function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.pass_obj
    def click_command(esperoj):
        """Execute the daily_verify function with the esperoj object.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        daily_verify(esperoj)

    return click_command
