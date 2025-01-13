from functools import partial


def info(esperoj):
    """Show info.

    Args:
        esperoj (object): An object passed from the parent function.

    Returns:
        None
    """
    import json

    exit()

    files = json.load(open("files.json", "r"))
    records = []
    for file in files:
        mirrors = json.loads(file["mirrors"])
        mirrors_update = {
            "internet_archive": {
                "sources": [
                    {
                        "src": mirrors["internet_archive"]["sources"][0],
                        "sha256": file["sha256"],
                        "size": file["size"],
                        "verified": True,
                    }
                ],
                "encrypted": False,
            },
            "filehaus": {
                "sources": [
                    {
                        "src": mirrors["file_haus"]["sources"][0],
                        "sha256": file["sha256"],
                        "size": file["size"],
                        "verified": True,
                    }
                ],
                "encrypted": False,
            },
            "lain_la": {
                "sources": [
                    {
                        "src": mirrors["lain_la"]["sources"][0],
                        "sha256": file["sha256"],
                        "size": file["size"],
                        "verified": True,
                    }
                ],
                "encrypted": False,
            },
            "audio_storage": {
                "sources": [
                    {
                        "src": mirrors["audio_storage"]["sources"][0],
                        "sha256": file["sha256"],
                        "size": file["size"],
                        "verified": True,
                    }
                ],
                "encrypted": False,
            },
            "backup_audio_storage": {
                "sources": [
                    {
                        "src": mirrors["backup_audio_storage"]["sources"][0],
                        "sha256": file["sha256"],
                        "size": file["size"],
                        "verified": True,
                    }
                ],
                "encrypted": False,
            },
        }
        records.append({"id": file["_id"], "mirrors": mirrors_update})
    esperoj.databases["primary"].batch_update("files", records)


def get_esperoj_method(esperoj):
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return partial(info, esperoj)


def get_click_command():
    """Create a Click command for executing the info function.

    Returns:
        click.Command: A Click command object.
    """
    import click

    @click.command()
    @click.pass_obj
    def click_command(esperoj):
        """Execute the info function with the esperoj object.

        Args:
            esperoj (object): An object passed from the parent function.
        """
        info(esperoj)

    return click_command
