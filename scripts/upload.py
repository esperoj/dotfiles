from pathlib import Path

from esperoj.utils import get_util


def upload(src: Path, mirror: str):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    f = src.open("rb")
    upload_info = {
        "name": src.name,
        "mirrors": {mirror: {"sources": [], "encrypted": False}},
        "sha256": get_util("calculate_hash")(f, algorithm="sha256"),
        "size": src.stat().st_size,
        "src": src,
    }
    f.close()
    print(get_util("upload")([upload_info]))


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        function: A function.
    """
    return upload


def get_click_command():
    """Create a Click command for executing the upload function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument(
        "src",
        type=click.Path(exists=True, dir_okay=False, path_type=Path),
        required=True,
    )
    @click.argument("mirror", type=str, required=True)
    def click_command(src, mirror):
        """Execute the upload function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        upload(src, mirror)

    return click_command
