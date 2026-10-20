local _types = require("@self/_types")

--[=[
    Read, write, and extract the most common archive type I know of,
    the DEFLATE-based zip format.

    ## Usage

    Example: extract new album to Music folder, fixing song paths.

    ```luau
    const zip = require("@std/archive/zip")
    const fs = require("@std/fs")
    const str = require("@std/str")

    const archive_path = fs.dir.home()
        :expect_dir("Downloads")
        :list(false, function(p)
            -- assume album is only zip in downloads dir
            return str.endswith(p, ".zip")
        end)[1]

    const artist_dir = fs.dir.home()
        :expect_dir("Music")
        :expect_dir("Future Palace")
    
    const output_path = artist_dir:join("Resurgence")

    const arc = zip.readfile(archive_path)
    -- fix paths by removing unneeded directory from all paths before extraction
    for _, entry in arc do
        const file = entry:expect_file()
        -- path is like "Future Palace - Resurgence/10 Symphony of the Clouds.flac"
        -- but we want it saved like "Resurgence/10 Symphony of the Clouds.flac" where Resurgence is output_path
        const path = assert(fs.path.child(file:path()), "can't get child of path")
        entry:set_path(path)
    end
    arc:extract(output_path)
    fs.removefile(archive_path)
    ```
]=]
export type zip = {
    --[=[
        Extract the zip file into a new or existing directory at `destination`.

        `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
        Prefer passing a path on disk for performance reasons.

        This protects against path traversal attacks (unexpectedly writing outside destination directory),
        symlink traversal attacks, and caps archive and individual file sizes to prevent zip bombs.

        To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.

        ## Errors

        Throws an error if the zip file isn't valid, doesn't exist, is permission denied, etc.
    ]=]
    extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
    --[=[
        Reads the zip file at `path` into memory as an `Archive`. Other than requiring `path`
        be a zip file, has the same erroring semantics as `fs.readfile`.

        To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
    ]=]
    readfile: (path: string, options: ArchiveOptions?) -> Archive,
    --[=[
        Writes an archive to `path`. Other than requiring the `archive` be valid, has the same
        erroring semantics as `fs.writefile`.

        To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
    ]=]
    writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
    --[=[
        Load a zip file into memory as an `Archive` from an existing buffer of bytes.
    ]=]
    load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
    --[=[
        Create a new empty `Archive`.
    ]=]
    create: () -> Archive,
    --[=[
        Builds a `Deflate CompressionLevel` for use when writing/serializing zip archives.

        For no compression, use mode `"Store"`.

        For configurable compression levels, use mode `"Deflate"`.

        When mode is `"Deflate"`, compression `level` can range from 0 (no compression) to 9 (best).
        Defaults to 6.
    ]=]
    compression: (mode: "Store" | "Deflate", level: number?) -> CompressionLevel,
}

export type ArchiveOptions = _types.ArchiveOptions
export type ArchiveFormat = _types.ArchiveFormat

return {} :: zip