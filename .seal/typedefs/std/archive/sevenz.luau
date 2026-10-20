local _types = require("@self/_types")
export type ArchiveOptions = _types.ArchiveOptions
export type ArchiveFormat = _types.ArchiveFormat

--[=[
    Read, write, and extract the 7z format.

    7z (LZMA2) usually beats zip and tar.xz on compression ratio, at the cost of being slower
    to compress and less universally supported than zip.

    Uses LZMA2 preset 6, the same default as tar.xz.
    There is currently no way to change its compression ratio.

    Although the 7z format supports symlinks and other special files, this library
    cannot handle them correctly and reads 7z symlinks as regular files with their
    target in their file contents. This is a limitation of the sevenz crate.
]=]
export type sevenz = {
    --[=[
        Extract the 7z archive into the directory at `destination`, creating a new
        directory if needed. This function has the same erroring semantics as `fs.writefile`.

        `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
        Prefer passing a path on disk for performance reasons.

        This protects against path traversal attacks (unexpectedly writing outside destination directory),
        symlink traversal attacks, and caps archive and individual file sizes to prevent zip bombs.

        If you hit an error extracting a directory to a destination folder you're re-using, just remove that
        destination folder first with `fs.removetree`.

        To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
    ]=]
    extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
    --[=[
        Read the 7z archive at `path` into memory as an `Archive` with the same erroring semantics as `fs.readfile`.

        To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
    ]=]
    readfile: (path: string, options: ArchiveOptions?) -> Archive,
    --[=[
        Write an `Archive` to `path` as a 7z archive with the same erorring semantics as `fs.writefile`.

        To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
    ]=]
    writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
    --[=[
        Load a 7z archive into memory as an `Archive` from an existing buffer of bytes.
    ]=]
    load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
    --[=[
        Create a new empty `Archive`.
    ]=]
    create: () -> Archive,
}

return {} :: sevenz