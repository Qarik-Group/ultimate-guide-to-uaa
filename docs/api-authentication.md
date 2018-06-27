# API Authentication

The `uaa` CLI subcommands all support the `-v` and `--verbose` flag which will show you the API commands and headers included. This will allow you to start to learn the underlying API calls and their responses (which are typically the `uaa` CLI responses).

```text
uaa userinfo --verbose
```

The abridged output is similar to:

```text
GET /userinfo?scheme=openid HTTP/1.1
Host: 192.168.50.6:8443
Accept: application/json
Authorization: bearer eyJhbGciOiJSUzI1NiIsImtpZCI6ImxlZ2FjeS10b2tlbi1rZXkiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiI3MTMzOTFmY2E2OGU0MjlkYWRiY2FlNDFjNDI5OWYwNiIsInN1YiI6IjEwNjYxZDQ3LTZkMDgtNDg3Mi04MWFhLTc4NjgzMjdjZmYwYiIsInNjb3BlIjpbIm9wZW5pZCJdLCJjbGllbnRfaWQiOiJ1YWEtY2xpLWF1dGhjb2RlIiwiY2lkIjoidWFhLWNsaS1hdXRoY29kZSIsImF6cCI6InVhYS1jbGktYXV0aGNvZGUiLCJncmFudF90eXBlIjoiYXV0aG9yaXphdGlvbl9jb2RlIiwidXNlcl9pZCI6IjEwNjYxZDQ3LTZkMDgtNDg3Mi04MWFhLTc4NjgzMjdjZmYwYiIsIm9yaWdpbiI6InVhYSIsInVzZXJfbmFtZSI6ImRybmljIiwiZW1haWwiOiJkcm5pY0BzdGFya2FuZHdheW5lIiwiYXV0aF90aW1lIjoxNTMwMDgwMDM1LCJyZXZfc2lnIjoiNjNhMTVlNDMiLCJpYXQiOjE1MzAwODAwNDgsImV4cCI6MTUzMDEyMzI0OCwiaXNzIjoiaHR0cHM6Ly8xOTIuMTY4LjUwLjY6ODQ0My9vYXV0aC90b2tlbiIsInppZCI6InVhYSIsImF1ZCI6WyJ1YWEtY2xpLWF1dGhjb2RlIiwib3BlbmlkIl19.LWrz6p-uXs9TFI4wUB5XbEVEmQOhAXR3_ShVxOOhrwfWnhF1q9UITWd2MwmHqbQzDRHUQniwIq3bjYfsrmvbKLRVTkZtvzerLX8kMkUhwDy7eaERxkcjkkUjxkTS5TU512ywEX0pZ3NcRkFdUbJV45_sTWpH35I6U4l-PWPL_z01se2eeU2Wqg0xHZu0MoNuvVR2TfJU_OtZLB_J0tmvEGekm77XaaoLOb7PXtQrT6XPyuFjsOXz22TnDHHCKghuQ4hnO8p3yc1c6zbVrW-ha_jIQcelN65C9Z0EjqgTHWzatc-rltycUUxzU-LhhSoSohVlnrfUdHR5gRKKWU8Cqw
X-Identity-Zone-Subdomain:


HTTP/1.1 200
Transfer-Encoding: chunked
Cache-Control: no-cache, no-store, max-age=0, must-revalidate
Content-Type: application/json;charset=UTF-8
Date: Wed, 27 Jun 2018 06:19:10 GMT
Expires: 0
Pragma: no-cache
Strict-Transport-Security: max-age=31536000 ; includeSubDomains
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-Xss-Protection: 1; mode=block

111
{"user_id":"10661d47-6d08-4872-81aa-7868327cff0b","sub":"10661d47-6d08-4872-81aa-7868327cff0b","user_name":"drnic","given_name":"Dr Nic","family_name":"Williams","email":"drnic@starkandwayne","phone_number":null,"previous_logon_time":1530077822573,"name":"Dr Nic Williams"}
0
```

The first line `GET /userinfo?scheme=openid HTTP/1.1` shows the UAA API call invoked by the `uaa userinfo` command. The `Authorization` header is our temporary authorization code that we can use for API calls on behalf of the user.

Try reproducing the same API call using a different HTTP client, replacing `Authorization: bearer eyJhbG...` with the output from your `uaa userinfo -v` command earlier:

```text
curl -k -H 'Accept: application/json' https://192.168.50.6:8443/userinfo\?scheme=openid -H 'Authorization: bearer eyJhbG...'
```

The JSON output is the same as earlier:

```json
{"user_id":"10661d47-6d08-4872-81aa-7868327cff0b","sub":"10661d47-6d08-4872-81aa-7868327cff0b","user_name":"drnic","given_name":"Dr Nic","family_name":"Williams","email":"drnic@starkandwayne.com","phone_number":null,"previous_logon_time":1530077822573,"name":"Dr Nic Williams"}
```

We can act as an unauthenticated user if we omit the `-H 'Authorization:...'` flag:

```text
curl -k -H 'Accept: application/json' https://192.168.50.6:8443/userinfo\?scheme=openid
```

The output will indicate we are not an authenticated user for whom `/userinfo` API is meaningful nor permitted:

```json
{"error":"unauthorized","error_description":"Full authentication is required to access this resource"}
```

## Password Authentication

```text
uaa get-password-token uaa_cli -s uaa_cli_secret -u drnic -p drnic_secret --verbose
```

The HTTP request is `POST /oauth/token` with a collection of parameters:

```text
POST /oauth/token HTTP/1.1
Host: 192.168.50.6:8443
Accept: application/json
Content-Length: 140
Content-Type: application/x-www-form-urlencoded
X-Identity-Zone-Subdomain:

client_id=uaa_cli&client_secret=uaa_cli_secret&username=drnic&password=drnic_secret&grant_type=password&response_type=token&token_format=jwt
```

