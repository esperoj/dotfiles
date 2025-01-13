from pathlib import Path

from esperoj.database import get_database
from esperoj.utils import get_util

def download(name, dest: Path = None):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    if not dest:
        dest = Path(name)
    if dest.is_dir():
        dest = dest / name
    db = get_database("primary")
    files = db.get_table("files")
    record = list(filter(lambda r: r.name == name, files.query()))[0]

    download_info = {
        **dict(record),
        "dest": dest,
    }
    get_util("download")([download_info])[0]


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        function: A function.
    """
    return download


def get_click_command():
    """Create a Click command for executing the download function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument("name", type=str, required=True)
    @click.argument(
        "dest",
        type=click.Path(exists=False, dir_okay=True, path_type=Path),
        required=False,
    )
    def click_command(name, dest):
        """Execute the download function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        download(name, dest)

    return click_command
