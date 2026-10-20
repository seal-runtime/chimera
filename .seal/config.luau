local config = {
    entry_path = "./examples/site.luwu",
    test_path = "./tests/run.luwu",
    seal_version = "0.9.0"
}

export type SealConfig = {
    --- Script that `seal run` runs; usually the entrypoint to your codebase.
    --- Defaults to `./src/main.luau`.
    entry_path: string?,
    --- Script that `seal test` runs; usually a test runner.
    test_path: string?,
    --- semver version of seal this project/typedefs expects to run on
    seal_version: string,
}

return config :: SealConfig