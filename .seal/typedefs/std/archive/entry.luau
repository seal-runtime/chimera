--[=[
    Constructors of `ArchiveEntry` instances for `@std/archive` functions and `Archive` methods.
]=]
export type entry = {
    --[=[
        Create new entries (file/directory/symlink)
    ]=]
    create: {
        --[=[
            Create a new file `ArchiveEntry` with default unix permissions and no modified time.

            Call methods on this to set unix_mode and modified time.
        ]=]
        file: (path: string, contents: string | buffer) -> ArchiveEntryFile,
        --[=[
            Create a new directory `ArchiveEntry` with default unix permissions and no modified time.

            Call methods on this to set unix_mode and modified time.
        ]=]
        directory: (path: string) -> ArchiveEntryDirectory,
        --[=[
            Create a new symlink `ArchiveEntry` with default unix permissions and no modified time.

            Call methods on this to set unix_mode and modified time.
        ]=]
        symlink: (path: string, target: string) -> ArchiveEntrySymlink,
    },
    --[=[
        Create an `ArchiveEntry` from existing files/directories on disk. Preserves unix permissions
        and modified time if present. Returns a single ArchiveEntry when `path` points to a file,
        or `{ ArchiveEntry }` if path points to a directory. You can pass the return of this
        directly to `Archive:append`. Not able to create symlinks at this moment.

        By default, archive paths for files read via this function will default to just the child/basename/filename
        path component (`"./project/cache/important.json"` becomes a File with archive path `"important.json"`). 
        
        To preserve directory nesting, pass a second argument `as_archive_path`.

        If `as_archive_path` is specified, 
        - files will use it as an **explicit path** (`as_archive_path: "cache/important.json"`),
        - directories will have each of their **children's names joined** to it 
        (`as_archive_path: "cache" -> `"cache/important.json")

        If `as_archive_path` is a number, **keeps the last child components** of the path instead of only the filename.
        (`entry.read("./src/main.luau", 2)` gives File with archive path `src/main.luau`).
    ]=]
    read: (path: string, as_archive_path: (string | number)?) -> ArchiveEntry | { ArchiveEntry },
}

return {} :: entry