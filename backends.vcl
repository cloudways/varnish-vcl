backend default {
    .host = "127.0.0.1";
    .port = "8081";
    .first_byte_timeout = 1800s;
    .between_bytes_timeout = 1800s;
    .connect_timeout = 10s;
}

backend admin {
    .host = "127.0.0.1";
    .port = "8081";
    .first_byte_timeout = 1800s;
    .between_bytes_timeout = 1800s;
    .connect_timeout = 10s;
}
