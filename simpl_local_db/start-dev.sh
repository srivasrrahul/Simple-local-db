#!/bin/sh
exec erl \
    -pa ebin deps/*/ebin \
    -boot start_sasl \
    -sname simpl_local_db_dev \
    -s simpl_local_db \
    -s reloader
