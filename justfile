#!/usr/bin/env just --justfile

bt := '0'
export RUST_BACKTRACE := bt

log := "warn"
export JUST_LOG := log


_default:
  just --list

test:
    cargo test

fmt:
    cargo fmt

lint: fmt
    cargo clippy

build:
    cargo build
 
run-ci: lint build test

# utility functions
start_time := `date +%s`
_timer:
	@echo "[TASK]: Executed in $(($(date +%s) - {{ start_time }})) seconds"

# mode: makefile
# End:
# vim: set ft=make :
