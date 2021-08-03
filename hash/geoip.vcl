if (req.http.X-Forwarded-Country) {
    hash_data(req.http.X-Forwarded-Country);
}
if (req.http.X-Forwarded-Continent) {
    hash_data(req.http.X-Forwarded-Continent);
}