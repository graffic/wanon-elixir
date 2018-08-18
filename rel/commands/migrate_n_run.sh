#!/bin/sh
set -e
$RELEASE_ROOT_DIR/bin/wanon command Elixir.Wanon.Migrations migrate
$RELEASE_ROOT_DIR/bin/wanon foreground