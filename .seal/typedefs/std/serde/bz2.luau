export type bz2 = {
    --[=[
        Compresses bzip2-encoded (.bz2) data at compression `level`.

        bzip2 levels range from 1 (fastest) to 9 (most compressed); defaults to 6.
    ]=]
    compress: (content: string | buffer, level: number?) -> buffer,
    --[=[
        Decompress bzip2-encoded (.bz2) data up to `max_size` (default 1 GB).
    ]=]
    decompress: (content: buffer, max_size: FileSize?) -> buffer,
}

return {} :: bz2