The `client_id`/`client_secret` and `username`/`password` from our `uaa get-password-token` command are passed, in addition to parameters `grant_type=password`, `response_type=token`, and `token_format=jwt`.

The response section, formatted nicely, will look similar to:

```json
{
  "access_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImxlZ2FjeS10b2tlbi1rZXkiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiI1M2Y2NjljMmViZjA0MGFiOWJkYmFkYmQ3OTEzODViMyIsInN1YiI6IjEwNjYxZDQ3LTZkMDgtNDg3Mi04MWFhLTc4NjgzMjdjZmYwYiIsInNjb3BlIjpbIm9wZW5pZCJdLCJjbGllbnRfaWQiOiJ1YWFfY2xpIiwiY2lkIjoidWFhX2NsaSIsImF6cCI6InVhYV9jbGkiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJ1c2VyX2lkIjoiMTA2NjFkNDctNmQwOC00ODcyLTgxYWEtNzg2ODMyN2NmZjBiIiwib3JpZ2luIjoidWFhIiwidXNlcl9uYW1lIjoiZHJuaWMiLCJlbWFpbCI6ImRybmljQHN0YXJrYW5kd2F5bmUiLCJhdXRoX3RpbWUiOjE1MzAwOTcwODMsInJldl9zaWciOiJjZWM2ZWFhYSIsImlhdCI6MTUzMDA5NzA4MywiZXhwIjoxNTMwMDk3MjAzLCJpc3MiOiJodHRwczovLzE5Mi4xNjguNTAuNjo4NDQzL29hdXRoL3Rva2VuIiwiemlkIjoidWFhIiwiYXVkIjpbInVhYV9jbGkiLCJvcGVuaWQiXX0.MsUYmp-bGvINCCncnLUgqdbOraPUxJ942KJu_7jc0bJz1oKT4RxbrR1GcfIE00F18MWdsB0xflYlZ4rgsWdwBl4EMJzr5RdMhoRUQBu2LTq9YzEn9zh5pfD6WRujDCUyh2m1PNITcZ0Lcs2-vUwysI27yIrD6e_Is3It5eP6gye4nPokSjbJTNwOBaIEi0k-D2_Iere6xJtHlxM9Wvc568pTsNiHamNHphhW4gy9q2GKY45usVmpUm1hSIh6T3QuWaR5nNXOBNLynwhjVZtQmxE0OskPGBL1OcFeOsVGmEmH4bgnzL2Q3QNp6Z9YEzgG77yCQYu3AoXiTWOsDE8tnQ",
  "token_type": "bearer",
  "refresh_token": "eyJhbGciOiJSUzI1NiIsImtpZCI6ImxlZ2FjeS10b2tlbi1rZXkiLCJ0eXAiOiJKV1QifQ.eyJqdGkiOiJlYjk2OWJkYTQ0Zjc0ZTcyOTZiNDE3OThmMTJkNDAxZi1yIiwic3ViIjoiMTA2NjFkNDctNmQwOC00ODcyLTgxYWEtNzg2ODMyN2NmZjBiIiwic2NvcGUiOlsib3BlbmlkIl0sImlhdCI6MTUzMDA5NzA4MywiZXhwIjoxNTMwMTgzNDgzLCJjaWQiOiJ1YWFfY2xpIiwiY2xpZW50X2lkIjoidWFhX2NsaSIsImlzcyI6Imh0dHBzOi8vMTkyLjE2OC41MC42Ojg0NDMvb2F1dGgvdG9rZW4iLCJ6aWQiOiJ1YWEiLCJncmFudF90eXBlIjoicGFzc3dvcmQiLCJ1c2VyX25hbWUiOiJkcm5pYyIsIm9yaWdpbiI6InVhYSIsInVzZXJfaWQiOiIxMDY2MWQ0Ny02ZDA4LTQ4NzItODFhYS03ODY4MzI3Y2ZmMGIiLCJyZXZfc2lnIjoiY2VjNmVhYWEiLCJhdWQiOlsidWFhX2NsaSIsIm9wZW5pZCJdfQ.k4rvCmQsOmP5L_CXD8jr-UwBmoX9YWJGgY_R-AjzvUgZAI47cf_lzaSWI9iH4TigbWdvkFfU9ZUtpvN9dtX3-cxm2sLdCcdptsH5cGv6QqNIZEzjDYMxfXMQMOZEjSI5HefAXg43PtybC06eLkFLFqWqRrYezGa66Ryo-rg2inFpIDfuGF5U3ZlhLArqq_CY-OmG73j4GkLOhLQqNPGmTBHIzXrsngb9L0Eb518frCtSvSVBaOZgoYtI_sJv2BaI0xsnb7fviq74JJC7u8EC4Gmn_831WlkOH7eJqFngTmYOUchwNs5tB2MXEjddsHu7NgiXjWfXtiLEnnWchgI8FA",
  "expires_in": 119,
  "scope": "openid",
  "jti": "53f669c2ebf040ab9bdbadbd791385b3"
}
```

The `access_token` and `refresh_token` are JSON Web Tokens (JWT) and can be decoded with a JWT library, or the [jwt.io](https://jwt.io/) website:

![jwt-decode](images/jwt-decode.png)

Some interesting attributes about the newly authenticated user are returned within the `access_token`:

* `"user_id": "10661d47-6d08-4872-81aa-7868327cff0b"`
* `"user_name": "drnic"`
* `"email": "drnic@starkandwayne"`

The `access_token` is also the `Authorization: bearer <access_token>` used to make subsequent API calls on behalf of the `drnic` user, as per the section above.