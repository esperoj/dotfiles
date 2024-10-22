from esperoj.server import run


def server():
    """Start esperoj web server."""
    run()


def get_esperoj_method(esperoj):
    """Return a function."""
    return server


def get_click_command():
    """Create a Click command for executing the info function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    def click_command():
        server()

    return click_command
