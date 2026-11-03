# Render Markdown files as pages in the browser, offline (Pandoc): mdv README.md
function mdv
    for src in $argv
        if not test -f $src
            echo "mdv: $src not found" >&2
            continue
        end
        set -l dir (path dirname (path resolve $src))
        set -l out $TMPDIR/mdv/(path change-extension html (path basename $src))
        mkdir -p (path dirname $out)
        set -l common --to=html5 --standalone --embed-resources \
            --css=$HOME/.config/pandoc/mdv.css --lua-filter=$HOME/.config/pandoc/mdv.lua \
            --resource-path=$dir --output=$out $src
        # Front matter that isn't valid YAML fails the first run; render it as text instead
        pandoc --from=gfm+yaml_metadata_block $common 2>/dev/null
        or pandoc --from=gfm-yaml_metadata_block $common
        and open $out
    end
end
