"""Script to replicate files."""

from functools import partial


def verify(esperoj, max_files: int = 50) -> None:
    """Verify files.

    Args:
        esperoj (object): An object containing the necessary databases, storages, and loggers.

    Raises:
        VerificationError: If the verification of one or more files failed.
    """
    file_hosts = esperoj.config["file_hosts"]
    files = sorted(
        esperoj.databases["Primary"].get_table("Files").query(),
        key=lambda file: file["Created"],
        reverse=True,
    )
    files_to_process = [
        file
        for file in files
        if all(file.fields.get(key) for key in [*file_hosts, "Internet Archive"])
        and not file["Verified"]
    ]
    files_to_process = files_to_process[:max_files]
    esperoj.utils.verify(esperoj, files_to_process)


def get_esperoj_method(esperoj):
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return partial(verify, esperoj)


def get_click_command():
    """Create a Click command for executing the daily_verify function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.option("--max-files", "-m", type=int, default=50)
    @click.pass_obj
    def click_command(esperoj, max_files):
        """Execute the daily_verify function with the esperoj object.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        verify(esperoj, max_files)

    return click_command
