#!/bin/sh
set -e
#$RELEASE_ROOT_DIR/bin/wanon command Elixir.Wanon.Migrations migrate
release_ctl eval --mfa "Wanon.Migrations.migrate/1" --argv -- "$@"
$RELEASE_ROOT_DIR/bin/wanon foreground