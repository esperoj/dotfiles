import json
from esperoj.database import get_database


def export_database(name):
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    db = get_database(name, None)
    metadata = db.metadata  # type: ignore
    for table in metadata["tables"]:
        table_name = table["name"]
        data = [record.model_dump() for record in db.get_table(table_name).query()]
        with open(f"{table_name}.json", "w") as f:
            json.dump(data, f)
    with open("metadata.json", "w") as f:
        json.dump(metadata, f)


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return export_database


def get_click_command():
    """Create a Click command for executing the export_database function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.argument("name", type=click.STRING, required=True)
    def click_command(name):
        """Execute the export_database function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
            name (str): The name of the database to export.
        """
        export_database(name)

    return click_command
