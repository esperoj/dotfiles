from pathlib import Path

from esperoj.database import get_database
from esperoj.utils import get_util


def download(category: str, dest: Path | None = None):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    if not dest:
        dest = Path(category)
    db = get_database("primary")
    files = db.get_table("files")
    records = list(filter(lambda r: len(getattr(r, category)) > 0, files.query()))
    download_info_list = [
        {
            **dict(record),
            "dest": dest / record.name,
        }
        for record in records
    ]
    results = get_util("download")(download_info_list)
    for error, download_info in results:
        if error:
            raise RuntimeError("Can't download all files")


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
    @click.argument("category", type=str, required=True)
    @click.argument(
        "dest",
        type=click.Path(exists=False, dir_okay=True, path_type=Path),
        required=False,
    )
    def click_command(category, dest):
        """Execute the download function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        download(category, dest)

    return click_command
