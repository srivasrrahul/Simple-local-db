# Simple-local-db
This provides a single node key value db service.
Services provides HTTP based simple interface:

1. GET example (http://127.0.0.1:8080?key=K2) returns value in body else 500
2. POST example (http://127.0.0.1:8080?key=K2&value=test) returns 200 OK if updated successfully.

This service is based on erlang though without using any of fancy features like ets/dts.
It stores data in form of different files with consistent hashing based approach.

Its uses mochiweb framework for web handling.
