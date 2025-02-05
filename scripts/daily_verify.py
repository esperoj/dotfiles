from esperoj.utils import get_util
from esperoj.database import get_database
import datetime
from esperoj.exceptions import VerificationError


def is_verified(file):
    for mirror_info in file.mirrors.values():
        for source in mirror_info["sources"]:
            if not source["verified"]:
                return False
    return file.verified


def is_completed(file):
    for mirror_info in file.mirrors.values():
        if len(mirror_info["sources"]) == 0:
            return False
    return True


def daily_verify(today: int | None = None):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    db = get_database("primary")
    files_table = db.get_table("files")
    files = sorted(
        files_table.query(),
        key=lambda file: file.created,
        reverse=True,
    )
    files = list(filter(is_completed, files))
    num_shards = 28
    shard_size, extra = divmod(len(files), num_shards)
    today = (
        today
        if today is not None
        else datetime.datetime.now(datetime.UTC).day % num_shards
    )
    begin = (shard_size + 1) * today if today < extra else shard_size * today
    end = begin + shard_size + (1 if today < extra else 0)
    files_to_process = files[begin:end]

    results = get_util("verify")(files_to_process)
    if not all(result[1] for result in results):
        raise VerificationError(
            [file.name for file, result in results if result is False]
        )
    else:
        update_fields_list = []
        for file in files_to_process:
            if not is_verified(file):
                file.verified = True
                for mirror_info in file.mirrors.values():
                    for source in mirror_info["sources"]:
                        source["verified"] = True
                update_fields_list.append(dict(file))
        if len(update_fields_list) > 0:
            files_table.batch_update(update_fields_list)


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        function: A function.
    """
    return daily_verify


def get_click_command():
    """Create a Click command for executing the daily_verify function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument("today", type=int, required=False)
    def click_command(today):
        """Execute the daily_verify function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        daily_verify(today)

    return click_command
