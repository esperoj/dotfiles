"""Script to replicate files."""

import concurrent.futures
import time
from functools import partial

import tempfile
from pathlib import Path

from esperoj.exceptions import ReplicationError, VerificationError


def replicate(esperoj, max_files: int = 16) -> None:
    """Replicate files to file hosts and Internet Archive

    Args:
        esperoj (object): An object containing the necessary databases, storages, and loggers.

    Raises:
        VerificationError: If the verification of one or more files failed.
        ReplicationError: If the replication of one or more files failed.
    """
    logger = esperoj.loggers["Primary"]
    storages = esperoj.storages
    file_hosts = esperoj.config["file_hosts"]
    files = sorted(
        esperoj.databases["Primary"].get_table("Files").query(),
        key=lambda file: file["Created"],
        reverse=True,
    )
    files_to_process = [
        file
        for file in files
        if file["Internet Archive"] == "https://example.com/"
        or not all(file.fields.get(key) for key in file_hosts)
    ]
    files_to_process = files_to_process[:max_files]

    def replicate_file(file):
        name = file["Name"]
        start_time = time.time()
        logger.info(f"Start replicating file `{name}`")
        hosts_to_upload = [host for host in file_hosts if not file.fields.get(host)]
        with tempfile.TemporaryDirectory() as temp_dir:
            file_path = Path(temp_dir) / name
            storages[file["Storages"][0]].download_file(name, str(file_path))
            f = file_path.open("rb")
            sha256 = esperoj.utils.calculate_hash(f, algorithm="sha256")
            f.close()
            if sha256 == file["SHA256"]:
                result = esperoj.utils.share(str(file_path), name, hosts_to_upload)
                logger.info(
                    f"Replicated file `{name}` in {time.time() - start_time} seconds"
                )
                return result
            raise VerificationError(f"Verification failed for file `{name}`")

    errors = []

    with concurrent.futures.ThreadPoolExecutor(max_workers=4) as executor:
        futures = {
            executor.submit(replicate_file, file): file for file in files_to_process
        }
        for future in concurrent.futures.as_completed(futures):
            try:
                results = future.result()
                file = futures[future]
                for host, result in results.items():
                    if isinstance(result, Exception):
                        errors.append(result)
                    else:
                        file[host] = result
                if file["Internet Archive"] == "https://example.com/":
                    url = file.fields.get(file_hosts[0])
                    if url:
                        archive_url = esperoj.save_page(url)
                        file.update({"Internet Archive": archive_url})
            except Exception as e:
                errors.append(e)
    if errors:
        logger.error(f"Replication failed with errors: {', '.join(errors)}")
        raise ReplicationError("Replication failed for one or more files.")


def get_esperoj_method(esperoj):
    """Create a partial function with esperoj object.

    Args:
        esperoj (object): An object to be passed as an argument to the partial function.

    Returns:
        functools.partial: A partial function with esperoj object bound to it.
    """
    return partial(replicate, esperoj)


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
        replicate(esperoj, max_files)

    return click_command
