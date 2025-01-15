from esperoj.utils import get_util
from esperoj.database import get_database

from esperoj.exceptions import VerificationError
from esperoj.logging import get_logger

logger = get_logger(__name__)


def is_verified(file):
    if not file.verified:
        return False
    for mirror_info in file.mirrors.values():
        for source in mirror_info["sources"]:
            if not source["verified"]:
                return False


def verify(name: str):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    db = get_database("primary")
    files = db.get_table("files")
    file = next(filter(lambda f: f.name == name, files.query()))
    results = get_util("verify")([file])
    if not all(results):
        raise VerificationError([file.name])
    else:
        if not is_verified(file):
            file.verified = True
            for mirror_info in file.mirrors.values():
                for source in mirror_info["sources"]:
                    source["verified"] = True
            files.update(dict(file))
        logger.info("Successed verified file '%s'.", file.name)


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        function: A function.
    """
    return verify


def get_click_command():
    """Create a Click command for executing the verify function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument("name", type=str, required=True)
    def click_command(name):
        """Execute the verify function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        verify(name)

    return click_command
