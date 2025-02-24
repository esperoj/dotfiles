from internetarchive import get_item
from esperoj.database import get_database
from esperoj.logging import get_logger

logger = get_logger(__name__)


def ingest_movie(identifier):
    item = get_item(identifier)
    metadata = item.item_metadata["metadata"]
    logger.info(f"Ingesting {metadata["title"]}")
    if metadata.get("contributor"):
        metadata["contributor"] = metadata["contributor"].split("; ")
    if type(metadata.get("subject")) is str:
        metadata["subject"] = metadata["subject"].split(";")
    metadata["include_reg"] = "^.+\\.mkv$"
    movies = get_database("primary").get_table("movies")
    record = movies.create(metadata)
    if record:
        logger.info("Successed ingest record '%s'", record.id)


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return ingest_movie


def get_click_command():
    """Create a Click command for executing the export_database function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument("identifier", type=str, required=True)
    def click_command(identifier):
        """Execute the export_database function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
            identifier (str): The name of the database to export.
        """
        ingest_movie(identifier)

    return click_command
