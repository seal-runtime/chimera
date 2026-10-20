local _types = require("./_types")

--[=[
    Read, write, and extract tar ("Tape Archive") archives, affectionally known as
    tarballs, split by the compression codec applied to the tarball 
    ("uncompressed" for none).
]=]
export type tar = {
    --[=[
        Unzip/Unball(is that a word?) gzip-compressed tarballs (`.tar.gz`/`.tgz`),
        the most common type of archive on Linux and Unix-like platforms.

        tar.gz tarballs are fast to decompress and are very well supported, but have a compression ratio lower
        than tar.xz, zstd, and 7z.

        If you don't know who or what will need to decompress the archive, use zip or this.

        Uses gzip's default compression level (6), unless `ArchiveOptions.compression_level` is provided.
    ]=]
    gz: {
        --[=[
            Extract the tar.gz archive into a new or existing directory at `destination`.
            This function has the same erroring semantics as `fs.writefile`.
            
            `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
            Prefer passing a path on disk for performance reasons.

            This protects against path traversal attacks (unexpectedly writing outside destination directory),
            symlink traversal attacks, and caps archive and individual file sizes to prevent extraction bombs.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.

            ## Errors

            Throws an error if the path doesn't exist, path doesn't lead to a valid `TarGz` archive,
            is permission denied, or another IO error occurs.
        ]=]
        extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
        --[=[
            Read the tar.gz archive at `path` into memory as an `Archive` with the same erroring semantics
            as `fs.readfile`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.

            ## Errors

            Throws an error if the path doesn't exist, isn't a valid `tar.gz` archive, permission denied, etc. 
        ]=]
        readfile: (path: string, options: ArchiveOptions?) -> Archive,
        --[=[
            Write an `Archive` to `path` as a tar.gz archive with the same erorring semantics as `fs.writefile`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
        --[=[
            Load a tar.gz archive into memory as an `Archive` from an existing buffer of bytes.
        ]=]
        load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
        --[=[
            Create a new empty `Archive`.
        ]=]
        create: () -> Archive,
        --[=[
            Builds a `Gzip CompressionLevel` to use when writing or serializing tar.gz archives.

            `level` must be in the range of 0 (no compression) to 9 (best); defaults to 6.
        ]=]
        compression: (level: number) -> CompressionLevel,
    },
    --[=[
        Plain tarball with no compression. You might be looking for `tar.gz` instead.
    ]=]
    uncompressed: {
        --[=[
            Extract an uncompressed tar archive into a new or existing directory at `destination`.
            This function has the same erroring semantics as `fs.writefile`.

            `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
            Prefer passing a path on disk for performance reasons.

            This protects against path traversal attacks (unexpectedly writing outside destination directory),
            symlink traversal attacks, and caps archive and individual file sizes to prevent extraction bombs.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
        --[=[
            Read the tar archive at `path` into memory as an `Archive` with the same erroring semantics as `fs.readfile`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        readfile: (path: string, options: ArchiveOptions?) -> Archive,
        --[=[
            Write an `Archive` to `path` as an uncompressed tar archive.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
        --[=[
            Load a tar archive into memory as an `Archive` from an existing buffer of bytes.
        ]=]
        load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
        --[=[
            Create a new empty `Archive`.
        ]=]
        create: () -> Archive,
    },
    --[=[
        xz-compressed tarballs (`.tar.xz`), using LZMA2.

        Best-in-class compression ratio, on par with 7z, but noticeably slower to compress than
        gzip or zstd.
        
        Good for release tarballs you compress once and many people decompress.

        Uses xz preset 6, unless `ArchiveOptions.compression_level` is provided.
    ]=]
    xz: {
        --[=[
            Extract the tar.xz archive into a new or existing directory at `destination`.

            `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
            Prefer passing a path on disk for performance reasons.

            This protects against path traversal attacks (unexpectedly writing outside destination directory),
            symlink traversal attacks, and caps archive and individual file sizes to prevent extraction bombs.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
        --[=[
            Read the tar.xz archive at `path` into memory as an `Archive`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        readfile: (path: string, options: ArchiveOptions?) -> Archive,
        --[=[
            Write an `Archive` to `path` as a tar.xz archive.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
        --[=[
            Load a tar.xz archive into memory as an `Archive` from an existing buffer of bytes.
        ]=]
        load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
        --[=[
            Create a new empty `Archive`.
        ]=]
        create: () -> Archive,
        --[=[
            Builds an `Xz CompressionLevel` to use when writing or serializing tar.xz archives.

            `level` is xz/LZMA2's preset and must be in the range of 0 (fastest) - 9 (best); defaults to 6.
        ]=]
        compression: (level: number) -> CompressionLevel,
    },
    --[=[
        lz4-compressed tarballs (`.tar.lz4`).

        The fastest codec here to compress and decompress but has the worst compression ratio.
        
        Uses lz4's fast mode (level 0), not its high-compression mode, unless `ArchiveOptions.compression_level`
        is provided.
    ]=]
    lz4: {
        --[=[
            Extract the tar.lz4 archive into a new or existing directory at `destination`.

            `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
            Prefer passing a path on disk for performance reasons.

            This protects against path traversal attacks (unexpectedly writing outside destination directory),
            symlink traversal attacks, and caps archive and individual file sizes to prevent extraction bombs.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
        --[=[
            Read the tar.lz4 archive at `path` into memory as an `Archive`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        readfile: (path: string, options: ArchiveOptions?) -> Archive,
        --[=[
            Write an `Archive` to `path` as a tar.lz4 archive.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
        --[=[
            Load a tar.lz4 archive into memory as an `Archive` from an existing buffer of bytes.
        ]=]
        load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
        --[=[
            Create a new empty `Archive`.
        ]=]
        create: () -> Archive,
        --[=[
            Builds a `Lz4 CompressionLevel` to use when writing or serializing tar.lz4 archives.

            `level` is lz4's level; must be in the range of 0 (fast mode) - 16 (best, high-compression mode); defaults to 0.
        ]=]
        compression: (level: number) -> CompressionLevel,
    },
    --[=[
        bzip2-compressed tarballs (`.tar.bz2`).

        Can beat gzip's ratio on text-heavy data, but is slower to compress and decompress than
        gzip, lz4, or zstd, and has been largely superseded by xz/zstd. Mainly useful for
        compatibility with older tooling that expects bz2.

        Uses bzip2's default compression level (6), unless `ArchiveOptions.compression_level` is provided.
    ]=]
    bz2: {
        --[=[
            Extract the tar.bz2 archive into a new or existing directory at `destination`.

            `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
            Prefer passing a path on disk for performance reasons.

            This protects against path traversal attacks (unexpectedly writing outside destination directory),
            symlink traversal attacks, and caps archive and individual file sizes to prevent extraction bombs.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
        --[=[
            Read the tar.bz2 archive at `path` into memory as an `Archive`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        readfile: (path: string, options: ArchiveOptions?) -> Archive,
        --[=[
            Write an `Archive` to `path` as a tar.bz2 archive.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
        --[=[
            Load a tar.bz2 archive into memory as an `Archive` from an existing buffer of bytes.
        ]=]
        load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
        --[=[
            Create a new empty `Archive`.
        ]=]
        create: () -> Archive,
        --[=[
            Builds a `Bz2 CompressionLevel` to use when writing or serializing tar.bz2 archives.

            `level` is bzip2's level and must be in the range of 1 (fastest) - 9 (best); defaults to 6.
        ]=]
        compression: (level: number) -> CompressionLevel,
    },
    --[=[
        Zstandard-compressed tarballs (`.tar.zst`).

        We compress at zstd's default level (3), which is fast like gzip/lz4 while landing closer to
        xz's ratio than gzip does. 
        
        The best general-purpose choice unless you need gzip (`tar.gz`) ubiquity or xz/7z's maximum ratio.

        If you want to write `tar.zst` archives with a different compression level or other zstd
        options (checksums, window log, etc.), create the tarball as tar.uncompressed and then
        compress it with`@std/serde/zstd` before writing it to disk.
    ]=]
    zst: {
        --[=[
            Extract the tar.zst archive into a new or existing directory at `destination`. Same erroring
            semantics as `fs.writefile`.
    
            `path_or_archive` can be a path string or an `Archive` instance you've read and modified in memory.
            Prefer passing a path on disk for performance reasons.

            This protects against path traversal attacks (unexpectedly writing outside destination directory),
            symlink traversal attacks, and caps archive and individual file sizes to prevent extraction bombs.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        extract: (path_or_archive: string | Archive, destination: string, options: ArchiveOptions?) -> (),
        --[=[
            Read the tar.zst archive at `path` into memory as an `Archive`.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        readfile: (path: string, options: ArchiveOptions?) -> Archive,
        --[=[
            Write an `Archive` to `path` as a tar.zst archive.

            To increase size limits, allow unsafe path traversals or allow symlinks, see `ArchiveOptions`.
        ]=]
        writefile: (path: string, archive: Archive, options: ArchiveOptions?) -> (),
        --[=[
            Load a tar.zst archive into memory as an `Archive` from an existing buffer of bytes.
        ]=]
        load: (bytes: buffer, options: ArchiveOptions?) -> Archive,
        --[=[
            Create a new empty `Archive`.
        ]=]
        create: () -> Archive,
        --[=[
            Builds a `Zstd CompressionLevel` for use when writing/serializing tar.zst archives.

            `level` is zstd's level, -7 (fastest) - 22 (best); default is 3. 
            Passing 0 tells zstd to use its default compression level (3).
        ]=]
        compression: (level: number) -> CompressionLevel,
    },
}

export type ArchiveOptions = _types.ArchiveOptions
export type ArchiveFormat = _types.ArchiveFormat

return {} :: tar
