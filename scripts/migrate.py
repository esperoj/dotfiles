from esperoj.database import get_database


def migrate():
    """Export the data and metadata of a database to JSON files.

    Args:
        esperoj (object): An object containing the databases.
        name (str): The name of the database to export.

    Returns:
        None
    """
    db = get_database("primary")
    files = db.get_table("files")
    files.query()
    breakpoint()


def get_esperoj_method():
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        function: A function.
    """
    return migrate


def get_click_command():
    """Create a Click command for executing the migrate function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    def click_command():
        """Execute the migrate function with the esperoj object and database name.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        migrate()

    return click_command


"""
    results = files.batch_update(
        [
            {
                "id": record.id,
                "mirrors": {
                    "internet-archive": record.mirrors["internet_archive"],
                    "audio-0": record.mirrors["audio_storage"],
                    "audio-1": record.mirrors["backup_audio_storage"],
                    "catbox": {"sources": [], "encrypted": False},
                },
            }
            for record in records
        ]
    )
"""
