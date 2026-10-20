export type xz = {
    --[=[
        Compresses xz-encoded (.xz) data at compression `level`.

        xz levels range from 0 (fastest) to 9 (most compressed); defaults to 6.
    ]=]
    compress: (content: string | buffer, level: number?) -> buffer,
    --[=[
        Decompress xz-encoded (.xz) data up to `max_size` (default 1 GB).
    ]=]
    decompress: (content: buffer, max_size: FileSize?) -> buffer,
}

return {} :: xz
