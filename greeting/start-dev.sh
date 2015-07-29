#!/bin/sh
exec erl \
    -pa ebin deps/*/ebin \
    -boot start_sasl \
    -sname greeting_dev \
    -s greeting \
    -s reloader
