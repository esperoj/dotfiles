from esperoj.utils import get_util


def replicate(limit):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    get_util("replicate")(limit)


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        function: A function.
    """
    return replicate


def get_click_command():
    """Create a Click command for executing the replicate function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.option("--limit", required=False, type=int, default=16)
    def click_command(limit: int = 16):
        """Execute the replicate function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        replicate(limit)

    return click_command
