#!/bin/sh
set -e
$RELEASE_ROOT_DIR/bin/wanon command Elixir.Wanon.Migrations seed
$RELEASE_ROOT_DIR/bin/wanon foreground