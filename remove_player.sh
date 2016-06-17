#!/bin/bash
cd players
ls | grep -E '^[0-9]+.rb$' | xargs -i rm '{}'
