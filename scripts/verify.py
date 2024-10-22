"""Script to replicate files."""

from functools import partial

from esperoj.exceptions import VerificationError


def verify(esperoj, max_files: int = 16) -> None:
    """Verify files.

    Args:
        esperoj (object): An object containing the necessary databases, storages, and loggers.

    Raises:
        VerificationError: If the verification of one or more files failed.
    """
    files = sorted(
        esperoj.databases["primary"]["files"].query(),
        key=lambda file: file.created,
        reverse=True,
    )
    files_to_process = [file for file in files if not file.verified][:max_files]
    results = esperoj.utils.verify(esperoj, files_to_process)
    if not all(results):
        raise VerificationError("Failed to verify one or more file.")


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
    @click.option("--max-files", "-m", type=int, default=16)
    @click.pass_obj
    def click_command(esperoj, max_files):
        """Execute the daily_verify function with the esperoj object.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        verify(esperoj, max_files)

    return click_command
