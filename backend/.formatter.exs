[
  import_deps: [
    :ash,
    :ash_postgres,
    :ash_phoenix,
    :ash_authentication,
    :ecto,
    :ecto_sql,
    :phoenix
  ],
  subdirectories: ["priv/*/migrations"],
  inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}", "priv/*/seeds.exs"]
]
