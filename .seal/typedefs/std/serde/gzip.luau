export type gzip = {
    --[=[
        Compresses gzip-encoded (.gz) data at compression `level`.

        gzip levels range from 0 (fastest) to 9 (most compressed); defaults to 6.
    ]=]
    compress: (content: string | buffer, level: number?) -> buffer,
    --[=[
        Decompress gzip-encoded (.gz) data up to `max_size` (default 1 GB).
    ]=]
    decompress: (content: buffer, max_size: FileSize?) -> buffer,
}
return {} :: gzip
