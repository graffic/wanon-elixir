#!/bin/sh
set -e
release_ctl eval --mfa "Wanon.Migrations.migrate/1" --argv -- "$@"
$RELEASE_ROOT_DIR/bin/wanon foreground